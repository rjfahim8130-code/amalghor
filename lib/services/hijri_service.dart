import 'package:hijri/hijri_calendar.dart';

/// Service wrapping the `hijri` package for Gregorian ↔ Hijri
/// conversion, with multi-locale month names and Ramadan helpers.
class HijriService {
  const HijriService();

  HijriCalendar toHijri(DateTime date) => HijriCalendar.fromDate(date);

  int dayOfMonth(DateTime date) => toHijri(date).hDay;

  int monthOfYear(DateTime date) => toHijri(date).hMonth;

  int year(DateTime date) => toHijri(date).hYear;

  String format(DateTime date, String localeCode) {
    final h = toHijri(date);
    final month = monthName(h.hMonth, localeCode);
    return '${h.hDay} $month ${h.hYear}';
  }

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

  bool isRamadan(DateTime date) => monthOfYear(date) == 9;

  int? ramadanDay(DateTime date) {
    final h = toHijri(date);
    return h.hMonth == 9 ? h.hDay : null;
  }

  int? daysUntilRamadan(DateTime from) {
    final start = DateTime(from.year, from.month, from.day);
    for (int i = 0; i < 400; i++) {
      final candidate = start.add(Duration(days: i));
      final h = toHijri(candidate);
      if (h.hMonth == 9 && h.hDay == 1) return i;
    }
    return null;
  }

  static const double averageHijriYearDays = 10631 / 30;

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
