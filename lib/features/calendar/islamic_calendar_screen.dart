import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../providers/islamic_calendar_provider.dart';
import '../../services/bangla_date_service.dart';
import '../../services/hijri_service.dart';

/// Islamic calendar view with three simultaneous calendars.
class IslamicCalendarScreen extends ConsumerWidget {
  const IslamicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final month = ref.watch(islamicCalendarProvider);
    final primary = ref.watch(primaryDisplayProvider);
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
          _PrimarySelector(current: primary),
          const _WeekdayHeader(),
          Expanded(
            child: _DayGrid(
              month: month,
              days: days,
              primary: primary,
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
    final hijri = const HijriService();

    final enLabel = DateFormat('MMMM y').format(month.firstDay);

    final bn1 = bangla.convert(month.firstDay).monthIndex;
    final bn2 = bangla.convert(month.lastDay).monthIndex;
    final bnLabel = bn1 == bn2
        ? bangla.monthName(bn1)
        : '${bangla.monthName(bn1)} — ${bangla.monthName(bn2)}';

    final h1 = hijri.monthOfYear(month.firstDay);
    final h2 = hijri.monthOfYear(month.lastDay);
    final hLabel = h1 == h2
        ? hijri.monthName(h1, 'bn')
        : '${hijri.monthName(h1, 'bn')} — ${hijri.monthName(h2, 'bn')}';

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
            child: Column(
              children: [
                Text(
                  enLabel,
                  style: TextStyle(
                    color: colors.emerald,
                    fontSize: AppConstants.fontHeading,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  bnLabel,
                  style: TextStyle(
                    color: colors.gold,
                    fontSize: AppConstants.fontCaption,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 1),
                Text(
                  hLabel,
                  style: TextStyle(
                    color: colors.cyan,
                    fontSize: AppConstants.fontCaption,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
// PRIMARY DISPLAY SELECTOR
// ─────────────────────────────────────────────

class _PrimarySelector extends ConsumerWidget {
  final CalendarPrimaryDisplay current;

  const _PrimarySelector({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(primaryDisplayProvider.notifier);
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
            onTap: () => notifier.set(CalendarPrimaryDisplay.english),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          _PrimaryChip(
            label: 'বাংলা',
            color: colors.gold,
            selected: current == CalendarPrimaryDisplay.bangla,
            onTap: () => notifier.set(CalendarPrimaryDisplay.bangla),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          _PrimaryChip(
            label: 'হিজরি',
            color: colors.cyan,
            selected: current == CalendarPrimaryDisplay.hijri,
            onTap: () => notifier.set(CalendarPrimaryDisplay.hijri),
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
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
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
  final CalendarMonth month;
  final List<CalendarDay> days;
  final CalendarPrimaryDisplay primary;

  const _DayGrid({
    required this.month,
    required this.days,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final leadingBlanks = month.leadingBlanks;
    final cells = <Widget>[];

    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (final d in days) {
      cells.add(_DayCell(day: d, primary: primary));
    }
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
    final en = day.gregorian.day;
    final bn = day.banglaDay;
    final hi = day.hijriDay;

    final isFriday = day.gregorian.weekday == DateTime.friday;
    final isToday = day.isToday;

    late final int primaryValue;
    late final int sec1Value;
    late final int sec2Value;
    late final Color primaryColor;

    switch (primary) {
      case CalendarPrimaryDisplay.english:
        primaryValue = en;
        sec1Value = bn;
        sec2Value = hi;
        primaryColor = colors.emerald;
        break;
      case CalendarPrimaryDisplay.bangla:
        primaryValue = bn;
        sec1Value = en;
        sec2Value = hi;
        primaryColor = colors.gold;
        break;
      case CalendarPrimaryDisplay.hijri:
        primaryValue = hi;
        sec1Value = en;
        sec2Value = bn;
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
                    fontFeatures: const [FontFeature.tabularFigures()],
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
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
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
