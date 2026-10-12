import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../../data/models/prayer_times.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/clock_provider.dart';
import '../../providers/prayer_provider.dart';

/// Ramadan screen showing:
///   - today's Sehri end (Imsak) and Iftar times
///   - a live countdown to the nearest event
///   - a Ramadan day counter if the current date is in Ramadan
///   - days remaining until next Ramadan otherwise
class RamadanScreen extends ConsumerWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prayerAsync = ref.watch(currentDayPrayerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ramadanTitle)),
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
        data: (prayer) => _RamadanBody(prayer: prayer),
      ),
    );
  }
}

class _RamadanBody extends ConsumerWidget {
  final PrayerTimes prayer;

  const _RamadanBody({required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncNow = ref.watch(clockProvider);
    final now = asyncNow.value ?? DateTime.now();

    final isRamadan = AppDateUtils.isRamadan(now);
    final ramadanDay = AppDateUtils.ramadanDay(now);
    final daysUntil = AppDateUtils.daysUntilRamadan(now);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceLg,
      ),
      children: [
        // Status banner
        _Banner(
          isRamadan: isRamadan,
          ramadanDay: ramadanDay,
          daysUntil: daysUntil,
          l10n: l10n,
        ),
        const SizedBox(height: AppConstants.spaceLg),

        // Countdown card
        _CountdownCard(prayer: prayer, now: now, l10n: l10n),
        const SizedBox(height: AppConstants.spaceLg),

        // Sehri + Iftar times
        _TimeRow(
          title: l10n.ramadanSehriEnds,
          time: AppDateUtils.formatTimeShort(prayer.imsak),
          icon: Icons.alarm,
          accent: AppConstants.goldAccent,
        ),
        const SizedBox(height: AppConstants.spaceMd),
        _TimeRow(
          title: l10n.ramadanIftarAt,
          time: AppDateUtils.formatTimeShort(prayer.maghrib),
          icon: Icons.restaurant,
          accent: AppConstants.emeraldPrimary,
        ),
        const SizedBox(height: AppConstants.spaceXl),

        // Fasting duration
        _DurationCard(prayer: prayer, l10n: l10n),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  final bool isRamadan;
  final int? ramadanDay;
  final int? daysUntil;
  final AppLocalizations l10n;

  const _Banner({
    required this.isRamadan,
    required this.ramadanDay,
    required this.daysUntil,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;

    if (isRamadan && ramadanDay != null) {
      title = l10n.ramadanDay(ramadanDay!);
      subtitle = '';
    } else if (daysUntil != null) {
      title = l10n.ramadanDaysRemaining(daysUntil!);
      subtitle = '';
    } else {
      title = l10n.ramadanTitle;
      subtitle = '';
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.emeraldPrimary.withValues(alpha: 0.18),
            AppConstants.goldAccent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppConstants.emeraldPrimary.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppConstants.emeraldPrimary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.nightlight_round,
              color: AppConstants.emeraldPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppConstants.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: AppConstants.fontHeading,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle,
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
}

class _CountdownCard extends StatelessWidget {
  final PrayerTimes prayer;
  final DateTime now;
  final AppLocalizations l10n;

  const _CountdownCard({
    required this.prayer,
    required this.now,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final sehriEnds = prayer.imsak;
    final iftar = prayer.maghrib;
    final isBeforeSehriEnd = now.isBefore(sehriEnds);
    final target = isBeforeSehriEnd ? sehriEnds : iftar;
    final label =
        isBeforeSehriEnd ? l10n.ramadanSehriEnds : l10n.ramadanIftarAt;
    final diff = target.difference(now);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      child: Column(
        children: [
          Text(
            l10n.ramadanCountdown,
            style: const TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontCaption,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            AppDateUtils.formatDuration(diff),
            style: const TextStyle(
              color: AppConstants.emeraldPrimary,
              fontSize: AppConstants.fontDisplay,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            label,
            style: const TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontCaption,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color accent;

  const _TimeRow({
    required this.title,
    required this.time,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: AppConstants.fontBody,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: accent,
              fontSize: AppConstants.fontSubtitle,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  final PrayerTimes prayer;
  final AppLocalizations l10n;

  const _DurationCard({required this.prayer, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final fastDuration = prayer.maghrib.difference(prayer.fajr);
    final h = fastDuration.inHours;
    final m = fastDuration.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDarker,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Fast duration',
            style: TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontBody,
            ),
          ),
          Text(
            '${h}h ${m}m',
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontSubtitle,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
