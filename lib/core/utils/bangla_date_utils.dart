import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class BanglaDateUtils {
  static const List<String> banglaMonths = [
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

  static const List<String> banglaWeekDays = [
    'সোমবার',
    'মঙ্গলবার',
    'বুধবার',
    'বৃহস্পতিবার',
    'শুক্রবার',
    'শনিবার',
    'রবিবার',
  ];

  static const List<String> banglaDigits = [
    '০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'
  ];

  /// Convert English number to Bangla digits
  static String toBanglaNumber(int number) {
    return number.toString().split('').map((d) {
      final idx = int.tryParse(d);
      return idx != null ? banglaDigits[idx] : d;
    }).join();
  }

  static String toBanglaNumberStr(String number) {
    return number.split('').map((d) {
      final idx = int.tryParse(d);
      return idx != null ? banglaDigits[idx] : d;
    }).join();
  }

  /// Approximate Bangla date from Gregorian (using common algorithm used in Bangladesh)
  /// This is a simplified but widely used conversion.
  static Map<String, dynamic> getBanglaDate(DateTime date) {
    // Bangla New Year roughly 14 April
    int banglaYear = date.year - 593;
    if (date.month < 4 || (date.month == 4 && date.day < 14)) {
      banglaYear -= 1;
    }

    // Approximate month calculation
    // This is a practical approximation used by many Bangladeshi apps
    final List<List<int>> monthStarts = [
      [4, 14], // Boishakh
      [5, 15], // Joishtho
      [6, 15], // Ashar
      [7, 16], // Srabon
      [8, 16], // Bhadro
      [9, 16], // Ashshin
      [10, 16], // Kartik
      [11, 15], // Ogrohayon
      [12, 15], // Poush
      [1, 14], // Magh
      [2, 13], // Falgun
      [3, 15], // Choitro
    ];

    int monthIndex = 0;
    int day = 1;

    for (int i = 0; i < 12; i++) {
      final startMonth = monthStarts[i][0];
      final startDay = monthStarts[i][1];

      DateTime startDate;
      if (startMonth >= 4) {
        startDate = DateTime(date.year, startMonth, startDay);
      } else {
        startDate = DateTime(date.year + 1, startMonth, startDay);
        if (date.isBefore(DateTime(date.year, 4, 14))) {
          startDate = DateTime(date.year, startMonth, startDay);
        }
      }

      DateTime nextStart;
      final nextI = (i + 1) % 12;
      final nextStartMonth = monthStarts[nextI][0];
      final nextStartDay = monthStarts[nextI][1];
      if (nextStartMonth >= 4) {
        nextStart = DateTime(date.year, nextStartMonth, nextStartDay);
        if (i >= 8) nextStart = DateTime(date.year + 1, nextStartMonth, nextStartDay);
      } else {
        nextStart = DateTime(date.year + 1, nextStartMonth, nextStartDay);
      }

      if (!date.isBefore(startDate) && date.isBefore(nextStart)) {
        monthIndex = i;
        day = date.difference(startDate).inDays + 1;
        break;
      }
    }

    return {
      'year': banglaYear,
      'month': monthIndex + 1,
      'monthName': banglaMonths[monthIndex],
      'day': day,
      'weekDay': banglaWeekDays[date.weekday - 1],
    };
  }

  static String formatBanglaDate(DateTime date, {bool full = true}) {
    final b = getBanglaDate(date);
    final day = toBanglaNumber(b['day']);
    final month = b['monthName'];
    final year = toBanglaNumber(b['year']);
    if (full) {
      return '$day $month $year';
    }
    return '$day $month';
  }

  static String formatHijriDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';
  }

  static String formatHijriShort(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return '${hijri.hDay} ${hijri.longMonthName}';
  }

  static String formatEnglishDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  static String formatTime(DateTime time, {bool isBangla = true}) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? (isBangla ? 'PM' : 'PM') : (isBangla ? 'AM' : 'AM');
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    if (isBangla) {
      return '${toBanglaNumber(h)}:${toBanglaNumberStr(minute)} $period';
    }
    return '$h:$minute $period';
  }

  static String formatDuration(Duration d, {bool isBangla = true}) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);

    final hs = h.toString().padLeft(2, '0');
    final ms = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');

    if (isBangla) {
      return '${toBanglaNumberStr(hs)}:${toBanglaNumberStr(ms)}:${toBanglaNumberStr(ss)}';
    }
    return '$hs:$ms:$ss';
  }
}
