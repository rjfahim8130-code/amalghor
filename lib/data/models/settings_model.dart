import 'package:flutter/material.dart';

/// School of jurisprudence for Asr calculation.
enum MadhhabType {
  /// Asr shadow factor = 2 (Hanafi).
  hanafi,

  /// Asr shadow factor = 1 (Shafi'i, Maliki, Hanbali).
  shafii,
}

/// Astronomical calculation method standard.
enum CalcMethodType {
  /// University of Islamic Sciences, Karachi — widely used in South Asia.
  karachi,

  /// Muslim World League — Europe and Far East.
  mwl,

  /// Umm al-Qura, Makkah — Arabian Peninsula.
  ummAlQura,

  /// Egyptian General Authority of Survey.
  egyptian,

  /// Islamic Society of North America.
  isna,

  /// Institute of Geophysics, University of Tehran.
  tehran,

  /// Shia Ithna-Ashari, Leva Institute, Qum.
  shiaIthnaAshari,
}

/// Primary calendar used for display and PDF headers.
enum CalendarPrimary {
  english,
  bangla,
  hijri,
}

/// User-selectable app-wide configuration.
@immutable
class SettingsModel {
  final Locale locale;
  final ThemeMode themeMode;
  final MadhhabType madhhab;
  final CalcMethodType calcMethod;
  final CalendarPrimary calendarPrimary;

  // Notification toggles
  final bool notifFajr;
  final bool notifDhuhr;
  final bool notifAsr;
  final bool notifMaghrib;
  final bool notifIsha;
  final bool notifSehri;
  final bool notifIftar;

  const SettingsModel({
    this.locale = const Locale('en'),
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
  });

  String get languageCode => locale.languageCode;

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
      };

  factory SettingsModel.fromMap(Map<String, dynamic> m) {
    return SettingsModel(
      locale: Locale(m['locale'] as String? ?? 'en'),
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
          other.calendarPrimary == calendarPrimary &&
          other.notifFajr == notifFajr &&
          other.notifDhuhr == notifDhuhr &&
          other.notifAsr == notifAsr &&
          other.notifMaghrib == notifMaghrib &&
          other.notifIsha == notifIsha &&
          other.notifSehri == notifSehri &&
          other.notifIftar == notifIftar;

  @override
  int get hashCode => Object.hashAll([
        locale,
        themeMode,
        madhhab,
        calcMethod,
        calendarPrimary,
        notifFajr,
        notifDhuhr,
        notifAsr,
        notifMaghrib,
        notifIsha,
        notifSehri,
        notifIftar,
      ]);
}
