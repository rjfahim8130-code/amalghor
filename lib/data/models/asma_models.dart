import 'package:flutter/foundation.dart';

/// A single one of the 99 Names of Allah.
@immutable
class AsmaName {
  final int number;          // 1..99
  final String arabic;
  final String transliteration;
  final String englishMeaning;
  final String banglaMeaning;

  const AsmaName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.englishMeaning,
    required this.banglaMeaning,
  });

  /// Localized meaning based on the current locale code.
  String meaningFor(String localeCode) {
    switch (localeCode) {
      case 'bn':
        return banglaMeaning;
      case 'ar':
        return arabic;
      default:
        return englishMeaning;
    }
  }

  Map<String, dynamic> toMap() => {
        'number': number,
        'arabic': arabic,
        'transliteration': transliteration,
        'englishMeaning': englishMeaning,
        'banglaMeaning': banglaMeaning,
      };

  factory AsmaName.fromMap(Map<String, dynamic> m) => AsmaName(
        number: m['number'] as int,
        arabic: m['arabic'] as String,
        transliteration: m['transliteration'] as String,
        englishMeaning: m['englishMeaning'] as String,
        banglaMeaning: m['banglaMeaning'] as String,
      );
}
