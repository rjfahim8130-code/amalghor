import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../providers/islamic_calendar_provider.dart';
import '../../services/bangla_date_service.dart';
import '../../services/hijri_service.dart';

/// Islamic calendar view with three simultaneous calendars.
class IslamicCalendarScreen extends ConsumerWidget {
  const IslamicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(islamicCalendarProvider);
    final primary = ref.watch(primaryDisplayProvider);
    final days = ref.watch(calendarDaysProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ইসলামিক ক্যালেন্ডার'),
        actions: [
          IconButton(
            tooltip: 'আজকে যান',
            icon: const Icon(Icons.today),
            onPressed: () =>
                ref.read(islamicCalendarProvider.notifier).goToToday(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Month header ────────────────────
          _MonthHeader(month: month),

          // ─── Primary display selector ────────
          _PrimarySelector(current: primary),

          // ─── Weekday header row ──────────────
          const _WeekdayHeader(),

          // ─── Day grid ────────────────────────
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
    final notifier = ref.read(islamicCalendarProvider.notifier);
    final bangla = const BanglaDateService();
    final hijri = const HijriService();

    // English month range.
    final enLabel = DateFormat('MMMM y').format(month.firstDay);

    // Bangla months — might span two.
    final bn1 = bangla.convert(month.firstDay).monthIndex;
    final bn2 = bangla.convert(month.lastDay).monthIndex;
    final bnLabel =
        bn1 == bn2 ? bangla.monthName(bn1) : '${bangla.monthName(bn1)} — ${bangla.monthName(bn2)}';

    // Hijri months — might span two.
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
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppConstants.dividerColor, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: notifier.previousMonth,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  enLabel,
                  style: const TextStyle(
                    color: AppConstants.emeraldPrimary,
                    fontSize: AppConstants.fontHeading,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  bnLabel,
                  style: const TextStyle(
                    color: AppConstants.goldAccent,
                    fontSize: AppConstants.fontCaption,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 1),
                Text(
                  hLabel,
                  style: const TextStyle(
                    color: Color(0xFF0EA5E9),
                    fontSize: AppConstants.fontCaption,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceSm,
      ),
      child: Row(
        children: [
          _PrimaryChip(
            label: 'ইংরেজি',
            color: AppConstants.emeraldPrimary,
            selected: current == CalendarPrimaryDisplay.english,
            onTap: () => notifier.set(CalendarPrimaryDisplay.english),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          _PrimaryChip(
            label: 'বাংলা',
            color: AppConstants.goldAccent,
            selected: current == CalendarPrimaryDisplay.bangla,
            onTap: () => notifier.set(CalendarPrimaryDisplay.bangla),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          _PrimaryChip(
            label: 'হিজরি',
            color: const Color(0xFF0EA5E9),
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
                  ? color.withValues(alpha: 0.20)
                  : AppConstants.surfaceDarker,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              border: Border.all(
                color: selected ? color : AppConstants.dividerColor,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? color : AppConstants.textMuted,
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
                  style: const TextStyle(
                    color: AppConstants.textMuted,
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
    // Build a single flat list of "cells" — leading blanks + day cells.
    final leadingBlanks = month.leadingBlanks;
    final cells = <Widget>[];

    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (final d in days) {
      cells.add(_DayCell(day: d, primary: primary));
    }

    // Pad the end so the grid always fills rows of 7.
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

// ─────────────────────────────────────────────
// DAY CELL
// ─────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final CalendarDay day;
  final CalendarPrimaryDisplay primary;

  const _DayCell({
    required this.day,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which numbers to show as primary & secondary.
    // Primary is large; secondaries are small below.
    final en = day.gregorian.day;
    final bn = day.banglaDay;
    final hi = day.hijriDay;

    final isFriday = day.gregorian.weekday == DateTime.friday;
    final isToday = day.isToday;

    // Determine primary / secondary values based on the mode.
    late final int primaryValue;
    late final String primaryLabel;
    late final int sec1Value;
    late final int sec2Value;
    late final Color primaryColor;

    switch (primary) {
      case CalendarPrimaryDisplay.english:
        primaryValue = en;
        primaryLabel = 'EN';
        sec1Value = bn;
        sec2Value = hi;
        primaryColor = AppConstants.emeraldPrimary;
        break;
      case CalendarPrimaryDisplay.bangla:
        primaryValue = bn;
        primaryLabel = 'BN';
        sec1Value = en;
        sec2Value = hi;
        primaryColor = AppConstants.goldAccent;
        break;
      case CalendarPrimaryDisplay.hijri:
        primaryValue = hi;
        primaryLabel = 'HI';
        sec1Value = en;
        sec2Value = bn;
        primaryColor = const Color(0xFF0EA5E9);
        break;
    }

    return AspectRatio(
      aspectRatio: 0.85,
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? AppConstants.emeraldPrimary.withValues(alpha: 0.15)
              : AppConstants.surfaceDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: isToday
                ? AppConstants.emeraldPrimary
                : (isFriday
                    ? AppConstants.goldAccent.withValues(alpha: 0.4)
                    : AppConstants.dividerColor),
            width: isToday ? 1.6 : 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Primary number
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

            // Secondary row (two small numbers)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$sec1Value',
                  style: const TextStyle(
                    color: AppConstants.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 2,
                  height: 2,
                  decoration: const BoxDecoration(
                    color: AppConstants.textFaint,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$sec2Value',
                  style: const TextStyle(
                    color: AppConstants.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),

            // Friday marker
            if (isFriday) ...[
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppConstants.goldAccent,
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
