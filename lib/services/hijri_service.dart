import 'package:hijri/hijri_calendar.dart';

/// Service wrapping the `hijri` package for Gregorian ↔ Hijri
/// conversion, with multi-locale month names and Ramadan helpers.
class HijriService {
  const HijriService();

  /// Convert a Gregorian date to a Hijri calendar record.
  HijriCalendar toHijri(DateTime date) => HijriCalendar.fromDate(date);

  /// Get the Hijri day-of-month (1–30).
  int dayOfMonth(DateTime date) => toHijri(date).hDay;

  /// Get the Hijri month number (1–12).
  int monthOfYear(DateTime date) => toHijri(date).month;

  /// Get the Hijri year.
  int year(DateTime date) => toHijri(date).hYear;

  /// Formatted Hijri date string for the given locale code.
  String format(DateTime date, String localeCode) {
    final h = toHijri(date);
    final month = monthName(h.month, localeCode);
    return '${h.hDay} $month ${h.hYear}';
  }

  /// Localized Hijri month name.
  String monthName(int monthIndex, String localeCode) {
    final idx = (monthIndex - 1).clamp(0, 11);
    switch (localeCode) {
      case 'bn':
        return _monthsBn[idx];
      case 'ar':
        return _monthsAr[idx];
      default:
        return _monthsEn[idx];
    }
  }

  /// True if the given date is inside the month of Ramadan.
  bool isRamadan(DateTime date) => monthOfYear(date) == 9;

  /// Ramadan day number (1–30) or null if not in Ramadan.
  int? ramadanDay(DateTime date) {
    final h = toHijri(date);
    return h.month == 9 ? h.hDay : null;
  }

  /// Number of days from [from] until the next 1 Ramadan.
  /// Returns null if not found within 400 days.
  int? daysUntilRamadan(DateTime from) {
    final start = DateTime(from.year, from.month, from.day);
    for (int i = 0; i < 400; i++) {
      final candidate = start.add(Duration(days: i));
      final h = toHijri(candidate);
      if (h.month == 9 && h.hDay == 1) return i;
    }
    return null;
  }

  /// Approximate Hijri year length in days (used for PDF clustering).
  /// Uses the tabular Islamic calendar's 30-year cycle = 10631 days.
  static const double averageHijriYearDays = 10631 / 30; // ≈ 354.367

  // ─────────────────────────────────────────────
  // MONTH NAME TABLES
  // ─────────────────────────────────────────────
  static const List<String> _monthsEn = [
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

  static const List<String> _monthsAr = [
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

  static const List<String> _monthsBn = [
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
}
