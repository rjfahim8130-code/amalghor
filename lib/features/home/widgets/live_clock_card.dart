import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../data/models/prayer_times.dart';
import '../../../providers/clock_provider.dart';

/// Live digital clock card with a 3-chip tri-calendar row underneath.
///
/// Visuals:
///   - Emerald-tinted gradient background
///   - Soft emerald outer glow
///   - A thin emerald inner border
///   - Big clock numbers with tabular figures
///   - A "——— LOCAL TIME ———" divider line
///   - 3 outlined mini cards for Gregorian / Bangla / Hijri dates
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
        gradient: AppConstants.clockGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(
          color: AppConstants.emeraldPrimary.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: AppConstants.emeraldGlowMedium,
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
              letterSpacing: 1.2,
              height: 1.05,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),

          // ─── Divider label ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _line(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceSm,
                ),
                child: Text(
                  _localeTag(localeCode),
                  style: const TextStyle(
                    color: AppConstants.textMuted,
                    fontSize: AppConstants.fontMicro,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.0,
                  ),
                ),
              ),
              _line(),
            ],
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Tri-calendar chips ─────────────
          _TriCalendarChips(prayer: prayer),
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
      width: 24,
      height: 1,
      color: AppConstants.textFaint.withValues(alpha: 0.5),
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
            accent: AppConstants.emeraldPrimary,
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: _CalendarChip(
            label: 'বাংলা',
            value: tri.banglaFormatted,
            icon: Icons.wb_sunny_outlined,
            accent: AppConstants.goldBright,
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: _CalendarChip(
            label: 'হিজরি',
            value: tri.hijriFormatted,
            icon: Icons.nightlight_round,
            accent: AppConstants.cyanAccent,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceMd,
      ),
      decoration: BoxDecoration(
        color: AppConstants.amoledBlack.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: accent.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 13),
              const SizedBox(width: AppConstants.spaceXs),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.9),
                    fontSize: AppConstants.fontMicro,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontCaption,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
