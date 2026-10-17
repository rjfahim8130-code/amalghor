import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum MadhhabType { hanafi, shafii }

enum CalcMethodType {
  karachi,
  mwl,
  ummAlQura,
  egyptian,
  isna,
  tehran,
  shiaIthnaAshari,
}

enum CalendarPrimary { english, bangla, hijri }

@immutable
class SettingsModel {
  final Locale locale;
  final ThemeMode themeMode;
  final MadhhabType madhhab;
  final CalcMethodType calcMethod;
  final CalendarPrimary calendarPrimary;

  // ─── Prayer notification toggles ─────────────
  final bool notifFajr;
  final bool notifDhuhr;
  final bool notifAsr;
  final bool notifMaghrib;
  final bool notifIsha;
  final bool notifSehri;
  final bool notifIftar;
  final bool notifTahajjud;

  // ─── Per-prayer reminder offsets (minutes) ───
  /// Positive = before the prayer (notification arrives X minutes earlier).
  final int offsetFajr;
  final int offsetDhuhr;
  final int offsetAsr;
  final int offsetMaghrib;
  final int offsetIsha;
  final int offsetSehri;
  final int offsetIftar;
  final int offsetTahajjud;

  const SettingsModel({
    this.locale = const Locale('bn'),
    this.themeMode = ThemeMode.dark,
    this.madhhab = MadhhabType.hanafi,
    this.calcMethod = CalcMethodType.karachi,
    this.calendarPrimary = CalendarPrimary.english,
    this.notifFajr = true,
    this.notifDhuhr = true,
    this.notifAsr = true,
    this.notifMaghrib = true,
    this.notifIsha = true,
    this.notifSehri = true,
    this.notifIftar = true,
    this.notifTahajjud = false,
    this.offsetFajr = 0,
    this.offsetDhuhr = 0,
    this.offsetAsr = 0,
    this.offsetMaghrib = 0,
    this.offsetIsha = 0,
    this.offsetSehri = 15,
    this.offsetIftar = 10,
    this.offsetTahajjud = 0,
  });

  String get languageCode => locale.languageCode;

  int offsetFor(String key) {
    switch (key) {
      case 'fajr':
        return offsetFajr;
      case 'dhuhr':
        return offsetDhuhr;
      case 'asr':
        return offsetAsr;
      case 'maghrib':
        return offsetMaghrib;
      case 'isha':
        return offsetIsha;
      case 'sehri':
        return offsetSehri;
      case 'iftar':
        return offsetIftar;
      case 'tahajjud':
        return offsetTahajjud;
      default:
        return 0;
    }
  }

  Map<String, dynamic> toMap() => {
        'locale': locale.languageCode,
        'themeMode': themeMode.name,
        'madhhab': madhhab.name,
        'calcMethod': calcMethod.name,
        'calendarPrimary': calendarPrimary.name,
        'notifFajr': notifFajr,
        'notifDhuhr': notifDhuhr,
        'notifAsr': notifAsr,
        'notifMaghrib': notifMaghrib,
        'notifIsha': notifIsha,
        'notifSehri': notifSehri,
        'notifIftar': notifIftar,
        'notifTahajjud': notifTahajjud,
        'offsetFajr': offsetFajr,
        'offsetDhuhr': offsetDhuhr,
        'offsetAsr': offsetAsr,
        'offsetMaghrib': offsetMaghrib,
        'offsetIsha': offsetIsha,
        'offsetSehri': offsetSehri,
        'offsetIftar': offsetIftar,
        'offsetTahajjud': offsetTahajjud,
      };

  factory SettingsModel.fromMap(Map<String, dynamic> m) {
    return SettingsModel(
      locale: Locale(m['locale'] as String? ?? 'bn'),
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == m['themeMode'],
        orElse: () => ThemeMode.dark,
      ),
      madhhab: MadhhabType.values.firstWhere(
        (e) => e.name == m['madhhab'],
        orElse: () => MadhhabType.hanafi,
      ),
      calcMethod: CalcMethodType.values.firstWhere(
        (e) => e.name == m['calcMethod'],
        orElse: () => CalcMethodType.karachi,
      ),
      calendarPrimary: CalendarPrimary.values.firstWhere(
        (e) => e.name == m['calendarPrimary'],
        orElse: () => CalendarPrimary.english,
      ),
      notifFajr: m['notifFajr'] as bool? ?? true,
      notifDhuhr: m['notifDhuhr'] as bool? ?? true,
      notifAsr: m['notifAsr'] as bool? ?? true,
      notifMaghrib: m['notifMaghrib'] as bool? ?? true,
      notifIsha: m['notifIsha'] as bool? ?? true,
      notifSehri: m['notifSehri'] as bool? ?? true,
      notifIftar: m['notifIftar'] as bool? ?? true,
      notifTahajjud: m['notifTahajjud'] as bool? ?? false,
      offsetFajr: m['offsetFajr'] as int? ?? 0,
      offsetDhuhr: m['offsetDhuhr'] as int? ?? 0,
      offsetAsr: m['offsetAsr'] as int? ?? 0,
      offsetMaghrib: m['offsetMaghrib'] as int? ?? 0,
      offsetIsha: m['offsetIsha'] as int? ?? 0,
      offsetSehri: m['offsetSehri'] as int? ?? 15,
      offsetIftar: m['offsetIftar'] as int? ?? 10,
      offsetTahajjud: m['offsetTahajjud'] as int? ?? 0,
    );
  }

  SettingsModel copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    MadhhabType? madhhab,
    CalcMethodType? calcMethod,
    CalendarPrimary? calendarPrimary,
    bool? notifFajr,
    bool? notifDhuhr,
    bool? notifAsr,
    bool? notifMaghrib,
    bool? notifIsha,
    bool? notifSehri,
    bool? notifIftar,
    bool? notifTahajjud,
    int? offsetFajr,
    int? offsetDhuhr,
    int? offsetAsr,
    int? offsetMaghrib,
    int? offsetIsha,
    int? offsetSehri,
    int? offsetIftar,
    int? offsetTahajjud,
  }) {
    return SettingsModel(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      madhhab: madhhab ?? this.madhhab,
      calcMethod: calcMethod ?? this.calcMethod,
      calendarPrimary: calendarPrimary ?? this.calendarPrimary,
      notifFajr: notifFajr ?? this.notifFajr,
      notifDhuhr: notifDhuhr ?? this.notifDhuhr,
      notifAsr: notifAsr ?? this.notifAsr,
      notifMaghrib: notifMaghrib ?? this.notifMaghrib,
      notifIsha: notifIsha ?? this.notifIsha,
      notifSehri: notifSehri ?? this.notifSehri,
      notifIftar: notifIftar ?? this.notifIftar,
      notifTahajjud: notifTahajjud ?? this.notifTahajjud,
      offsetFajr: offsetFajr ?? this.offsetFajr,
      offsetDhuhr: offsetDhuhr ?? this.offsetDhuhr,
      offsetAsr: offsetAsr ?? this.offsetAsr,
      offsetMaghrib: offsetMaghrib ?? this.offsetMaghrib,
      offsetIsha: offsetIsha ?? this.offsetIsha,
      offsetSehri: offsetSehri ?? this.offsetSehri,
      offsetIftar: offsetIftar ?? this.offsetIftar,
      offsetTahajjud: offsetTahajjud ?? this.offsetTahajjud,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModel &&
          other.locale == locale &&
          other.themeMode == themeMode &&
          other.madhhab == madhhab &&
          other.calcMethod == calcMethod &&
          other.calendarPrimary == calendarPrimary;

  @override
  int get hashCode => Object.hash(
        locale,
        themeMode,
        madhhab,
        calcMethod,
        calendarPrimary,
      );
}
