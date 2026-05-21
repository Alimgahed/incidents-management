import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_response_model.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/helpers/shared_prefrence_constant.dart';
import 'package:incidents_managment/core/offline/offline_bootstrap.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/security/secure_storage_service.dart';

class SessionManager {
  final SecureStorageService _secureStorage;
  CurrentUser? _currentUser;
  bool _isSessionExpiredAlertShowing = false;

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
    return role == 'مشرف' || role == 'مسؤول' || role == 'المسؤول' || (_currentUser?.authorityLevelId ?? 0) >= 2;
  }

  /// Check login status
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getUserToken();
    return token != null && token.isNotEmpty;
  }

  /// Global proactive logout flow
  Future<void> logout({bool sessionExpired = false}) async {
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

    // 4. Wipe the offline cache so the next user doesn't inherit pending
    //    queue items, cached lists, or attachments from this session.
    try {
      await OfflineBootstrap.resetOnLogout();
    } catch (_) {}

    // 5. Redirect to login
    if (sessionExpired) {
      _showSessionExpiredAlert();
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  /// Display a professional dialog on session expiration
  void _showSessionExpiredAlert() {
    if (_isSessionExpiredAlertShowing) return;
    _isSessionExpiredAlertShowing = true;

    Get.dialog(
      PopScope(
        canPop: false, // Prevent dismissal by back button
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text(
                'انتهت الجلسة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'لقد انتهت صلاحية الجلسة الخاصة بك. يرجى تسجيل الدخول مرة أخرى للمتابعة.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _isSessionExpiredAlertShowing = false;
                Get.back(); // Close dialog
                Get.offAllNamed(Routes.login); // Redirect to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('تسجيل الدخول', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
