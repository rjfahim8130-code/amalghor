import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../data/models/prayer_times.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/clock_provider.dart';

/// Home dashboard card showing:
///   - the currently active prayer window
///   - a live countdown to the next prayer
///   - a compact list of all 13 timings with per-row countdowns
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MainCard(
          now: now,
          prayer: prayer,
          current: current,
          next: next,
          l10n: l10n,
        ),
        const SizedBox(height: AppConstants.spaceMd),
        _AllTimingsList(
          now: now,
          prayer: prayer,
          l10n: l10n,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MAIN CARD — current + next
// ─────────────────────────────────────────────
class _MainCard extends StatelessWidget {
  final DateTime now;
  final PrayerTimes prayer;
  final ({String key, DateTime start, DateTime end})? current;
  final ({String key, DateTime time}) next;
  final AppLocalizations l10n;

  const _MainCard({
    required this.now,
    required this.prayer,
    required this.current,
    required this.next,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = next.time.difference(now);
    final currentLabel = _localizedName(l10n, current?.key ?? 'tahajjud');
    final nextLabel = _localizedName(l10n, next.key);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.surfaceDark,
            AppConstants.surfaceDarker,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppConstants.emeraldPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Current phase ────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(
                  _iconFor(current?.key ?? 'tahajjud'),
                  color: AppConstants.emeraldPrimary,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentLabel,
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontSubtitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.nowRunning,
                      style: const TextStyle(
                        color: AppConstants.textMuted,
                        fontSize: AppConstants.fontCaption,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Next + countdown ─────────────────
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              color: AppConstants.amoledBlack.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppConstants.emeraldPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: Text(
                        'পরবর্তী: $nextLabel',
                        style: const TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: AppConstants.fontBody,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      AppDateUtils.formatTimeShort(next.time),
                      style: const TextStyle(
                        color: AppConstants.emeraldPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Row(
                  children: [
                    const Text(
                      'বাকি',
                      style: TextStyle(
                        color: AppConstants.textMuted,
                        fontSize: AppConstants.fontCaption,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: Text(
                        AppDateUtils.formatDuration(remaining),
                        style: const TextStyle(
                          color: AppConstants.emeraldPrimary,
                          fontSize: AppConstants.fontTitle,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                          letterSpacing: 1.0,
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
// ALL TIMINGS LIST — per-row countdown
// ─────────────────────────────────────────────
class _AllTimingsList extends StatelessWidget {
  final DateTime now;
  final PrayerTimes prayer;
  final AppLocalizations l10n;

  const _AllTimingsList({
    required this.now,
    required this.prayer,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final timings = prayer.allTimings(now);

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppConstants.dividerColor),
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
                  Icons.schedule,
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
          ...timings.asMap().entries.map((e) {
            final isLast = e.key == timings.length - 1;
            return _TimingRow(
              entry: e.value,
              now: now,
              showDivider: !isLast,
            );
          }),
        ],
      ),
    );
  }
}

class _TimingRow extends StatelessWidget {
  final ({String key, DateTime time, String label}) entry;
  final DateTime now;
  final bool showDivider;

  const _TimingRow({
    required this.entry,
    required this.now,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = entry.time.isBefore(now);
    final isNext = !isPast;

    // Compute countdown from now to this event (only if not past).
    final diff = entry.time.difference(now);
    final countdownText = isPast
        ? '✓'
        : AppDateUtils.formatDuration(diff);

    final accent = isPast
        ? AppConstants.textFaint
        : AppConstants.emeraldPrimary;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceMd,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Icon(
                  _iconFor(entry.key),
                  color: accent,
                  size: 14,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),

              // Label
              Expanded(
                child: Text(
                  entry.label,
                  style: TextStyle(
                    color: isPast
                        ? AppConstants.textFaint
                        : AppConstants.textPrimary,
                    fontSize: AppConstants.fontBody,
                    fontWeight:
                        isNext ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),

              // Clock time
              Text(
                AppDateUtils.formatTimeShort(entry.time),
                style: TextStyle(
                  color: isPast
                      ? AppConstants.textFaint
                      : AppConstants.textPrimary,
                  fontSize: AppConstants.fontBody,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),

              // Countdown
              SizedBox(
                width: 72,
                child: Text(
                  countdownText,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: accent,
                    fontSize: AppConstants.fontCaption,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: AppConstants.spaceLg),
      ],
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
      return Icons.alarm;
    case 'fajr':
    case 'dhuhr':
    case 'asr':
    case 'maghrib':
    case 'isha':
      return Icons.mosque;
    case 'sunrise':
      return Icons.wb_twilight;
    case 'sunset':
      return Icons.wb_twilight;
    case 'ishraq':
      return Icons.wb_sunny_outlined;
    case 'iftar':
      return Icons.restaurant;
    case 'midnight':
      return Icons.dark_mode;
    default:
      return Icons.schedule;
  }
}
