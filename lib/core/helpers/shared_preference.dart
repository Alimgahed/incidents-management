import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._();

  // ── Singleton cache ────────────────────────────────────────────────────────
  //
  // Populated by [init] during startup (before any storage call runs).
  // All public methods use [instance] synchronously so they never need to
  // re-await SharedPreferences.getInstance() after warm-up completes.

  static SharedPreferences? _prefs;

  /// Called once from [StartupService] after [SharedPreferences.getInstance]
  /// resolves. Must be called before any other method on this class.
  static void init(SharedPreferences prefs) => _prefs = prefs;

  /// Synchronous access to the cached [SharedPreferences] instance.
  /// Asserts in debug mode if [init] was not called first.
  static SharedPreferences get instance {
    assert(
      _prefs != null,
      'SharedPreferencesHelper.init() must be called before using the helper.',
    );
    return _prefs!;
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Save a primitive value. Supported types: [String], [int], [bool],
  /// [double], [List<String>].
  static Future<bool> saveData<T>(String key, T value) async {
    if (kDebugMode) debugPrint('Saving data: $key = $value');

    final prefs = instance;
    if (value is String) return prefs.setString(key, value);
    if (value is int) return prefs.setInt(key, value);
    if (value is bool) return prefs.setBool(key, value);
    if (value is double) return prefs.setDouble(key, value);
    if (value is List<String>) return prefs.setStringList(key, value);

    if (kDebugMode) debugPrint('❌ Unsupported type for key: $key');
    return false;
  }

  /// Save a JSON map as an encoded string.
  static Future<bool> saveJson(String key, Map<String, dynamic> json) async {
    if (kDebugMode) debugPrint('Saving JSON: $key');
    return instance.setString(key, jsonEncode(json));
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Read a primitive value. Returns `null` if the key is absent.
  static Future<T?> getData<T>(String key) async {
    return instance.get(key) as T?;
  }

  /// Read a JSON-encoded map. Returns `null` if absent or malformed.
  static Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = instance.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error decoding JSON for key: $key');
      return null;
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Remove a single key.
  static Future<bool> removeData(String key) async {
    if (kDebugMode) debugPrint('Removing data for key: $key');
    return instance.remove(key);
  }

  /// Clear every key in SharedPreferences.
  static Future<bool> clearAllData() async {
    if (kDebugMode) debugPrint('Clearing all shared preferences data');
    return instance.clear();
  }
}
