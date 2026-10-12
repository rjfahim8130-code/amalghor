import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../data/models/prayer_times.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/clock_provider.dart';

/// Live digital clock card. Ticks every second via [clockProvider].
class LiveClockCard extends ConsumerWidget {
  final PrayerTimes prayer;

  const LiveClockCard({super.key, required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final asyncNow = ref.watch(clockProvider);
    final now = asyncNow.value ?? DateTime.now();

    final clockStr = AppDateUtils.formatClock(now);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceXl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.surfaceDark,
            AppConstants.surfaceDarker,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(
          color: AppConstants.emeraldPrimary.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.emeraldPrimary.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            clockStr,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontDisplay,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            _localeTag(localeCode),
            style: const TextStyle(
              color: AppConstants.textFaint,
              fontSize: AppConstants.fontMicro,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          _DateLine(prayer: prayer),
        ],
      ),
    );
  }

  String _localeTag(String code) {
    switch (code) {
      case 'bn':
        return 'স্থানীয় সময়';
      case 'ar':
        return 'التوقيت المحلي';
      default:
        return 'LOCAL TIME';
    }
  }
}

// ─────────────────────────────────────────────
// TRI-CALENDAR DATE LINE
// ─────────────────────────────────────────────
class _DateLine extends StatelessWidget {
  final PrayerTimes prayer;

  const _DateLine({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final tri = AppDateUtils.buildTriCalendar(prayer.date, localeCode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppConstants.amoledBlack.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppConstants.spaceSm,
        runSpacing: AppConstants.spaceXs,
        children: [
          Text(
            tri.gregorianFormatted,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontCaption,
              fontWeight: FontWeight.w600,
            ),
          ),
          const _Dot(),
          Text(
            tri.banglaFormatted,
            style: const TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontCaption,
            ),
          ),
          const _Dot(),
          Text(
            tri.hijriFormatted,
            style: const TextStyle(
              color: AppConstants.emeraldPrimary,
              fontSize: AppConstants.fontCaption,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: AppConstants.textFaint,
        shape: BoxShape.circle,
      ),
    );
  }
}
