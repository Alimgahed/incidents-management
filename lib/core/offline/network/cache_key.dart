/// Canonical key shared by the in-memory and persistent GET caches.
/// Volatile timestamp parameters are ignored and query keys are ordered so
/// equivalent requests share one entry regardless of parameter order.
abstract final class CacheKey {
  static String fromUri(Uri uri) {
    final params = uri.queryParametersAll.map(
      (key, values) => MapEntry(key, List<String>.of(values)),
    )..remove('_t');
    final keys = params.keys.toList()..sort();
    final canonical = <String, List<String>>{};
    for (final key in keys) {
      final values = params[key]!..sort();
      canonical[key] = values;
    }
    return uri
        .replace(queryParameters: canonical.isEmpty ? null : canonical)
        .toString();
  }
}
