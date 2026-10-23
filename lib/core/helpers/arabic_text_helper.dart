/// Helper utility for normalizing Arabic text to provide robust,
/// accent-insensitive, and variant-tolerant Arabic search and comparison.
class ArabicTextHelper {
  ArabicTextHelper._();

  static final RegExp _diacriticsRegex = RegExp(r'[\u064B-\u0652\u0670\u0640]');
  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  /// Normalizes Arabic text by:
  /// - Lowercasing and trimming
  /// - Stripping Tashkeel (diacritics) and Tatweel (Kashida)
  /// - Normalizing Alef variants (أ, إ, آ, ٱ -> ا)
  /// - Normalizing Ta Marbuta (ة -> ه)
  /// - Normalizing Alef Maqsura (ى -> ي)
  /// - Collapsing multiple spaces into a single space
  static String normalize(String? text) {
    if (text == null || text.isEmpty) return '';

    var result = text.trim().toLowerCase();

    // 1. Remove diacritics and Tatweel
    result = result.replaceAll(_diacriticsRegex, '');

    // 2. Normalize Alef variants
    result = result.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // 3. Normalize Ta Marbuta to Ha
    result = result.replaceAll('ة', 'ه');

    // 4. Normalize Alef Maqsura to Ya
    result = result.replaceAll('ى', 'ي');

    // 5. Normalize whitespace
    result = result.replaceAll(_whitespaceRegex, ' ');

    return result.trim();
  }

  /// Checks if [source] contains [query] using normalized Arabic comparison.
  static bool contains(String? source, String query) {
    if (query.isEmpty) return true;
    if (source == null || source.isEmpty) return false;

    final normSource = normalize(source);
    final normQuery = normalize(query);

    return normSource.contains(normQuery);
  }
}
