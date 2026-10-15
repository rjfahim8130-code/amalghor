import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../data/models/prayer_times.dart';
import '../../../providers/clock_provider.dart';

/// Live digital clock card with a 3-chip tri-calendar row underneath.
///
/// Auto-adapts to dark or light mode via [AppColors]:
///   - Dark: emerald-tinted glass gradient + soft glow
///   - Light: mint-green cream gradient + soft card shadow
class LiveClockCard extends ConsumerWidget {
  final PrayerTimes prayer;

  const LiveClockCard({super.key, required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
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
        gradient: colors.clockGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(
          color: colors.border,
          width: 1.2,
        ),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          // ─── Big clock ──────────────────────
          Text(
            clockStr,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: AppConstants.fontDisplay,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 1.2,
              height: 1.05,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),

          // ─── Divider label ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _line(colors),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceSm,
                ),
                child: Text(
                  _localeTag(localeCode),
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: AppConstants.fontMicro,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.0,
                  ),
                ),
              ),
              _line(colors),
            ],
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Tri-calendar chips ─────────────
          _TriCalendarChips(prayer: prayer),
        ],
      ),
    );
  }

  Widget _line(AppColors colors) {
    return Container(
      width: 24,
      height: 1,
      color: colors.textFaint.withValues(alpha: 0.5),
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
    final colors = AppColors.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final tri = AppDateUtils.buildTriCalendar(prayer.date, localeCode);

    return Row(
      children: [
        Expanded(
          child: _CalendarChip(
            label: 'ইংরেজি',
            value: tri.gregorianFormatted,
            icon: Icons.calendar_month_outlined,
            accent: colors.emerald,
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: _CalendarChip(
            label: 'বাংলা',
            value: tri.banglaFormatted,
            icon: Icons.wb_sunny_outlined,
            accent: colors.gold,
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: _CalendarChip(
            label: 'হিজরি',
            value: tri.hijriFormatted,
            icon: Icons.nightlight_round,
            accent: colors.cyan,
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
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceMd,
      ),
      decoration: BoxDecoration(
        color: colors.calendarChip,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: accent.withValues(alpha: colors.isDark ? 0.35 : 0.55),
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
                    color: accent.withValues(alpha: 0.95),
                    fontSize: AppConstants.fontMicro,
                    fontWeight: FontWeight.w700,
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
            style: TextStyle(
              color: colors.textPrimary,
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
