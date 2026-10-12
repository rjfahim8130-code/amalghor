import 'package:flutter/foundation.dart';

/// Category of a daily Amol (deed).
enum AmolCategory {
  tasbih,
  dua,
  dhikr,
  quranReading,
  salat,
  custom,
}

/// A single Amol definition.
@immutable
class Amol {
  final String id;
  final String titleEn;
  final String titleBn;
  final String titleAr;
  final String? descriptionEn;
  final String? descriptionBn;
  final String? descriptionAr;
  final AmolCategory category;
  final int? targetCount;
  final String? arabicText;
  final bool isDefault;

  const Amol({
    required this.id,
    required this.titleEn,
    required this.titleBn,
    required this.titleAr,
    this.descriptionEn,
    this.descriptionBn,
    this.descriptionAr,
    required this.category,
    this.targetCount,
    this.arabicText,
    this.isDefault = true,
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

  String? descriptionFor(String localeCode) {
    switch (localeCode) {
      case 'bn':
        return descriptionBn;
      case 'ar':
        return descriptionAr;
      default:
        return descriptionEn;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'titleEn': titleEn,
        'titleBn': titleBn,
        'titleAr': titleAr,
        'descriptionEn': descriptionEn,
        'descriptionBn': descriptionBn,
        'descriptionAr': descriptionAr,
        'category': category.name,
        'targetCount': targetCount,
        'arabicText': arabicText,
        'isDefault': isDefault,
      };

  factory Amol.fromMap(Map<String, dynamic> m) => Amol(
        id: m['id'] as String,
        titleEn: m['titleEn'] as String,
        titleBn: m['titleBn'] as String,
        titleAr: m['titleAr'] as String,
        descriptionEn: m['descriptionEn'] as String?,
        descriptionBn: m['descriptionBn'] as String?,
        descriptionAr: m['descriptionAr'] as String?,
        category: AmolCategory.values.firstWhere(
          (e) => e.name == m['category'],
          orElse: () => AmolCategory.custom,
        ),
        targetCount: m['targetCount'] as int?,
        arabicText: m['arabicText'] as String?,
        isDefault: m['isDefault'] as bool? ?? true,
      );
}

/// A single day's completion record for one Amol.
@immutable
class AmolProgress {
  final String amolId;
  final String dateIso;
  final int completedCount;
  final bool isDone;

  const AmolProgress({
    required this.amolId,
    required this.dateIso,
    required this.completedCount,
    required this.isDone,
  });

  Map<String, dynamic> toMap() => {
        'amolId': amolId,
        'dateIso': dateIso,
        'completedCount': completedCount,
        'isDone': isDone ? 1 : 0,
      };

  factory AmolProgress.fromMap(Map<String, dynamic> m) => AmolProgress(
        amolId: m['amolId'] as String,
        dateIso: m['dateIso'] as String,
        completedCount: m['completedCount'] as int,
        isDone: (m['isDone'] as int) == 1,
      );

  AmolProgress copyWith({
    int? completedCount,
    bool? isDone,
  }) {
    return AmolProgress(
      amolId: amolId,
      dateIso: dateIso,
      completedCount: completedCount ?? this.completedCount,
      isDone: isDone ?? this.isDone,
    );
  }
}

/// Built-in default Amols shipped with the app.
class DefaultAmols {
  DefaultAmols._();

  static const List<Amol> all = [
    Amol(
      id: 'tasbih_subhanallah',
      titleEn: 'Subhanallah (33x)',
      titleBn: 'সুবহানাল্লাহ (৩৩ বার)',
      titleAr: 'سبحان الله (٣٣)',
      category: AmolCategory.tasbih,
      targetCount: 33,
      arabicText: 'سُبْحَانَ اللَّهِ',
    ),
    Amol(
      id: 'tasbih_alhamdulillah',
      titleEn: 'Alhamdulillah (33x)',
      titleBn: 'আলহামদুলিল্লাহ (৩৩ বার)',
      titleAr: 'الحمد لله (٣٣)',
      category: AmolCategory.tasbih,
      targetCount: 33,
      arabicText: 'الْحَمْدُ لِلَّهِ',
    ),
    Amol(
      id: 'tasbih_allahuakbar',
      titleEn: 'Allahu Akbar (34x)',
      titleBn: 'আল্লাহু আকবার (৩৪ বার)',
      titleAr: 'الله أكبر (٣٤)',
      category: AmolCategory.tasbih,
      targetCount: 34,
      arabicText: 'اللَّهُ أَكْبَرُ',
    ),
    Amol(
      id: 'dua_morning',
      titleEn: 'Morning Dua',
      titleBn: 'সকালের দুআ',
      titleAr: 'دعاء الصباح',
      category: AmolCategory.dua,
    ),
    Amol(
      id: 'dua_evening',
      titleEn: 'Evening Dua',
      titleBn: 'সন্ধ্যার দুআ',
      titleAr: 'دعاء المساء',
      category: AmolCategory.dua,
    ),
    Amol(
      id: 'quran_daily',
      titleEn: 'Read Quran (1 page)',
      titleBn: 'কুরআন তিলাওয়াত (১ পৃষ্ঠা)',
      titleAr: 'قراءة القرآن (صفحة واحدة)',
      category: AmolCategory.quranReading,
      targetCount: 1,
    ),
  ];
}
