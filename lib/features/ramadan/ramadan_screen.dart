import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../../data/models/prayer_times.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/clock_provider.dart';
import '../../providers/prayer_provider.dart';

/// Ramadan screen — shows Sehri end, Iftar time, and a countdown.
class RamadanScreen extends ConsumerWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final prayerAsync = ref.watch(currentDayPrayerProvider);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Text(
          l10n.ramadanTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: prayerAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: colors.emerald),
        ),
        error: (e, _) => Center(
          child: Text(
            '$e',
            style: TextStyle(color: colors.textMuted),
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
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final asyncNow = ref.watch(clockProvider);
    final now = asyncNow.value ?? DateTime.now();

    final isRamadan = AppDateUtils.isRamadan(now);
    final ramadanDay = AppDateUtils.ramadanDay(now);
    final daysUntil = AppDateUtils.daysUntilRamadan(now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.space2xl,
      ),
      children: [
        _Banner(
          isRamadan: isRamadan,
          ramadanDay: ramadanDay,
          daysUntil: daysUntil,
          l10n: l10n,
        ),
        const SizedBox(height: AppConstants.spaceLg),
        _CountdownCard(prayer: prayer, now: now, l10n: l10n),
        const SizedBox(height: AppConstants.spaceLg),
        _TimeRow(
          title: l10n.ramadanSehriEnds,
          time: AppDateUtils.formatTimeShort(prayer.sehriSafety),
          icon: Icons.alarm_rounded,
          accent: colors.gold,
        ),
        const SizedBox(height: AppConstants.spaceMd),
        _TimeRow(
          title: l10n.ramadanIftarAt,
          time: AppDateUtils.formatTimeShort(prayer.iftarSafety),
          icon: Icons.restaurant_rounded,
          accent: colors.emerald,
        ),
        const SizedBox(height: AppConstants.spaceXl),
        _DurationCard(prayer: prayer),
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
    final colors = AppColors.of(context);
    String title;
    if (isRamadan && ramadanDay != null) {
      title = l10n.ramadanDay(ramadanDay!);
    } else if (daysUntil != null) {
      title = l10n.ramadanDaysRemaining(daysUntil!);
    } else {
      title = l10n.ramadanTitle;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        gradient: colors.prayerCardGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: colors.border, width: 1.2),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.iconBackground,
              shape: BoxShape.circle,
              border: Border.all(color: colors.iconBorder),
            ),
            child: Icon(
              Icons.nightlight_round,
              color: colors.emerald,
              size: 26,
            ),
          ),
          const SizedBox(width: AppConstants.spaceLg),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: AppConstants.fontHeading,
                fontWeight: FontWeight.w700,
              ),
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
    final colors = AppColors.of(context);
    final sehriEnds = prayer.sehriSafety;
    final iftar = prayer.iftarSafety;
    final isBeforeSehriEnd = now.isBefore(sehriEnds);
    final target = isBeforeSehriEnd ? sehriEnds : iftar;
    final label =
        isBeforeSehriEnd ? l10n.ramadanSehriEnds : l10n.ramadanIftarAt;
    final diff = target.difference(now);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        gradient: colors.clockGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: colors.border, width: 1.2),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            l10n.ramadanCountdown,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: AppConstants.fontCaption,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            AppDateUtils.formatDuration(diff),
            style: TextStyle(
              color: colors.emerald,
              fontSize: AppConstants.fontDisplay,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            label,
            style: TextStyle(
              color: colors.textMuted,
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
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: colors.border, width: 1.0),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.textPrimary,
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

  const _DurationCard({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fastDuration = prayer.maghrib.difference(prayer.fajr);
    final h = fastDuration.inHours;
    final m = fastDuration.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: colors.cardBackgroundSubtle,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fast duration',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: AppConstants.fontBody,
            ),
          ),
          Text(
            '${h}h ${m}m',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: AppConstants.fontSubtitle,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
