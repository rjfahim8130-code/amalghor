import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';

import '../services/bangla_date_service.dart';

/// Which month is currently visible in the calendar.
@immutable
class CalendarMonth {
  final int year;
  final int month; // 1..12 (Gregorian)

  const CalendarMonth({required this.year, required this.month});

  CalendarMonth copyWith({int? year, int? month}) {
    return CalendarMonth(
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }

  DateTime get firstDay => DateTime(year, month, 1);
  DateTime get lastDay => DateTime(year, month + 1, 0);
  int get daysInMonth => lastDay.day;
  int get leadingBlanks => firstDay.weekday % 7; // 0=Sun

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarMonth &&
          other.year == year &&
          other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

/// A single day cell in the calendar grid.
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

/// Which calendar is the "primary" (large) label in each cell.
enum CalendarPrimaryDisplay {
  english,
  bangla,
  hijri,
}

/// Notifier that tracks the visible month + primary display mode.
class IslamicCalendarNotifier extends StateNotifier<CalendarMonth> {
  IslamicCalendarNotifier()
      : super(
          CalendarMonth(
            year: DateTime.now().year,
            month: DateTime.now().month,
          ),
        );

  void nextMonth() {
    final m = state.month + 1;
    if (m > 12) {
      state = CalendarMonth(year: state.year + 1, month: 1);
    } else {
      state = state.copyWith(month: m);
    }
  }

  void previousMonth() {
    final m = state.month - 1;
    if (m < 1) {
      state = CalendarMonth(year: state.year - 1, month: 12);
    } else {
      state = state.copyWith(month: m);
    }
  }

  void goToToday() {
    final now = DateTime.now();
    state = CalendarMonth(year: now.year, month: now.month);
  }

  void setMonth(int year, int month) {
    state = CalendarMonth(year: year, month: month);
  }
}

final islamicCalendarProvider =
    StateNotifierProvider<IslamicCalendarNotifier, CalendarMonth>((ref) {
  return IslamicCalendarNotifier();
});

/// Primary display mode for cells.
class PrimaryDisplayNotifier extends StateNotifier<CalendarPrimaryDisplay> {
  PrimaryDisplayNotifier() : super(CalendarPrimaryDisplay.english);

  void set(CalendarPrimaryDisplay mode) => state = mode;
}

final primaryDisplayProvider =
    StateNotifierProvider<PrimaryDisplayNotifier, CalendarPrimaryDisplay>(
  (ref) => PrimaryDisplayNotifier(),
);

/// Computes the day grid for the current month.
final calendarDaysProvider = Provider<List<CalendarDay>>((ref) {
  final month = ref.watch(islamicCalendarProvider);
  final bangla = const BanglaDateService();
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  final days = <CalendarDay>[];
  for (int d = 1; d <= month.daysInMonth; d++) {
    final date = DateTime(month.year, month.month, d);
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
