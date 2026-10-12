import 'package:flutter/material.dart';

/// Global application constants.
class AppConstants {
  AppConstants._();

  // ─────────────────────────────────────────────
  // IDENTITY
  // ─────────────────────────────────────────────
  static const String appName = 'Amalghor';
  static const String appNameBn = 'আমলঘর';
  static const String appNameAr = 'أملغور';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.amalghor.app';

  // ─────────────────────────────────────────────
  // COLORS — AMOLED-first palette
  // ─────────────────────────────────────────────
  static const Color amoledBlack = Color(0xFF0B0F12);
  static const Color surfaceDark = Color(0xFF161D24);
  static const Color surfaceDarker = Color(0xFF0F1418);
  static const Color emeraldPrimary = Color(0xFF10B981);
  static const Color emeraldGlow = Color(0xFF00C853);
  static const Color goldAccent = Color(0xFFD4A24A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textFaint = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFF1F2937);

  // Light theme palette
  static const Color lightBg = Color(0xFFF9FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextMuted = Color(0xFF6B7280);

  // ─────────────────────────────────────────────
  // LOCALES
  // ─────────────────────────────────────────────
  static const Locale localeEn = Locale('en');
  static const Locale localeBn = Locale('bn');
  static const Locale localeAr = Locale('ar');

  static const List<Locale> supportedLocales = [
    localeEn,
    localeBn,
    localeAr,
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'bn': 'বাংলা',
    'ar': 'العربية',
  };

  // ─────────────────────────────────────────────
  // SPACING
  // ─────────────────────────────────────────────
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double space2xl = 32.0;

  // ─────────────────────────────────────────────
  // RADII
  // ─────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ─────────────────────────────────────────────
  // TYPOGRAPHY SIZES
  // ─────────────────────────────────────────────
  static const double fontDisplay = 48.0;
  static const double fontTitle = 24.0;
  static const double fontHeading = 20.0;
  static const double fontSubtitle = 16.0;
  static const double fontBody = 14.0;
  static const double fontCaption = 12.0;
  static const double fontMicro = 10.0;

  // ─────────────────────────────────────────────
  // STORAGE KEYS (SharedPreferences)
  // ─────────────────────────────────────────────
  static const String keyLocale = 'settings.locale';
  static const String keyThemeMode = 'settings.theme_mode';
  static const String keyMadhhab = 'settings.madhhab';
  static const String keyCalculationMethod = 'settings.calc_method';
  static const String keyCalendarPrimary = 'settings.calendar_primary';
  static const String keyLatitude = 'location.latitude';
  static const String keyLongitude = 'location.longitude';
  static const String keyLocationName = 'location.name';
  static const String keyTimezone = 'location.timezone';
  static const String keyManualLocation = 'location.manual';
  static const String keyNotifFajr = 'notif.fajr';
  static const String keyNotifDhuhr = 'notif.dhuhr';
  static const String keyNotifAsr = 'notif.asr';
  static const String keyNotifMaghrib = 'notif.maghrib';
  static const String keyNotifIsha = 'notif.isha';
  static const String keyNotifSehri = 'notif.sehri';
  static const String keyNotifIftar = 'notif.iftar';
  static const String keyOnboarded = 'app.onboarded';

  // ─────────────────────────────────────────────
  // DATABASE
  // ─────────────────────────────────────────────
  static const String dbName = 'amalghor.db';
  static const int dbVersion = 1;
  static const String tablePrayerCache = 'prayer_cache';
  static const String tableBookmarks = 'quran_bookmarks';
  static const String tableAmolTracker = 'amol_tracker';

  // ─────────────────────────────────────────────
  // NOTIFICATIONS
  // ─────────────────────────────────────────────
  static const String notifChannelId = 'amalghor_prayer_channel';
  static const String notifChannelName = 'Prayer Times';
  static const String notifChannelDesc =
      'Notifications for prayer times, sehri, iftar';

  // ─────────────────────────────────────────────
  // CALCULATION DEFAULTS
  // ─────────────────────────────────────────────
  static const double defaultLatitude = 23.8103;
  static const double defaultLongitude = 90.4125;
  static const String defaultTimezone = 'Asia/Dhaka';
  static const String defaultLocationName = 'Dhaka, Bangladesh';

  // ─────────────────────────────────────────────
  // PDF
  // ─────────────────────────────────────────────
  static const String pdfFileNamePrefix = 'amalghor_prayer_calendar';
  static const double pdfPageMargin = 24.0;
  static const double pdfHeaderFontSize = 16.0;
  static const double pdfBodyFontSize = 8.0;
  static const double pdfHeaderRowFontSize = 9.0;
}
