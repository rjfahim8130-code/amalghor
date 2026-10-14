import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../data/models/prayer_times.dart';
import '../../../providers/clock_provider.dart';

/// Live digital clock card with a 3-chip tri-calendar row underneath.
class LiveClockCard extends ConsumerWidget {
  final PrayerTimes prayer;

  const LiveClockCard({super.key, required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      ),
      child: Column(
        children: [
          // ─── Big clock ──────────────────────
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

          // ─── Tri-calendar chips ─────────────
          _TriCalendarChips(prayer: prayer),
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
// TRI-CALENDAR CHIPS
// ─────────────────────────────────────────────

class _TriCalendarChips extends StatelessWidget {
  final PrayerTimes prayer;

  const _TriCalendarChips({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final tri = AppDateUtils.buildTriCalendar(prayer.date, localeCode);

    return Row(
      children: [
        Expanded(
          child: _CalendarChip(
            label: 'ইংরেজি',
            value: tri.gregorianFormatted,
            icon: Icons.calendar_month_outlined,
            accent: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: _CalendarChip(
            label: 'বাংলা',
            value: tri.banglaFormatted,
            icon: Icons.wb_sunny_outlined,
            accent: AppConstants.goldAccent,
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: _CalendarChip(
            label: 'হিজরি',
            value: tri.hijriFormatted,
            icon: Icons.nightlight_round,
            accent: AppConstants.emeraldPrimary,
          ),
        ),
      ],
    );
  }
}

class _CalendarChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _CalendarChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppConstants.amoledBlack.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppConstants.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 14),
              const SizedBox(width: AppConstants.spaceXs),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppConstants.textMuted,
                    fontSize: AppConstants.fontMicro,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            value,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontCaption,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
