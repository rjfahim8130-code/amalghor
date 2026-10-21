import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';

import '../services/bangla_date_service.dart';

@immutable
class CalendarMonth {
  final int year;       // Year of the primary calendar (e.g. 1448 for Hijri, 1433 for Bangla)
  final int month;      // 1..12
  final CalendarPrimaryDisplay primary;

  const CalendarMonth({
    required this.year,
    required this.month,
    required this.primary,
  });

  CalendarMonth copyWith({
    int? year,
    int? month,
    CalendarPrimaryDisplay? primary,
  }) {
    return CalendarMonth(
      year: year ?? this.year,
      month: month ?? this.month,
      primary: primary ?? this.primary,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarMonth &&
          other.year == year &&
          other.month == month &&
          other.primary == primary;

  @override
  int get hashCode => Object.hash(year, month, primary);
}

@immutable
class CalendarDay {
  final DateTime gregorian;
  final int banglaDay;
  final int hijriDay;
  final int hijriMonth;
  final bool isToday;

  const CalendarDay({
    required this.gregorian,
    required this.banglaDay,
    required this.hijriDay,
    required this.hijriMonth,
    required this.isToday,
  });
}

enum CalendarPrimaryDisplay { english, bangla, hijri }

class IslamicCalendarNotifier extends StateNotifier<CalendarMonth> {
  IslamicCalendarNotifier()
      : super(
          CalendarMonth(
            year: DateTime.now().year,
            month: DateTime.now().month,
            primary: CalendarPrimaryDisplay.english,
          ),
        );

  void nextMonth() {
    var m = state.month + 1;
    var y = state.year;

    if (m > 12) {
      m = 1;
      y += 1;
    }
    state = state.copyWith(month: m, year: y);
  }

  void previousMonth() {
    var m = state.month - 1;
    var y = state.year;

    if (m < 1) {
      m = 12;
      y -= 1;
    }
    state = state.copyWith(month: m, year: y);
  }

  void goToToday() {
    final now = DateTime.now();
    final primary = state.primary;
    
    if (primary == CalendarPrimaryDisplay.english) {
      state = state.copyWith(year: now.year, month: now.month);
    } else if (primary == CalendarPrimaryDisplay.hijri) {
      final h = HijriCalendar.fromDate(now);
      state = state.copyWith(year: h.hYear, month: h.hMonth);
    } else {
      final b = const BanglaDateService().convert(now);
      state = state.copyWith(year: b.year, month: b.monthIndex + 1);
    }
  }

  void setPrimary(CalendarPrimaryDisplay p) {
    final now = DateTime.now();
    if (p == CalendarPrimaryDisplay.english) {
      state = state.copyWith(primary: p, year: now.year, month: now.month);
    } else if (p == CalendarPrimaryDisplay.hijri) {
      final h = HijriCalendar.fromDate(now);
      state = state.copyWith(primary: p, year: h.hYear, month: h.hMonth);
    } else {
      final b = const BanglaDateService().convert(now);
      state = state.copyWith(primary: p, year: b.year, month: b.monthIndex + 1);
    }
  }
}

final islamicCalendarProvider =
    StateNotifierProvider<IslamicCalendarNotifier, CalendarMonth>((ref) {
  return IslamicCalendarNotifier();
});

final primaryDisplayProvider =
    StateNotifierProvider<PrimaryDisplayNotifier, CalendarPrimaryDisplay>(
  (ref) => PrimaryDisplayNotifier(),
);

class PrimaryDisplayNotifier extends StateNotifier<CalendarPrimaryDisplay> {
  PrimaryDisplayNotifier() : super(CalendarPrimaryDisplay.english);

  void set(CalendarPrimaryDisplay mode) => state = mode;
}

/// Builds the day grid for the currently selected calendar and month.
final calendarDaysProvider = Provider<List<CalendarDay>>((ref) {
  final month = ref.watch(islamicCalendarProvider);
  final bangla = const BanglaDateService();
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  // 1. Determine the Start and End date (Gregorian) for this calendar month.
  DateTime startDate;
  DateTime endDate;

  if (month.primary == CalendarPrimaryDisplay.english) {
    startDate = DateTime(month.year, month.month, 1);
    endDate = DateTime(month.year, month.month + 1, 0);
  } else if (month.primary == CalendarPrimaryDisplay.hijri) {
    // Approximate Hijri to Gregorian mapping (since exact conversion varies by moon)
    final hijri = HijriCalendar();
    hijri.hYear = month.year;
    hijri.hMonth = month.month;
    hijri.hDay = 1;
    startDate = hijri.hijriToGregorian(month.year, month.month, 1);
    
    // End date is one day before the start of next Hijri month
    final nextHijriMonth = month.month == 12 ? 1 : month.month + 1;
    final nextHijriYear = month.month == 12 ? month.year + 1 : month.year;
    final nextStart = hijri.hijriToGregorian(nextHijriYear, nextHijriMonth, 1);
    endDate = nextStart.subtract(const Duration(days: 1));
  } else {
    // Bangla: approximate Gregorian start for the month
    // Find the first day of the Bangla month by iterating from April 14 of that year
    final bnYear = month.year;
    final bnMonth = month.month - 1; // 0-based
    final leap = _isGregorianLeap(bnYear + 593);
    
    // April 14 of the Gregorian year corresponding to this Bangla year
    final newYear = DateTime(bnYear + 593, 4, 14);
    
    final monthLengths = <int>[
      31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 
      leap ? 30 : 29, leap ? 31 : 30
    ];
    
    int daysBefore = 0;
    for (int i = 0; i < bnMonth; i++) {
      daysBefore += monthLengths[i];
    }
    
    startDate = newYear.add(Duration(days: daysBefore));
    endDate = startDate.add(Duration(days: monthLengths[bnMonth] - 1));
  }

  // 2. Generate all days in between.
  final days = <CalendarDay>[];
  final totalDays = endDate.difference(startDate).inDays + 1;

  for (int i = 0; i < totalDays; i++) {
    final date = startDate.add(Duration(days: i));
    final bn = bangla.convert(date);
    final hn = HijriCalendar.fromDate(date);
    
    days.add(
      CalendarDay(
        gregorian: date,
        banglaDay: bn.day,
        hijriDay: hn.hDay,
        hijriMonth: hn.hMonth,
        isToday: date == todayDate,
      ),
    );
  }
  return days;
});

bool _isGregorianLeap(int year) {
  if (year % 400 == 0) return true;
  if (year % 100 == 0) return false;
  return year % 4 == 0;
}

/// Helper: number of leading blanks for the first day of the month.
int leadingBlanksFor(DateTime firstDay) => firstDay.weekday % 7;
