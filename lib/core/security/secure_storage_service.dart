import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_response_model.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage;

  SecureStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  static const String _keyUserToken = 'user_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData = 'user_data';

  /// Save raw string token
  Future<void> saveUserToken(String token) async {
    if (kIsWeb) {
      await SharedPreferencesHelper.saveData(_keyUserToken, token);
    } else {
      await _secureStorage.write(key: _keyUserToken, value: token);
    }
  }

  /// Get raw string token
  Future<String?> getUserToken() async {
    if (kIsWeb) {
      return await SharedPreferencesHelper.getData<String>(_keyUserToken);
    }
    return await _secureStorage.read(key: _keyUserToken);
  }

  /// Delete user token
  Future<void> deleteUserToken() async {
    if (kIsWeb) {
      await SharedPreferencesHelper.removeData(_keyUserToken);
    } else {
      await _secureStorage.delete(key: _keyUserToken);
    }
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    if (kIsWeb) {
      await SharedPreferencesHelper.saveData(_keyRefreshToken, token);
    } else {
      await _secureStorage.write(key: _keyRefreshToken, value: token);
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      return await SharedPreferencesHelper.getData<String>(_keyRefreshToken);
    }
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    if (kIsWeb) {
      await SharedPreferencesHelper.removeData(_keyRefreshToken);
    } else {
      await _secureStorage.delete(key: _keyRefreshToken);
    }
  }

  /// Save CurrentUser object as encrypted json string
  Future<void> saveUserData(CurrentUser user) async {
    final userJson = jsonEncode(user.toJson());
    if (kIsWeb) {
      await SharedPreferencesHelper.saveData(_keyUserData, userJson);
    } else {
      await _secureStorage.write(key: _keyUserData, value: userJson);
    }
  }

  /// Get CurrentUser object from encrypted JSON
  Future<CurrentUser?> getUserData() async {
    String? userJson;
    if (kIsWeb) {
      userJson = await SharedPreferencesHelper.getData<String>(_keyUserData);
    } else {
      userJson = await _secureStorage.read(key: _keyUserData);
    }
    if (userJson == null || userJson.isEmpty) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(userJson) as Map<String, dynamic>;
      return CurrentUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Delete user data
  Future<void> deleteUserData() async {
    if (kIsWeb) {
      await SharedPreferencesHelper.removeData(_keyUserData);
    } else {
      await _secureStorage.delete(key: _keyUserData);
    }
  }

  /// Clear all secure data on logout/session expiry
  Future<void> clearAll() async {
    if (kIsWeb) {
      await SharedPreferencesHelper.removeData(_keyUserToken);
      await SharedPreferencesHelper.removeData(_keyRefreshToken);
      await SharedPreferencesHelper.removeData(_keyUserData);
    } else {
      await _secureStorage.delete(key: _keyUserToken);
      await _secureStorage.delete(key: _keyRefreshToken);
      await _secureStorage.delete(key: _keyUserData);
    }
  }
}
