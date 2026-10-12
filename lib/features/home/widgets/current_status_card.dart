import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../data/models/prayer_times.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/clock_provider.dart';

/// Card showing the currently active prayer window, the time left
/// in the window, and the next upcoming prayer.
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

    if (current == null) {
      // Before Fajr — we are still within the previous night's window.
      return _buildBeforeFajr(context, l10n, next);
    }

    final remaining = current.end.difference(now);
    final isPrayerWindow = current.key != 'sunrise';
    final currentLabel = _localizedPrayerName(l10n, current.key);
    final nextLabel = _localizedPrayerName(l10n, next.key);
    final nextTimeStr = AppDateUtils.formatTimeShort(next.time);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppConstants.emeraldPrimary.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  isPrayerWindow ? Icons.mosque : Icons.wb_sunny_outlined,
                  color: AppConstants.emeraldPrimary,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPrayerWindow
                          ? l10n.prayerStarted(currentLabel)
                          : currentLabel,
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontSubtitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.timeRemaining,
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
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppDateUtils.formatDuration(remaining),
                style: const TextStyle(
                  color: AppConstants.emeraldPrimary,
                  fontSize: AppConstants.fontTitle,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: AppConstants.spaceSm,
            ),
            decoration: BoxDecoration(
              color: AppConstants.surfaceDarker,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppConstants.textMuted,
                  size: 16,
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    l10n.nextPrayer(nextLabel, nextTimeStr),
                    style: const TextStyle(
                      color: AppConstants.textMuted,
                      fontSize: AppConstants.fontCaption,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeFajr(
    BuildContext context,
    AppLocalizations l10n,
    ({String key, DateTime time}) next,
  ) {
    final nextLabel = _localizedPrayerName(l10n, next.key);
    final nextTimeStr = AppDateUtils.formatTimeShort(next.time);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppConstants.emeraldPrimary.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  color: AppConstants.emeraldPrimary,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Text(
                  l10n.lastThird,
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: AppConstants.fontSubtitle,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            l10n.nextPrayer(nextLabel, nextTimeStr),
            style: const TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontCaption,
            ),
          ),
        ],
      ),
    );
  }

  String _localizedPrayerName(AppLocalizations l10n, String key) {
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
        return l10n.imsak;
      case 'solarNoon':
        return l10n.solarNoon;
      case 'midnight':
        return l10n.midnight;
      case 'lastThird':
        return l10n.lastThird;
      case 'ishraq':
        return l10n.ishraq;
      default:
        return key;
    }
  }
}
