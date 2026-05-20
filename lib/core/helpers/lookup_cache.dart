import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';

/// Persistent cache for static lookup tables (incident types, classes, missions).
///
/// Reads and writes via [SharedPreferencesHelper.instance] — the synchronous
/// singleton cached at startup — so no async [SharedPreferences.getInstance]
/// round-trip is needed inside any of these methods.
///
/// Each entry is stored as a JSON-encoded list alongside a Unix-millisecond
/// timestamp used to enforce the [ttl]. Call [read] for fresh-only access,
/// [readStale] to get cached data regardless of age (useful as a network-
/// failure fallback).
///
/// Usage in a repository:
/// ```dart
/// // Try fresh cache first
/// final cached = await LookupCacheService.read(_cacheKey);
/// if (cached != null) return ApiResult.success(cached.map(MyModel.fromJson).toList());
///
/// // Network fetch
/// final items = await apiService.getAll();
/// LookupCacheService.write(_cacheKey, items.map((e) => e.toJson()).toList()); // fire-and-forget
/// return ApiResult.success(items);
/// ```
class LookupCacheService {
  LookupCacheService._();

  // Default TTL: 24 hours — lookup tables rarely change.
  static const Duration defaultTtl = Duration(hours: 24);

  static const String _timestampSuffix = '__ts';

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns the cached list if it exists **and** is younger than [ttl].
  /// Returns `null` if the entry is missing or expired.
  static Future<List<Map<String, dynamic>>?> read(
    String key, {
    Duration ttl = defaultTtl,
  }) async {
    try {
      final prefs = SharedPreferencesHelper.instance;
      final raw = prefs.getString(key);
      final tsRaw = prefs.getInt('$key$_timestampSuffix');

      if (raw == null || tsRaw == null) return null;

      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(tsRaw),
      );
      if (age > ttl) return null; // expired

      return _decode(raw);
    } catch (e) {
      if (kDebugMode) debugPrint('[LookupCache] read error for "$key": $e');
      return null;
    }
  }

  /// Returns the cached list regardless of age (stale-but-usable fallback).
  /// Returns `null` only if no entry has ever been written for [key].
  static Future<List<Map<String, dynamic>>?> readStale(String key) async {
    try {
      final raw = SharedPreferencesHelper.instance.getString(key);
      if (raw == null) return null;
      return _decode(raw);
    } catch (e) {
      if (kDebugMode) debugPrint('[LookupCache] readStale error for "$key": $e');
      return null;
    }
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Persists [data] under [key] and records the current time as the write
  /// timestamp. Silently swallows errors so a write failure never crashes the
  /// app; the next network response will attempt to write again.
  static Future<void> write(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final prefs = SharedPreferencesHelper.instance;
      await Future.wait([
        prefs.setString(key, jsonEncode(data)),
        prefs.setInt(
          '$key$_timestampSuffix',
          DateTime.now().millisecondsSinceEpoch,
        ),
      ]);
    } catch (e) {
      if (kDebugMode) debugPrint('[LookupCache] write error for "$key": $e');
    }
  }

  // ── Invalidate ────────────────────────────────────────────────────────────

  /// Removes both the data and timestamp entries for [key], forcing the next
  /// [read] to go to the network. Useful after an admin mutation (add/edit/
  /// delete of a lookup item).
  static Future<void> invalidate(String key) async {
    try {
      final prefs = SharedPreferencesHelper.instance;
      await Future.wait([
        prefs.remove(key),
        prefs.remove('$key$_timestampSuffix'),
      ]);
    } catch (e) {
      if (kDebugMode) debugPrint('[LookupCache] invalidate error for "$key": $e');
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _decode(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return List<Map<String, dynamic>>.generate(
      list.length,
      (i) => Map<String, dynamic>.from(list[i] as Map),
      growable: false,
    );
  }
}
