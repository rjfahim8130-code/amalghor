import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../providers/islamic_calendar_provider.dart';
import '../../services/bangla_date_service.dart';

class IslamicCalendarScreen extends ConsumerWidget {
  const IslamicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final month = ref.watch(islamicCalendarProvider);
    final days = ref.watch(calendarDaysProvider);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Text(
          'ইসলামিক ক্যালেন্ডার',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'আজকে যান',
            icon: Icon(Icons.today, color: colors.textPrimary),
            onPressed: () =>
                ref.read(islamicCalendarProvider.notifier).goToToday(),
          ),
        ],
      ),
      body: Column(
        children: [
          _MonthHeader(month: month),
          _PrimarySelector(current: month.primary),
          _WeekdayHeader(firstDay: days.first.gregorian),
          Expanded(
            child: _DayGrid(
              firstDay: days.first.gregorian,
              days: days,
              primary: month.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MONTH HEADER
// ─────────────────────────────────────────────

class _MonthHeader extends ConsumerWidget {
  final CalendarMonth month;

  const _MonthHeader({required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final notifier = ref.read(islamicCalendarProvider.notifier);
    final bangla = const BanglaDateService();

    // We display the currently selected calendar as the main title.
    String mainTitle;
    Color mainColor;
    
    if (month.primary == CalendarPrimaryDisplay.english) {
      mainTitle = DateFormat('MMMM y').format(DateTime(month.year, month.month));
      mainColor = colors.emerald;
    } else if (month.primary == CalendarPrimaryDisplay.hijri) {
      final hijri = HijriCalendar();
      hijri.hYear = month.year;
      hijri.hMonth = month.month;
      // Get name for the month
      mainTitle = '${hijri.longMonthName} ${month.year} هـ';
      mainColor = colors.cyan;
    } else {
      // Bangla
      mainTitle = '${bangla.monthName(month.month - 1)} ${month.year}';
      mainColor = colors.gold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceMd,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.divider, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: colors.textPrimary),
            onPressed: notifier.previousMonth,
          ),
          Expanded(
            child: Text(
              mainTitle,
              style: TextStyle(
                color: mainColor,
                fontSize: AppConstants.fontHeading,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: colors.textPrimary),
            onPressed: notifier.nextMonth,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRIMARY SELECTOR
// ─────────────────────────────────────────────

class _PrimarySelector extends ConsumerWidget {
  final CalendarPrimaryDisplay current;

  const _PrimarySelector({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(islamicCalendarProvider.notifier);
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceSm,
      ),
      child: Row(
        children: [
          _PrimaryChip(
            label: 'ইংরেজি',
            color: colors.emerald,
            selected: current == CalendarPrimaryDisplay.english,
            onTap: () => notifier.setPrimary(CalendarPrimaryDisplay.english),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          _PrimaryChip(
            label: 'বাংলা',
            color: colors.gold,
            selected: current == CalendarPrimaryDisplay.bangla,
            onTap: () => notifier.setPrimary(CalendarPrimaryDisplay.bangla),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          _PrimaryChip(
            label: 'হিজরি',
            color: colors.cyan,
            selected: current == CalendarPrimaryDisplay.hijri,
            onTap: () => notifier.setPrimary(CalendarPrimaryDisplay.hijri),
          ),
        ],
      ),
    );
  }
}

class _PrimaryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PrimaryChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.15)
                  : colors.cardBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              border: Border.all(
                color: selected ? color : colors.border,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? color : colors.textMuted,
                fontSize: AppConstants.fontCaption,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WEEKDAY HEADER
// ─────────────────────────────────────────────

class _WeekdayHeader extends StatelessWidget {
  final DateTime firstDay;
  const _WeekdayHeader({required this.firstDay});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // Adjust names to start from Sunday (0)
    const days = ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি'];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      child: Row(
        children: days
            .map(
              (d) => Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: AppConstants.fontMicro,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DAY GRID
// ─────────────────────────────────────────────

class _DayGrid extends StatelessWidget {
  final DateTime firstDay;
  final List<CalendarDay> days;
  final CalendarPrimaryDisplay primary;

  const _DayGrid({
    required this.firstDay,
    required this.days,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    // Blank cells for days before the first of the month.
    final leadingBlanks = firstDay.weekday % 7;
    final cells = <Widget>[];

    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (final d in days) {
      cells.add(_DayCell(day: d, primary: primary));
    }
    // Fill the last row
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }

    final rows = <TableRow>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(
        TableRow(
          children: cells.sublist(i, i + 7).map<Widget>((w) {
            return Padding(
              padding: const EdgeInsets.all(2),
              child: w,
            );
          }).toList(),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows,
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final CalendarDay day;
  final CalendarPrimaryDisplay primary;

  const _DayCell({
    required this.day,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    // Friday check
    final isFriday = day.gregorian.weekday == DateTime.friday;
    final isToday = day.isToday;

    // Determine which number is big and which is small
    late final int primaryValue;
    late final int sec1Value;
    late final int sec2Value;
    late final Color primaryColor;

    switch (primary) {
      case CalendarPrimaryDisplay.english:
        primaryValue = day.gregorian.day;
        sec1Value = day.banglaDay;
        sec2Value = day.hijriDay;
        primaryColor = colors.emerald;
        break;
      case CalendarPrimaryDisplay.bangla:
        primaryValue = day.banglaDay;
        sec1Value = day.gregorian.day;
        sec2Value = day.hijriDay;
        primaryColor = colors.gold;
        break;
      case CalendarPrimaryDisplay.hijri:
        primaryValue = day.hijriDay;
        sec1Value = day.gregorian.day;
        sec2Value = day.banglaDay;
        primaryColor = colors.cyan;
        break;
    }

    return AspectRatio(
      aspectRatio: 0.85,
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? colors.emerald.withValues(alpha: 0.15)
              : colors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: isToday
                ? colors.emerald
                : (isFriday
                    ? colors.gold.withValues(alpha: 0.4)
                    : colors.border),
            width: isToday ? 1.6 : 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Primary (Big) Number
            Text(
              '$primaryValue',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 3),
            
            // Secondary (Small) Numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$sec1Value',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    color: colors.textFaint,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$sec2Value',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            
            // Friday Dot
            if (isFriday) ...[
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.gold,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
