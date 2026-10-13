import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../../data/models/prayer_times.dart';
import '../../data/models/timeline_event.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/prayer_provider.dart';

/// Full timeline screen listing all events for the current day.
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prayerAsync = ref.watch(currentDayPrayerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPrayer)),
      body: prayerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppConstants.emeraldPrimary,
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            '$e',
            style: const TextStyle(color: AppConstants.textMuted),
          ),
        ),
        data: (prayer) => _PrayerTimeline(prayer: prayer),
      ),
    );
  }
}

class _PrayerTimeline extends StatelessWidget {
  final PrayerTimes prayer;

  const _PrayerTimeline({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final events = TimelineBuilder.build(
      lastThird: prayer.lastThirdStart,
      imsak: prayer.sehriSafety,
      fajr: prayer.fajr,
      sunrise: prayer.sunrise,
      ishraq: prayer.ishraq,
      solarNoon: prayer.solarNoon,
      dhuhr: prayer.dhuhr,
      asr: prayer.asr,
      sunset: prayer.sunset,
      maghrib: prayer.maghrib,
      isha: prayer.isha,
      midnight: prayer.islamicMidnight,
    );

    final currentIdx = TimelineBuilder.currentIndex(events, now);
    final nextIdx = TimelineBuilder.nextIndex(events, now);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceLg,
      ),
      itemCount: events.length,
      itemBuilder: (context, i) {
        final event = events[i];
        return _TimelineTile(
          event: event,
          label: _localizedEvent(l10n, event.key),
          isCurrent: i == currentIdx,
          isNext: i == nextIdx,
          isPast: event.isPast(now),
        );
      },
    );
  }

  String _localizedEvent(AppLocalizations l10n, String key) {
    switch (key) {
      case 'lastThird':
        return l10n.lastThird;
      case 'imsak':
        return l10n.imsak;
      case 'fajr':
        return l10n.fajr;
      case 'sunrise':
        return l10n.sunrise;
      case 'ishraq':
        return l10n.ishraq;
      case 'solarNoon':
        return l10n.solarNoon;
      case 'dhuhr':
        return l10n.dhuhr;
      case 'asr':
        return l10n.asr;
      case 'sunset':
        return 'সূর্যাস্ত';
      case 'maghrib':
        return l10n.maghrib;
      case 'isha':
        return l10n.isha;
      case 'midnight':
        return l10n.midnight;
      default:
        return key;
    }
  }
}

class _TimelineTile extends StatelessWidget {
  final TimelineEvent event;
  final String label;
  final bool isCurrent;
  final bool isNext;
  final bool isPast;

  const _TimelineTile({
    required this.event,
    required this.label,
    required this.isCurrent,
    required this.isNext,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isCurrent
        ? AppConstants.emeraldPrimary
        : (isNext ? AppConstants.goldAccent : AppConstants.textFaint);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent,
                      width: isCurrent ? 2.0 : 1.0,
                    ),
                  ),
                  child: Icon(event.icon, color: accent, size: 16),
                ),
                Container(
                  width: 1.4,
                  height: 22,
                  color: AppConstants.dividerColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceLg,
                vertical: AppConstants.spaceMd,
              ),
              decoration: BoxDecoration(
                color: isCurrent || isNext
                    ? AppConstants.surfaceDark
                    : AppConstants.surfaceDarker,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: isCurrent
                      ? AppConstants.emeraldPrimary.withValues(alpha: 0.5)
                      : AppConstants.dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isPast && !isCurrent
                            ? AppConstants.textFaint
                            : AppConstants.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: isCurrent || isNext
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    AppDateUtils.formatTimeShort(event.time),
                    style: TextStyle(
                      color: accent,
                      fontSize: AppConstants.fontBody,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
