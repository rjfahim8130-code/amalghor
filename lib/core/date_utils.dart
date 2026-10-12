import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';

/// Result of a tri-calendar conversion:
/// Gregorian + Bangla + Hijri dates together.
class TriCalendarDate {
  final DateTime gregorian;
  final String gregorianFormatted;
  final String banglaFormatted;
  final String hijriFormatted;
  final int hijriDay;
  final String hijriMonthName;
  final int hijriYear;
  final int banglaDay;
  final String banglaMonthName;
  final int banglaYear;

  const TriCalendarDate({
    required this.gregorian,
    required this.gregorianFormatted,
    required this.banglaFormatted,
    required this.hijriFormatted,
    required this.hijriDay,
    required this.hijriMonthName,
    required this.hijriYear,
    required this.banglaDay,
    required this.banglaMonthName,
    required this.banglaYear,
  });
}

/// Central date utility.
///
/// Provides:
/// - Gregorian ↔ Bangla ↔ Hijri conversion
/// - Locale-aware formatting
/// - Islamic astronomical night-time helpers
class AppDateUtils {
  AppDateUtils._();

  // ─────────────────────────────────────────────
  // BANGLA CALENDAR DATA
  // ─────────────────────────────────────────────
  static const List<String> _banglaMonths = [
    'বৈশাখ',
    'জ্যৈষ্ঠ',
    'আষাঢ়',
    'শ্রাবণ',
    'ভাদ্র',
    'আশ্বিন',
    'কার্তিক',
    'অগ্রহায়ণ',
    'পৌষ',
    'মাঘ',
    'ফাল্গুন',
    'চৈত্র',
  ];

  // ─────────────────────────────────────────────
  // HIJRI MONTH NAMES
  // ─────────────────────────────────────────────
  static const List<String> _hijriMonthsEn = [
    'Muharram',
    'Safar',
    "Rabi' al-Awwal",
    "Rabi' al-Thani",
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhu al-Qi'dah",
    'Dhu al-Hijjah',
  ];

  static const List<String> _hijriMonthsAr = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الثانية',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static const List<String> _hijriMonthsBn = [
    'মুহাররম',
    'সফর',
    'রবিউল আউয়াল',
    'রবিউস সানি',
    'জুমাদাল উলা',
    'জুমাদাস সানি',
    'রজব',
    'শাবান',
    'রমজান',
    'শাওয়াল',
    'জিলকদ',
    'জিলহজ',
  ];

  // ─────────────────────────────────────────────
  // GREGORIAN FORMATTING
  // ─────────────────────────────────────────────
  static String formatGregorian(DateTime date, String localeCode) {
    switch (localeCode) {
      case 'bn':
        return DateFormat('d MMMM y', 'bn').format(date);
      case 'ar':
        return DateFormat('d MMMM y', 'ar').format(date);
      default:
        return DateFormat('d MMM y').format(date);
    }
  }

  static String formatTime(DateTime date, String localeCode) {
    final timeStr = DateFormat('hh:mm').format(date);
    if (localeCode == 'bn') {
      final bnPeriod = date.hour < 12 ? 'পূর্বাহ্ন' : 'অপরাহ্ন';
      return '$timeStr $bnPeriod';
    }
    if (localeCode == 'ar') {
      final arPeriod = date.hour < 12 ? 'ص' : 'م';
      return '$timeStr $arPeriod';
    }
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$timeStr $period';
  }

  static String formatTimeShort(DateTime date) {
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')} $period';
  }

  static String formatClock(DateTime date) {
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')} $period';
  }

  static String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  // ─────────────────────────────────────────────
  // BANGLA CALENDAR CONVERSION
  // ─────────────────────────────────────────────
  /// Convert Gregorian to Bangla (Bangladesh revised 2019+ calendar).
  static ({int day, int monthIndex, int year}) gregorianToBangla(DateTime g) {
    const banglaNewYearMonth = 4;
    const banglaNewYearDay = 14;

    int banglaYear = g.year - 593;
    DateTime newYearThisYear =
        DateTime(g.year, banglaNewYearMonth, banglaNewYearDay);

    if (g.isBefore(newYearThisYear)) {
      banglaYear -= 1;
      newYearThisYear =
          DateTime(g.year - 1, banglaNewYearMonth, banglaNewYearDay);
    }

    final daysSinceNewYear = g.difference(newYearThisYear).inDays;
    final isLeap = _isGregorianLeap(g.year);

    final monthLengths = <int>[
      31, 31, 31, 31, 31, // Boishakh–Bhadro
      30, 30, 30, 30, 30, // Ashwin–Magh
      30, // Falgun placeholder
      30, // Choitro placeholder
    ];
    monthLengths[10] = isLeap ? 30 : 29;
    final totalOther = monthLengths.take(11).reduce((a, b) => a + b);
    monthLengths[11] = (isLeap ? 366 : 365) - totalOther;

    int remaining = daysSinceNewYear;
    int monthIndex = 0;
    while (monthIndex < 12 && remaining >= monthLengths[monthIndex]) {
      remaining -= monthLengths[monthIndex];
      monthIndex++;
    }

    return (
      day: remaining + 1,
      monthIndex: monthIndex.clamp(0, 11),
      year: banglaYear,
    );
  }

  static bool _isGregorianLeap(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }

  static String getBanglaMonthName(int monthIndex) {
    return _banglaMonths[monthIndex.clamp(0, 11)];
  }

  // ─────────────────────────────────────────────
  // HIJRI CONVERSION
  // ─────────────────────────────────────────────
  static HijriCalendar gregorianToHijri(DateTime g) {
    return HijriCalendar.fromDate(g);
  }

  static String getHijriMonthName(int monthIndex, String localeCode) {
    final idx = (monthIndex - 1).clamp(0, 11);
    switch (localeCode) {
      case 'bn':
        return _hijriMonthsBn[idx];
      case 'ar':
        return _hijriMonthsAr[idx];
      default:
        return _hijriMonthsEn[idx];
    }
  }

  // ─── Part 2 continues in next fragment ───
    // ─────────────────────────────────────────────
  // TRI-CALENDAR AGGREGATOR
  // ─────────────────────────────────────────────
  /// Build a [TriCalendarDate] combining all three calendars.
  static TriCalendarDate buildTriCalendar(DateTime date, String localeCode) {
    final gregFormatted = formatGregorian(date, localeCode);

    final bn = gregorianToBangla(date);
    final bnFormatted = '${_toBanglaDigits(bn.day)} '
        '${getBanglaMonthName(bn.monthIndex)} '
        '${_toBanglaDigits(bn.year)}';

    final hijri = gregorianToHijri(date);
    final hijriMonthName = getHijriMonthName(hijri.month, localeCode);
    final hijriFormatted = '${hijri.hDay} $hijriMonthName ${hijri.hYear}';

    return TriCalendarDate(
      gregorian: date,
      gregorianFormatted: gregFormatted,
      banglaFormatted: bnFormatted,
      hijriFormatted: hijriFormatted,
      hijriDay: hijri.hDay,
      hijriMonthName: hijriMonthName,
      hijriYear: hijri.hYear,
      banglaDay: bn.day,
      banglaMonthName: getBanglaMonthName(bn.monthIndex),
      banglaYear: bn.year,
    );
  }

  /// Convert English digits to Bangla digits.
  static String _toBanglaDigits(int number) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final s = number.toString();
    final buffer = StringBuffer();
    for (final ch in s.split('')) {
      final idx = en.indexOf(ch);
      buffer.write(idx >= 0 ? bn[idx] : ch);
    }
    return buffer.toString();
  }

  // ─────────────────────────────────────────────
  // ISLAMIC ASTRONOMICAL HELPERS
  // ─────────────────────────────────────────────
  static DateTime islamicMidnight(DateTime maghrib, DateTime nextFajr) {
    final night = nextFajr.difference(maghrib);
    return maghrib.add(Duration(milliseconds: night.inMilliseconds ~/ 2));
  }

  static DateTime lastThirdOfNight(DateTime maghrib, DateTime nextFajr) {
    final night = nextFajr.difference(maghrib);
    return maghrib.add(
      Duration(milliseconds: (night.inMilliseconds * 2) ~/ 3),
    );
  }

  static DateTime firstThirdOfNight(DateTime maghrib, DateTime nextFajr) {
    final night = nextFajr.difference(maghrib);
    return maghrib.add(Duration(milliseconds: night.inMilliseconds ~/ 3));
  }

  // ─────────────────────────────────────────────
  // HIJRI / RAMADAN SPECIFIC
  // ─────────────────────────────────────────────
  static bool isRamadan(DateTime date) {
    final hijri = gregorianToHijri(date);
    return hijri.month == 9;
  }

  static int? ramadanDay(DateTime date) {
    final hijri = gregorianToHijri(date);
    return hijri.month == 9 ? hijri.hDay : null;
  }

  static int? daysUntilRamadan(DateTime from) {
    for (int i = 0; i < 400; i++) {
      final candidate = from.add(Duration(days: i));
      final h = gregorianToHijri(candidate);
      if (h.month == 9 && h.hDay == 1) return i;
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // LOCALIZED LABEL HELPERS
  // ─────────────────────────────────────────────
  static String localizedDateLine(BuildContext context, DateTime date) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final tri = buildTriCalendar(date, localeCode);
    return '${tri.gregorianFormatted} • '
        '${tri.banglaFormatted} • '
        '${tri.hijriFormatted}';
  }

  static String localizedToday(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return l10n.today;
    if (diff == -1) return l10n.yesterday;
    if (diff == 1) return l10n.tomorrow;
    final localeCode = Localizations.localeOf(context).languageCode;
    return buildTriCalendar(date, localeCode).gregorianFormatted;
  }
}
