import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// QURAN DISPLAY MODE
// ─────────────────────────────────────────────

/// Which language layers to show in the reader.
///
/// The user can toggle any combination. Order of display is:
///   Arabic → Bangla → English
enum QuranLanguage {
  arabic,
  bangla,
  english,
}

/// A user-selected combination of languages to display.
@immutable
class QuranDisplayMode {
  final bool showArabic;
  final bool showBangla;
  final bool showEnglish;
  final double fontScale;
  final double lineHeight;

  const QuranDisplayMode({
    this.showArabic = true,
    this.showBangla = true,
    this.showEnglish = false,
    this.fontScale = 1.0,
    this.lineHeight = 1.6,
  });

  static const QuranDisplayMode arabicOnly = QuranDisplayMode(
    showArabic: true,
    showBangla: false,
    showEnglish: false,
  );

  static const QuranDisplayMode banglaOnly = QuranDisplayMode(
    showArabic: false,
    showBangla: true,
    showEnglish: false,
  );

  static const QuranDisplayMode englishOnly = QuranDisplayMode(
    showArabic: false,
    showBangla: false,
    showEnglish: true,
  );

  static const QuranDisplayMode arabicBangla = QuranDisplayMode(
    showArabic: true,
    showBangla: true,
    showEnglish: false,
  );

  static const QuranDisplayMode arabicEnglish = QuranDisplayMode(
    showArabic: true,
    showBangla: false,
    showEnglish: true,
  );

  static const QuranDisplayMode banglaEnglish = QuranDisplayMode(
    showArabic: false,
    showBangla: true,
    showEnglish: true,
  );

  static const QuranDisplayMode allThree = QuranDisplayMode(
    showArabic: true,
    showBangla: true,
    showEnglish: true,
  );

  int get visibleCount {
    var n = 0;
    if (showArabic) n++;
    if (showBangla) n++;
    if (showEnglish) n++;
    return n;
  }

  QuranDisplayMode copyWith({
    bool? showArabic,
    bool? showBangla,
    bool? showEnglish,
    double? fontScale,
    double? lineHeight,
  }) {
    return QuranDisplayMode(
      showArabic: showArabic ?? this.showArabic,
      showBangla: showBangla ?? this.showBangla,
      showEnglish: showEnglish ?? this.showEnglish,
      fontScale: fontScale ?? this.fontScale,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }

  Map<String, dynamic> toMap() => {
        'showArabic': showArabic,
        'showBangla': showBangla,
        'showEnglish': showEnglish,
        'fontScale': fontScale,
        'lineHeight': lineHeight,
      };

  factory QuranDisplayMode.fromMap(Map<String, dynamic> m) => QuranDisplayMode(
        showArabic: m['showArabic'] as bool? ?? true,
        showBangla: m['showBangla'] as bool? ?? true,
        showEnglish: m['showEnglish'] as bool? ?? false,
        fontScale: (m['fontScale'] as num?)?.toDouble() ?? 1.0,
        lineHeight: (m['lineHeight'] as num?)?.toDouble() ?? 1.6,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranDisplayMode &&
          other.showArabic == showArabic &&
          other.showBangla == showBangla &&
          other.showEnglish == showEnglish &&
          other.fontScale == fontScale &&
          other.lineHeight == lineHeight;

  @override
  int get hashCode => Object.hash(
        showArabic,
        showBangla,
        showEnglish,
        fontScale,
        lineHeight,
      );
}

// ─────────────────────────────────────────────
// SURAH — METADATA
// ─────────────────────────────────────────────

/// Immutable metadata for a single Surah.
@immutable
class SurahMeta {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameBangla;
  final String nameTransliteration;
  final int totalAyahs;
  final String revelationPlace; // 'makkah' | 'madinah'

  const SurahMeta({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameBangla,
    required this.nameTransliteration,
    required this.totalAyahs,
    required this.revelationPlace,
  });

  bool get isMakki => revelationPlace == 'makkah';
  bool get isMadani => revelationPlace == 'madinah';

  /// Localized name based on locale code.
  String nameFor(String localeCode) {
    switch (localeCode) {
      case 'bn':
        return nameBangla;
      case 'ar':
        return nameArabic;
      default:
        return nameEnglish;
    }
  }

  Map<String, dynamic> toMap() => {
        'number': number,
        'nameArabic': nameArabic,
        'nameEnglish': nameEnglish,
        'nameBangla': nameBangla,
        'nameTransliteration': nameTransliteration,
        'totalAyahs': totalAyahs,
        'revelationPlace': revelationPlace,
      };

  factory SurahMeta.fromMap(Map<String, dynamic> m) => SurahMeta(
        number: m['number'] as int,
        nameArabic: m['nameArabic'] as String,
        nameEnglish: m['nameEnglish'] as String,
        nameBangla: m['nameBangla'] as String,
        nameTransliteration: m['nameTransliteration'] as String,
        totalAyahs: m['totalAyahs'] as int,
        revelationPlace: m['revelationPlace'] as String,
      );
}

// ─────────────────────────────────────────────
// AYAH — A SINGLE VERSE
// ─────────────────────────────────────────────

/// A single Ayah with all available language texts.
///
/// Any of [textBangla], [textEnglish] can be null if that
/// translation is unavailable for the given verse.
@immutable
class Ayah {
  final int surahNumber;
  final int ayahNumber;
  final String textArabic;
  final String? textBangla;
  final String? textEnglish;

  const Ayah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.textArabic,
    this.textBangla,
    this.textEnglish,
  });

  /// Returns the appropriate text for a given language.
  String? textFor(QuranLanguage lang) {
    switch (lang) {
      case QuranLanguage.arabic:
        return textArabic;
      case QuranLanguage.bangla:
        return textBangla;
      case QuranLanguage.english:
        return textEnglish;
    }
  }

  Map<String, dynamic> toMap() => {
        'surah': surahNumber,
        'ayah': ayahNumber,
        'textArabic': textArabic,
        'textBangla': textBangla,
        'textEnglish': textEnglish,
      };

  factory Ayah.fromMap(Map<String, dynamic> m) => Ayah(
        surahNumber: m['surah'] as int,
        ayahNumber: m['ayah'] as int,
        textArabic: m['textArabic'] as String,
        textBangla: m['textBangla'] as String?,
        textEnglish: m['textEnglish'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ayah &&
          other.surahNumber == surahNumber &&
          other.ayahNumber == ayahNumber;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber);
}

// ─────────────────────────────────────────────
// BOOKMARK
// ─────────────────────────────────────────────

/// A user-saved bookmark at a specific Ayah.
@immutable
class QuranBookmark {
  final int? id;
  final int surahNumber;
  final int ayahNumber;
  final DateTime createdAt;
  final String? note;

  const QuranBookmark({
    this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.createdAt,
    this.note,
  });

  QuranBookmark copyWith({
    int? id,
    int? surahNumber,
    int? ayahNumber,
    DateTime? createdAt,
    String? note,
  }) {
    return QuranBookmark(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'surah': surahNumber,
        'ayah': ayahNumber,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };

  factory QuranBookmark.fromMap(Map<String, dynamic> m) => QuranBookmark(
        id: m['id'] as int?,
        surahNumber: m['surah'] as int,
        ayahNumber: m['ayah'] as int,
        createdAt: DateTime.parse(m['createdAt'] as String),
        note: m['note'] as String?,
      );
}

// ─────────────────────────────────────────────
// LAST READ POSITION
// ─────────────────────────────────────────────

/// Tracks the last Ayah the user was reading, so the app can
/// offer a "Continue Reading" shortcut.
@immutable
class LastReadPosition {
  final int surahNumber;
  final int ayahNumber;
  final DateTime readAt;

  const LastReadPosition({
    required this.surahNumber,
    required this.ayahNumber,
    required this.readAt,
  });

  Map<String, dynamic> toMap() => {
        'surah': surahNumber,
        'ayah': ayahNumber,
        'readAt': readAt.toIso8601String(),
      };

  factory LastReadPosition.fromMap(Map<String, dynamic> m) => LastReadPosition(
        surahNumber: m['surah'] as int,
        ayahNumber: m['ayah'] as int,
        readAt: DateTime.parse(m['readAt'] as String),
      );
}

// ─────────────────────────────────────────────
// SEARCH RESULT
// ─────────────────────────────────────────────

/// A single hit from a full-text search across all languages.
@immutable
class QuranSearchResult {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final QuranLanguage matchedLanguage;
  final String matchedText;
  final String snippet;

  const QuranSearchResult({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.matchedLanguage,
    required this.matchedText,
    required this.snippet,
  });
}
