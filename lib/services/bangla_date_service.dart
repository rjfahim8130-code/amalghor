/// Service for converting Gregorian dates to the Bangladeshi
/// revised Bangla calendar (2019 reform).
///
/// Months and lengths:
///   Boishakh–Bhadro  : 31 days each (5 × 31 = 155)
///   Ashwin–Magh      : 30 days each (5 × 30 = 150)
///   Falgun           : 29 days (30 in Gregorian leap years)
///   Choitro          : 30 days (31 in Gregorian leap years)
///
/// The Bangla year always begins on 14 April (Gregorian).
class BanglaDateService {
  const BanglaDateService();

  static const List<String> _months = [
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

  static const List<String> _monthsEn = [
    'Boishakh',
    'Joishtho',
    'Asharh',
    'Srabon',
    'Bhadro',
    'Ashwin',
    'Kartik',
    'Ogrohayon',
    'Poush',
    'Magh',
    'Falgun',
    'Choitro',
  ];

  /// Convert a Gregorian date to Bangla calendar components.
  ({int day, int monthIndex, int year}) convert(DateTime g) {
    const newYearMonth = 4; // April
    const newYearDay = 14;

    int banglaYear = g.year - 593;
    DateTime newYear = DateTime(g.year, newYearMonth, newYearDay);

    if (g.isBefore(newYear)) {
      banglaYear -= 1;
      newYear = DateTime(g.year - 1, newYearMonth, newYearDay);
    }

    final daysSince = g.difference(newYear).inDays;
    final leap = _isGregorianLeap(g.year);

    final monthLengths = <int>[
      31, 31, 31, 31, 31, // Boishakh–Bhadro
      30, 30, 30, 30, 30, // Ashwin–Magh
      leap ? 30 : 29,     // Falgun
      leap ? 31 : 30,     // Choitro
    ];

    int remaining = daysSince;
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

  /// Bangla month name for a 0-based month index.
  String monthName(int monthIndex) => _months[monthIndex.clamp(0, 11)];

  /// English transliteration of the Bangla month name.
  String monthNameEn(int monthIndex) => _monthsEn[monthIndex.clamp(0, 11)];

  /// Fully-formatted Bangla date, e.g. "১৪ বৈশাখ ১৪৩০".
  String format(DateTime date) {
    final c = convert(date);
    return '${toBanglaDigits(c.day)} ${monthName(c.monthIndex)} '
        '${toBanglaDigits(c.year)}';
  }

  /// Fully-formatted Bangla date in English transliteration.
  String formatEn(DateTime date) {
    final c = convert(date);
    return '${c.day} ${monthNameEn(c.monthIndex)} ${c.year}';
  }

  /// Convert western digits in a number to Bangla digits.
  String toBanglaDigits(int number) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final buffer = StringBuffer();
    for (final ch in number.toString().split('')) {
      final idx = en.indexOf(ch);
      buffer.write(idx >= 0 ? bn[idx] : ch);
    }
    return buffer.toString();
  }

  bool _isGregorianLeap(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }
}
