import 'package:flutter/foundation.dart';

/// Heuristic parse of CMS "description" blobs (mixed Arabic/English, noise chars).
///
/// Does not call the network; safe to run on every build.
@immutable
class ParsedIncidentDescription {
  const ParsedIncidentDescription({
    required this.raw,
    this.title,
    this.type,
    this.locationFromDescription,
    this.technicalDetails,
  });

  final String raw;
  final String? title;

  /// Machine-friendly hint, e.g. [water_incident]; may be null.
  final String? type;
  final String? locationFromDescription;
  final String? technicalDetails;

  /// Short line for headers / list tiles.
  String get displayTitle {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    final f = IncidentDescriptionParser._firstMeaningfulLine(raw);
    return IncidentDescriptionParser._limitWords(
      IncidentDescriptionParser._stripNoise(f),
      8,
    );
  }

  /// True when parsing produced something cleaner than the raw blob.
  bool get looksStructured =>
      (title != null &&
          title!.trim().isNotEmpty &&
          title!.trim() != raw.trim()) ||
      locationFromDescription != null ||
      technicalDetails != null;
}

/// Parses incident description strings from external CMS / legacy forms.
class IncidentDescriptionParser {
  IncidentDescriptionParser._();

  static ParsedIncidentDescription parse(String? input) {
    final raw = (input ?? '').trim();
    if (raw.isEmpty) {
      return const ParsedIncidentDescription(raw: '');
    }

    final type = _detectType(raw);
    final withoutAddrLabel = raw
        .split(RegExp(r'\s*-\s*العنوان\s*:?'))
        .first
        .trim();
    final location = _extractLocation(withoutAddrLabel);
    final technical = _extractTechnical(raw);
    final strippedParens = _stripLatinGarbageParentheses(withoutAddrLabel);
    var working = _collapseWs(strippedParens);

    working = working.replaceAll(RegExp(r'^أزمة\s*#?\s*'), '');
    working = working.replaceAll(RegExp(r'#+'), ' ');
    working = _collapseWs(working);

    String? title = _titleFromBody(working, location);
    title = title == null || title.isEmpty ? null : _limitWords(title, 6);
    title = title == null || title.isEmpty ? null : _stripTrailingNoise(title);

    return ParsedIncidentDescription(
      raw: raw,
      title: title,
      type: type,
      locationFromDescription: location,
      technicalDetails: technical,
    );
  }

  static String? _detectType(String s) {
    if (RegExp(r'ماسورة|مياه|صرف|تسرب|سيل|فيضان|مطر').hasMatch(s)) {
      return 'water_incident';
    }
    if (RegExp(r'حريق|اشتعال|لهب').hasMatch(s)) return 'fire_incident';
    if (RegExp(r'كهرباء|كهربائي|مولد|كابل|أسلاك').hasMatch(s)) {
      return 'electrical_incident';
    }
    if (RegExp(r'غاز|تسرب غاز').hasMatch(s)) return 'gas_incident';
    if (RegExp(r'مركبة|حادث|سير|طريق|تصادم').hasMatch(s)) {
      return 'traffic_incident';
    }
    return null;
  }

  static String? _extractLocation(String s) {
    final m = RegExp(r'بمنطقة\s+(.+)$', dotAll: true).firstMatch(s.trim());
    if (m == null) return null;
    var loc = m.group(1)!;
    loc = loc.split('(').first;
    loc = _collapseWs(loc.replaceAll(RegExp(r'[:#]+'), ' '));
    if (loc.length < 2) return null;
    return loc;
  }

  static String? _extractTechnical(String s) {
    final parts = <String>[];

    final pipe = RegExp(
      r'ماسورة\s+مقاس\s*([^:)\n]+?)(?=\s*:\s*نوع|\s*\)|$)',
      caseSensitive: false,
    ).firstMatch(s);
    if (pipe != null) {
      var chunk = _collapseWs(pipe.group(1)!);
      chunk = chunk.replaceAll(RegExp(r':{2,}'), ' ');
      if (chunk.isNotEmpty) parts.add(chunk);
    }

    final mm = RegExp(r'\d+\s*مم(?:\s*\d+\s*بوصة)?').firstMatch(s);
    if (mm != null) {
      final t = mm.group(0)!;
      if (!parts.any((p) => p.contains(t))) parts.add(t);
    }

    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  static String _stripLatinGarbageParentheses(String s) {
    return s.replaceAllMapped(RegExp(r'\(\s*([^)]{0,120})\s*\)'), (m) {
      final inner = m.group(1)!.trim();
      if (inner.isEmpty) return ' ';
      final arabic = RegExp(r'[\u0600-\u06FF]').hasMatch(inner);
      final technical = RegExp(r'\d|مم|بوصة|مقاس').hasMatch(inner);
      if (arabic || technical) return m.group(0)!;
      if (RegExp(r'^[a-zA-Z0-9\s.,;!?_-]+$').hasMatch(inner) &&
          inner.length <= 48) {
        return ' ';
      }
      return m.group(0)!;
    });
  }

  static String? _titleFromBody(String working, String? location) {
    if (working.isEmpty) return null;
    var t = working;
    if (location != null && location.isNotEmpty) {
      final idx = t.indexOf('بمنطقة');
      if (idx > 0) {
        t = t.substring(0, idx).trim();
      }
    }
    t = t.split('(').first.trim();
    t = _collapseWs(t.replaceAll(RegExp(r'^\W+'), ''));
    return t.isEmpty ? null : t;
  }

  static String _stripNoise(String s) {
    var t = s.replaceAll(RegExp(r'[:]{3,}'), ' ');
    t = t.replaceAll(RegExp(r'[#]+'), ' ');
    t = t.replaceAll(RegExp(r'[(){}\[\]]'), ' ');
    return _collapseWs(t);
  }

  static String _firstMeaningfulLine(String s) {
    final line = s.split(RegExp(r'[\r\n]+')).first.trim();
    return _stripNoise(line);
  }

  static String _stripTrailingNoise(String s) {
    return s.replaceAll(RegExp(r'[\s:.\-_,]+$'), '').trim();
  }

  static String _limitWords(String s, int maxWords) {
    final words = s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length <= maxWords) return s.trim();
    return words.take(maxWords).join(' ');
  }

  static String _collapseWs(String s) =>
      s.replaceAll(RegExp(r'\s+'), ' ').trim();
}
