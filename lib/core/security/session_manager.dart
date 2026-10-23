import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_response_model.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/helpers/shared_prefrence_constant.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/core/network/fcm_service.dart';
import 'package:incidents_managment/core/offline/domain/sync_manager.dart';
import 'package:incidents_managment/core/offline/data/repositories/attachment_cache_repository.dart';
import 'package:incidents_managment/core/offline/data/repositories/sync_queue_repository.dart';
import 'package:incidents_managment/core/offline/network/network_monitor.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/security/secure_storage_service.dart';

class SessionManager {
  final SecureStorageService _secureStorage;
  CurrentUser? _currentUser;
  Future<void>? _logoutInFlight;
  bool get isLoggingOut => _logoutInFlight != null;

  SessionManager({SecureStorageService? secureStorage})
    : _secureStorage = secureStorage ?? getIt<SecureStorageService>();

  /// Load user details on app start if they exist
  Future<void> initializeSession() async {
    _currentUser = await _secureStorage.getUserData();
  }

  /// Cache user in memory and secure storage
  Future<void> setCurrentUser(CurrentUser user) async {
    _currentUser = user;
    await _secureStorage.saveUserData(user);
  }

  /// Get currently logged in user
  CurrentUser? getCurrentUser() {
    return _currentUser;
  }

  /// Get current role authority name
  String getAuthorityName() {
    return _currentUser?.authorityName ?? '';
  }

  /// Check if current user is Supervisor or Administrator
  bool isSupervisorOrAdmin() {
    if (_currentUser == null) return false;
    final role = _currentUser?.authorityName?.trim();
    // In Arabic, "مشرف" = Supervisor, "مسؤول" or "المسؤول" = Admin/Supervisor
    return role == 'مشرف' ||
        role == 'مسؤول' ||
        role == 'المسؤول' ||
        (_currentUser?.authorityLevelId ?? 0) >= 2;
  }

  /// Check login status
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getUserToken();
    return token != null && token.isNotEmpty;
  }

  /// Global proactive logout flow
  Future<void> logout({bool sessionExpired = false}) {
    final inFlight = _logoutInFlight;
    if (inFlight != null) return inFlight;
    final operation = _logoutFlow();
    _logoutInFlight = operation;
    return operation.whenComplete(() => _logoutInFlight = null);
  }

  Future<void> _logoutFlow() async {
    if (await _hasPendingWork()) {
      try {
        if (getIt<NetworkMonitorService>().isOnline &&
            getIt.isRegistered<SyncManager>()) {
          await getIt<SyncManager>().syncNow();
        }
      } catch (_) {}
      if (await _hasPendingWork()) {
        await _showPendingWorkNotice();
        return;
      }
    }
    await _performLogout();
  }

  Future<bool> _hasPendingWork() async {
    try {
      final queued = getIt<SyncQueueRepository>().totalCount();
      final attachments = getIt<AttachmentCacheRepository>().countPending();
      return queued > 0 || attachments > 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showPendingWorkNotice() async {
    if (Get.isDialogOpen == true) return;
    await Get.dialog<void>(
      AlertDialog(
        title: const Text('توجد أعمال لم تتم مزامنتها'),
        content: const Text(
          'تم الاحتفاظ بالبلاغات والملفات المعلقة. اتصل بالإنترنت وأعد المحاولة بعد اكتمال المزامنة قبل تسجيل الخروج.',
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('حسناً'))],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _performLogout() async {
    try {
      if (getIt.isRegistered<SyncManager>()) await getIt<SyncManager>().stop();
    } catch (_) {}
    // 0. Notify backend to clear device token
    try {
      final fcmToken = await FcmService.getToken();
      await getIt<ApiService>().logout({"device_token": fcmToken ?? ""});
    } catch (_) {
      // Ignore API errors to ensure local logout completes
    }

    // 1. Clear secure storage
    await _secureStorage.clearAll();

    // 2. Clear old preferences token just in case
    await SharedPreferencesHelper.removeData(SharedPreferenceKeys.userToken);
    await SharedPreferencesHelper.removeData(SharedPreferenceKeys.refreshToken);

    // Reset in-memory cache
    _currentUser = null;

    // 3. Disconnect real-time Socket.IO if active
    try {
      if (getIt.isRegistered<IncidentMapCubit>()) {
        getIt<IncidentMapCubit>().disconnectSocket();
      }
    } catch (_) {}

    // 4. Redirect to login directly without any session expired dialogs
    Get.offAllNamed(Routes.login);
  }
}
