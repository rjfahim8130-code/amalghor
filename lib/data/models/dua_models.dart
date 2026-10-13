import 'package:flutter/foundation.dart';

/// A category of duas (e.g., Morning, Evening, Travel).
@immutable
class DuaCategory {
  final String id;
  final String titleEn;
  final String titleBn;
  final String titleAr;
  final String emoji;
  final int colorValue;

  const DuaCategory({
    required this.id,
    required this.titleEn,
    required this.titleBn,
    required this.titleAr,
    required this.emoji,
    required this.colorValue,
  });

  String titleFor(String localeCode) {
    switch (localeCode) {
      case 'bn':
        return titleBn;
      case 'ar':
        return titleAr;
      default:
        return titleEn;
    }
  }
}

/// A single dua.
@immutable
class Dua {
  final String id;
  final String categoryId;
  final String titleEn;
  final String titleBn;
  final String arabic;
  final String transliteration;
  final String meaningEn;
  final String meaningBn;
  final String? reference;

  const Dua({
    required this.id,
    required this.categoryId,
    required this.titleEn,
    required this.titleBn,
    required this.arabic,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningBn,
    this.reference,
  });

  String titleFor(String localeCode) {
    return localeCode == 'bn' ? titleBn : titleEn;
  }

  String meaningFor(String localeCode) {
    return localeCode == 'bn' ? meaningBn : meaningEn;
  }
}
