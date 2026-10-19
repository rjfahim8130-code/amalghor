import 'package:flutter/foundation.dart';

/// A single Tasbih (dhikr) definition.
@immutable
class Tasbih {
  final String id;
  final String titleAr;
  final String titleEn;
  final String titleBn;
  final String transliteration;
  final String? meaning;
  final int target;
  final bool isDefault;

  const Tasbih({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.titleBn,
    required this.transliteration,
    this.meaning,
    this.target = 33,
    this.isDefault = true,
  });

  /// Title localized for the given locale code.
  ///
  /// Arabic UI is not supported. Use [titleAr] directly if you need to
  /// display the Arabic script (which is often shown alongside the
  /// localized title).
  String titleFor(String localeCode) {
    switch (localeCode) {
      case 'bn':
        return titleBn;
      default:
        return titleEn;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'titleBn': titleBn,
        'transliteration': transliteration,
        'meaning': meaning,
        'target': target,
        'isDefault': isDefault,
      };

  factory Tasbih.fromMap(Map<String, dynamic> m) => Tasbih(
        id: m['id'] as String,
        titleAr: m['titleAr'] as String,
        titleEn: m['titleEn'] as String,
        titleBn: m['titleBn'] as String,
        transliteration: m['transliteration'] as String,
        meaning: m['meaning'] as String?,
        target: m['target'] as int? ?? 33,
        isDefault: m['isDefault'] as bool? ?? true,
      );
}

/// A per-day session of one Tasbih.
@immutable
class TasbihSession {
  final String tasbihId;
  final String dateIso;
  final int count;
  final DateTime lastUpdated;

  const TasbihSession({
    required this.tasbihId,
    required this.dateIso,
    required this.count,
    required this.lastUpdated,
  });

  TasbihSession copyWith({
    int? count,
    DateTime? lastUpdated,
  }) {
    return TasbihSession(
      tasbihId: tasbihId,
      dateIso: dateIso,
      count: count ?? this.count,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() => {
        'tasbihId': tasbihId,
        'dateIso': dateIso,
        'count': count,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory TasbihSession.fromMap(Map<String, dynamic> m) => TasbihSession(
        tasbihId: m['tasbihId'] as String,
        dateIso: m['dateIso'] as String,
        count: m['count'] as int,
        lastUpdated: DateTime.parse(m['lastUpdated'] as String),
      );
}

/// Built-in default Tasbih list.
class DefaultTasbihs {
  DefaultTasbihs._();

  static const List<Tasbih> all = [
    Tasbih(
      id: 'subhanallah',
      titleAr: 'سُبْحَانَ اللَّهِ',
      titleEn: 'Subhanallah',
      titleBn: 'সুবহানাল্লাহ',
      transliteration: 'Subhanallah',
      meaning: 'আল্লাহ পবিত্র',
      target: 33,
    ),
    Tasbih(
      id: 'alhamdulillah',
      titleAr: 'الْحَمْدُ لِلَّهِ',
      titleEn: 'Alhamdulillah',
      titleBn: 'আলহামদুলিল্লাহ',
      transliteration: 'Alhamdulillah',
      meaning: 'সমস্ত প্রশংসা আল্লাহর',
      target: 33,
    ),
    Tasbih(
      id: 'allahuakbar',
      titleAr: 'اللَّهُ أَكْبَرُ',
      titleEn: 'Allahu Akbar',
      titleBn: 'আল্লাহু আকবার',
      transliteration: 'Allahu Akbar',
      meaning: 'আল্লাহ মহান',
      target: 34,
    ),
    Tasbih(
      id: 'lailahaillallah',
      titleAr: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      titleEn: 'La ilaha illallah',
      titleBn: 'লা ইলাহা ইল্লাল্লাহ',
      transliteration: 'La ilaha illallah',
      meaning: 'আল্লাহ ছাড়া কোনো ইলাহ নেই',
      target: 100,
    ),
    Tasbih(
      id: 'astaghfirullah',
      titleAr: 'أَسْتَغْفِرُ اللَّهَ',
      titleEn: 'Astaghfirullah',
      titleBn: 'আস্তাগফিরুল্লাহ',
      transliteration: 'Astaghfirullah',
      meaning: 'আমি আল্লাহর কাছে ক্ষমা চাই',
      target: 100,
    ),
    Tasbih(
      id: 'salawat',
      titleAr: 'صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ',
      titleEn: 'Salawat on the Prophet',
      titleBn: 'নবীজির উপর দরুদ',
      transliteration: 'Sallallahu alayhi wa sallam',
      meaning: 'নবীজির উপর শান্তি বর্ষিত হোক',
      target: 100,
    ),
  ];
}
