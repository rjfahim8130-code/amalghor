import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../data/models/prayer_times.dart';

/// Compact summary of the day's key prayer times.
///
/// Each row shows the **actual** time (large) followed by the
/// **safety** time (small, muted) where applicable.
class QuickSummaryCard extends StatelessWidget {
  final PrayerTimes prayer;

  const QuickSummaryCard({super.key, required this.prayer});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final current = prayer.currentPrayer(now);
    final next = prayer.nextPrayer(now);

    final rows = <_SummaryRow>[
      _SummaryRow(
        key: 'sehri',
        label: 'সেহরি',
        primary: prayer.sehriActual,
        secondary: prayer.sehriSafety,
        secondaryLabel: 'সতর্ক',
        icon: Icons.alarm,
      ),
      _SummaryRow(
        key: 'fajr',
        label: 'ফজর',
        primary: prayer.fajr,
        icon: Icons.mosque,
      ),
      _SummaryRow(
        key: 'sunrise',
        label: 'সূর্যোদয়',
        primary: prayer.sunrise,
        icon: Icons.wb_twilight,
      ),
      _SummaryRow(
        key: 'ishraq',
        label: 'ইশরাক',
        primary: prayer.ishraq,
        icon: Icons.wb_sunny_outlined,
      ),
      _SummaryRow(
        key: 'dhuhr',
        label: 'যোহর',
        primary: prayer.dhuhr,
        icon: Icons.mosque,
      ),
      _SummaryRow(
        key: 'asr',
        label: 'আসর',
        primary: prayer.asr,
        icon: Icons.mosque,
      ),
      _SummaryRow(
        key: 'iftar',
        label: 'ইফতার',
        primary: prayer.iftarActual,
        secondary: prayer.iftarSafety,
        secondaryLabel: 'সতর্ক',
        icon: Icons.restaurant,
      ),
      _SummaryRow(
        key: 'maghrib',
        label: 'মাগরিব',
        primary: prayer.maghrib,
        icon: Icons.mosque,
      ),
      _SummaryRow(
        key: 'isha',
        label: 'এশা',
        primary: prayer.isha,
        icon: Icons.mosque,
      ),
      _SummaryRow(
        key: 'ishaMustahab',
        label: 'মুস্তাহাব এশা',
        primary: prayer.ishaMustahab,
        icon: Icons.star_outline,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.spaceSm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppConstants.emeraldPrimary,
                  size: 18,
                ),
                SizedBox(width: AppConstants.spaceSm),
                Text(
                  'আজকের সময়সূচি',
                  style: TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: AppConstants.fontSubtitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...rows.map(
            (r) => _SummaryTile(
              row: r,
              isCurrent: current?.key == r.key,
              isNext: next.key == r.key,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow {
  final String key;
  final String label;
  final DateTime primary;
  final DateTime? secondary;
  final String? secondaryLabel;
  final IconData icon;

  const _SummaryRow({
    required this.key,
    required this.label,
    required this.primary,
    this.secondary,
    this.secondaryLabel,
    required this.icon,
  });
}

class _SummaryTile extends StatelessWidget {
  final _SummaryRow row;
  final bool isCurrent;
  final bool isNext;

  const _SummaryTile({
    required this.row,
    required this.isCurrent,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isCurrent
        ? AppConstants.emeraldPrimary
        : (isNext ? AppConstants.goldAccent : AppConstants.textMuted);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceMd,
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(row.icon, color: accent, size: 16),
          ),
          const SizedBox(width: AppConstants.spaceMd),

          // Label
          Expanded(
            child: Text(
              row.label,
              style: TextStyle(
                color: isCurrent || isNext
                    ? AppConstants.textPrimary
                    : AppConstants.textMuted,
                fontSize: AppConstants.fontBody,
                fontWeight: isCurrent || isNext
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),

          // Indicator dot
          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(right: AppConstants.spaceSm),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppConstants.emeraldPrimary,
                shape: BoxShape.circle,
              ),
            )
          else if (isNext)
            Container(
              margin: const EdgeInsets.only(right: AppConstants.spaceSm),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppConstants.goldAccent.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),

          // Actual time (large) — always the primary
          Text(
            AppDateUtils.formatTimeShort(row.primary),
            style: TextStyle(
              color: isCurrent
                  ? AppConstants.emeraldPrimary
                  : AppConstants.textPrimary,
              fontSize: AppConstants.fontSubtitle,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          // Safety time (small, muted) below — optional
          if (row.secondary != null) ...[
            const SizedBox(width: AppConstants.spaceSm),
            Text(
              '${row.secondaryLabel ?? ''} '
              '${AppDateUtils.formatTimeShort(row.secondary!)}',
              style: const TextStyle(
                color: AppConstants.textFaint,
                fontSize: AppConstants.fontMicro,
                fontWeight: FontWeight.w400,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
