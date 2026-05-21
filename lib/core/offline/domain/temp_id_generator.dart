import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../data/local_database.dart';

/// Strategy: server ids are positive non-zero ints; temp ids are negative ints
/// that count down monotonically from -1. Negative numbers compare correctly
/// in lists/maps and round-trip through JSON without quoting tricks. Once an
/// item is acknowledged by the server, [IdRemapService] swaps the temp id for
/// the real (positive) server id.
///
/// For non-incident, non-mission entities that don't have a numeric server id
/// we generate a `local_<uuid>` string instead.
class TempIdGenerator {
  static const String _kCounterKey = 'temp_id_counter';
  static const _uuid = Uuid();

  /// Returns a negative integer, monotonically decreasing across app
  /// restarts. Safe to call from any isolate.
  static int nextNumeric() {
    final Box box = LocalDatabase.keyValue;
    final current = (box.get(_kCounterKey) as int?) ?? 0;
    final next = current - 1;
    box.put(_kCounterKey, next);
    return next;
  }

  /// Returns `local_<uuid>`. For entities without a numeric id (e.g. comments,
  /// reactions).
  static String nextString() => 'local_${_uuid.v4()}';

  /// `true` for any id produced by [nextNumeric].
  static bool isTempNumeric(int id) => id < 0;

  /// `true` for any id produced by [nextString].
  static bool isTempString(String id) => id.startsWith('local_');
}
