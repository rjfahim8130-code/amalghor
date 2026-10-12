import 'package:flutter/foundation.dart';

/// Metadata for a single Surah.
@immutable
class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameBangla;
  final String nameTransliteration;
  final int totalAyahs;
  final String revelationPlace; // 'makkah' | 'madinah'

  const Surah({
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

  factory Surah.fromMap(Map<String, dynamic> m) => Surah(
        number: m['number'] as int,
        nameArabic: m['nameArabic'] as String,
        nameEnglish: m['nameEnglish'] as String,
        nameBangla: m['nameBangla'] as String,
        nameTransliteration: m['nameTransliteration'] as String,
        totalAyahs: m['totalAyahs'] as int,
        revelationPlace: m['revelationPlace'] as String,
      );
}

/// A single Ayah (verse) record.
@immutable
class Ayah {
  final int surahNumber;
  final int ayahNumber;
  final String textArabic;
  final String? textBangla;
  final String? textEnglish;
  final String? transliteration;

  const Ayah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.textArabic,
    this.textBangla,
    this.textEnglish,
    this.transliteration,
  });

  Map<String, dynamic> toMap() => {
        'surah': surahNumber,
        'ayah': ayahNumber,
        'textArabic': textArabic,
        'textBangla': textBangla,
        'textEnglish': textEnglish,
        'transliteration': transliteration,
      };

  factory Ayah.fromMap(Map<String, dynamic> m) => Ayah(
        surahNumber: m['surah'] as int,
        ayahNumber: m['ayah'] as int,
        textArabic: m['textArabic'] as String,
        textBangla: m['textBangla'] as String?,
        textEnglish: m['textEnglish'] as String?,
        transliteration: m['transliteration'] as String?,
      );
}

/// A user-placed bookmark within the Quran.
@immutable
class QuranBookmark {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final DateTime createdAt;
  final String? note;

  const QuranBookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.createdAt,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'surah': surahNumber,
        'ayah': ayahNumber,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };

  factory QuranBookmark.fromMap(Map<String, dynamic> m) => QuranBookmark(
        id: m['id'] as int,
        surahNumber: m['surah'] as int,
        ayahNumber: m['ayah'] as int,
        createdAt: DateTime.parse(m['createdAt'] as String),
        note: m['note'] as String?,
      );
}
