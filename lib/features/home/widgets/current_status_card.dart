import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../data/models/prayer_times.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/clock_provider.dart';

/// Home dashboard card — shows the currently active prayer window
/// and a live countdown to the next prayer.
///
/// Auto-adapts to dark or light mode via [AppColors].
class CurrentStatusCard extends ConsumerWidget {
  final PrayerTimes prayer;

  const CurrentStatusCard({super.key, required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncNow = ref.watch(clockProvider);
    final now = asyncNow.value ?? DateTime.now();

    final current = prayer.currentPrayer(now);
    final next = prayer.nextPrayer(now);

    return _MainCard(
      now: now,
      current: current,
      next: next,
      l10n: l10n,
    );
  }
}

// ─────────────────────────────────────────────
// MAIN CARD
// ─────────────────────────────────────────────

class _MainCard extends StatelessWidget {
  final DateTime now;
  final ({String key, DateTime start, DateTime end})? current;
  final ({String key, DateTime time}) next;
  final AppLocalizations l10n;

  const _MainCard({
    required this.now,
    required this.current,
    required this.next,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final remaining = next.time.difference(now);
    final currentLabel = _localizedName(l10n, current?.key ?? 'tahajjud');
    final nextLabel = _localizedName(l10n, next.key);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        gradient: colors.prayerCardGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(
          color: colors.border,
          width: 1.2,
        ),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Current prayer header ───────────
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(
                    color: colors.iconBorder,
                  ),
                ),
                child: Icon(
                  _iconFor(current?.key ?? 'tahajjud'),
                  color: colors.emerald,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentLabel,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.nowRunning,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: AppConstants.fontCaption,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Next prayer block ───────────────
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceMd + 2,
              AppConstants.spaceMd,
              AppConstants.spaceMd,
              AppConstants.spaceMd,
            ),
            decoration: BoxDecoration(
              color: colors.innerCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border(
                left: BorderSide(
                  color: colors.emerald,
                  width: 3.0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: colors.emerald,
                      size: 16,
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: Text(
                        'পরবর্তী: $nextLabel',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: AppConstants.fontBody,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      AppDateUtils.formatTimeShort(next.time),
                      style: TextStyle(
                        color: colors.emerald,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceSm),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Icon(
                        Icons.access_time_rounded,
                        color: colors.textMuted,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Text(
                      'বাকি',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: Text(
                        AppDateUtils.formatDuration(remaining),
                        style: TextStyle(
                          color: colors.emerald,
                          fontSize: AppConstants.fontTitle,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          letterSpacing: 1.2,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

String _localizedName(AppLocalizations l10n, String key) {
  switch (key) {
    case 'fajr':
      return l10n.fajr;
    case 'sunrise':
      return l10n.sunrise;
    case 'dhuhr':
      return l10n.dhuhr;
    case 'asr':
      return l10n.asr;
    case 'maghrib':
      return l10n.maghrib;
    case 'isha':
      return l10n.isha;
    case 'imsak':
    case 'sehri':
      return l10n.imsak;
    case 'solarNoon':
      return l10n.solarNoon;
    case 'midnight':
      return l10n.midnight;
    case 'lastThird':
    case 'tahajjud':
      return l10n.lastThird;
    case 'ishraq':
      return l10n.ishraq;
    case 'iftar':
      return l10n.iftar;
    default:
      return key;
  }
}

IconData _iconFor(String key) {
  switch (key) {
    case 'tahajjud':
    case 'lastThird':
      return Icons.nightlight_round;
    case 'sehri':
    case 'imsak':
      return Icons.alarm_rounded;
    case 'fajr':
    case 'dhuhr':
    case 'asr':
    case 'maghrib':
    case 'isha':
      return Icons.mosque_rounded;
    case 'sunrise':
      return Icons.wb_twilight_rounded;
    case 'sunset':
      return Icons.wb_twilight_rounded;
    case 'ishraq':
      return Icons.wb_sunny_outlined;
    case 'iftar':
      return Icons.restaurant_rounded;
    case 'midnight':
      return Icons.dark_mode_rounded;
    default:
      return Icons.schedule_rounded;
  }
}
