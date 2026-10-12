import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../data/models/prayer_times.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/clock_provider.dart';

/// Compact list of today's five prayers plus the key astronomical
/// anchors, showing an indicator on the currently active row.
class QuickSummaryCard extends ConsumerWidget {
  final PrayerTimes prayer;

  const QuickSummaryCard({super.key, required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncNow = ref.watch(clockProvider);
    final now = asyncNow.value ?? DateTime.now();

    final rows = <_SummaryRow>[
      _SummaryRow('imsak', l10n.imsak, prayer.imsak, Icons.alarm),
      _SummaryRow('fajr', l10n.fajr, prayer.fajr, Icons.mosque),
      _SummaryRow('sunrise', l10n.sunrise, prayer.sunrise, Icons.wb_twilight),
      _SummaryRow('dhuhr', l10n.dhuhr, prayer.dhuhr, Icons.mosque),
      _SummaryRow('asr', l10n.asr, prayer.asr, Icons.mosque),
      _SummaryRow('maghrib', l10n.maghrib, prayer.maghrib, Icons.mosque),
      _SummaryRow('isha', l10n.isha, prayer.isha, Icons.mosque),
    ];

    final current = prayer.currentPrayer(now);
    final next = prayer.nextPrayer(now);

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppConstants.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.spaceSm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppConstants.emeraldPrimary,
                  size: 18,
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Text(
                  l10n.todaysSchedule,
                  style: const TextStyle(
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
  final DateTime time;
  final IconData icon;

  const _SummaryRow(this.key, this.label, this.time, this.icon);
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
    final color = isCurrent
        ? AppConstants.emeraldPrimary
        : (isNext ? AppConstants.goldAccent : AppConstants.textMuted);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceMd,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(row.icon, color: color, size: 16),
          ),
          const SizedBox(width: AppConstants.spaceMd),
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
          Text(
            AppDateUtils.formatTimeShort(row.time),
            style: TextStyle(
              color: isCurrent
                  ? AppConstants.emeraldPrimary
                  : AppConstants.textPrimary,
              fontSize: AppConstants.fontBody,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
