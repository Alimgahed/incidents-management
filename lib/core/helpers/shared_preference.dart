import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._();

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Save data
  static Future<bool> saveData<T>(String key, T value) async {
    debugPrint('Saving data: $key = $value');

    final prefs = await _prefs;

    if (value is String) return prefs.setString(key, value);
    if (value is int) return prefs.setInt(key, value);
    if (value is bool) return prefs.setBool(key, value);
    if (value is double) return prefs.setDouble(key, value);
    if (value is List<String>) return prefs.setStringList(key, value);

    debugPrint('❌ Unsupported type for key: $key');
    return false;
  }

  /// Save JSON object as string
  static Future<bool> saveJson(String key, Map<String, dynamic> json) async {
    debugPrint('Saving JSON: $key');
    final prefs = await _prefs;
    final jsonString = jsonEncode(json);
    return prefs.setString(key, jsonString);
  }

  /// Read data
  static Future<T?> getData<T>(String key) async {
    final prefs = await _prefs;
    return prefs.get(key) as T?;
  }

  /// Read JSON object
  static Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error decoding JSON for key: $key');
      return null;
    }
  }

  /// Remove specific key
  static Future<bool> removeData(String key) async {
    debugPrint('Removing data for key: $key');
    final prefs = await _prefs;
    return prefs.remove(key);
  }

  /// Clear all keys
  static Future<bool> clearAllData() async {
    debugPrint('Clearing all shared preferences data');
    final prefs = await _prefs;
    return prefs.clear();
  }

  /// Secure storage methods
  static Future<void> setSecureString(String key, String value) async {
    const flutterSecureStorage = FlutterSecureStorage();
    await flutterSecureStorage.write(key: key, value: value);
  }

  static Future<String> getSecureString(String key) async {
    const flutterSecureStorage = FlutterSecureStorage();
    return await flutterSecureStorage.read(key: key) ?? '';
  }

  static Future<void> deleteSecureString(String key) async {
    const flutterSecureStorage = FlutterSecureStorage();
    await flutterSecureStorage.delete(key: key);
  }
}
