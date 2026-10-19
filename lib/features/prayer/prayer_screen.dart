import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../../data/models/prayer_times.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/clock_provider.dart';
import '../../providers/prayer_provider.dart';

/// Prayer timeline screen.
///
/// Layout:
///   - Section title: localized "Today's Schedule"
///   - Full daily timings list with live countdowns
///
/// NO location chip, NO settings icon (both live on the Home tab).
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final prayerAsync = ref.watch(currentDayPrayerProvider);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.emerald,
          backgroundColor: colors.cardBackground,
          onRefresh: () async {
            ref.invalidate(currentDayPrayerProvider);
            await ref.read(currentDayPrayerProvider.future);
          },
          child: prayerAsync.when(
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const _PrayerLoading(),
                ),
              ],
            ),
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              children: [
                _PrayerError(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(currentDayPrayerProvider),
                ),
              ],
            ),
            data: (prayer) => _PrayerBody(prayer: prayer),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────

class _PrayerBody extends ConsumerWidget {
  final PrayerTimes prayer;

  const _PrayerBody({required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final asyncNow = ref.watch(clockProvider);
    final now = asyncNow.value ?? DateTime.now();

    final entries = _buildEntries(prayer, l10n);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.space2xl,
      ),
      children: [
        // ─── Section header ────────────────
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.spaceXs,
            bottom: AppConstants.spaceMd,
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.emerald,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.emerald,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.emerald.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Text(
                l10n.todaysSchedule,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Container(
                  height: 1,
                  color: colors.border.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),

        // ─── Timings list card ─────────────
        Container(
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
            children: [
              for (var i = 0; i < entries.length; i++)
                _TimingRow(
                  entry: entries[i],
                  now: now,
                  showDivider: i < entries.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 14 timing rows — all labels come from `l10n`.
  List<_TimingEntry> _buildEntries(
    PrayerTimes p,
    AppLocalizations l10n,
  ) {
    return [
      _TimingEntry(
        key: 'tahajjud',
        label: l10n.tahajjudLabel,
        time: p.lastThirdStart,
        icon: Icons.nightlight_round,
      ),
      _TimingEntry(
        key: 'sehri',
        label: l10n.sehriEnds,
        time: p.sehriActual,
        icon: Icons.alarm_rounded,
      ),
      _TimingEntry(
        key: 'fajr',
        label: l10n.fajr,
        time: p.fajr,
        icon: Icons.mosque_rounded,
      ),
      _TimingEntry(
        key: 'sunrise',
        label: l10n.sunrise,
        time: p.sunrise,
        icon: Icons.wb_twilight_rounded,
      ),
      _TimingEntry(
        key: 'ishraq',
        label: l10n.ishraq,
        time: p.ishraq,
        icon: Icons.wb_sunny_outlined,
      ),
      _TimingEntry(
        key: 'solarNoon',
        label: l10n.solarNoon,
        time: p.solarNoon,
        icon: Icons.brightness_high_rounded,
      ),
      _TimingEntry(
        key: 'dhuhr',
        label: l10n.dhuhr,
        time: p.dhuhr,
        icon: Icons.mosque_rounded,
      ),
      _TimingEntry(
        key: 'asr',
        label: l10n.asr,
        time: p.asr,
        icon: Icons.mosque_rounded,
      ),
      _TimingEntry(
        key: 'sunset',
        label: l10n.sunset,
        time: p.sunset,
        icon: Icons.wb_twilight_rounded,
      ),
      _TimingEntry(
        key: 'iftar',
        label: l10n.iftar,
        time: p.iftarActual,
        icon: Icons.restaurant_rounded,
      ),
      _TimingEntry(
        key: 'maghrib',
        label: l10n.maghrib,
        time: p.maghrib,
        icon: Icons.mosque_rounded,
      ),
      _TimingEntry(
        key: 'isha',
        label: l10n.isha,
        time: p.isha,
        icon: Icons.mosque_rounded,
      ),
      _TimingEntry(
        key: 'ishaMustahab',
        label: l10n.mustahabbIsha,
        time: p.ishaMustahab,
        icon: Icons.star_outline_rounded,
      ),
      _TimingEntry(
        key: 'midnight',
        label: l10n.midnightHalf,
        time: p.islamicMidnight,
        icon: Icons.dark_mode_rounded,
      ),
    ];
  }
}

class _TimingEntry {
  final String key;
  final String label;
  final DateTime time;
  final IconData icon;

  const _TimingEntry({
    required this.key,
    required this.label,
    required this.time,
    required this.icon,
  });
}

// ─────────────────────────────────────────────
// TIMING ROW
// ─────────────────────────────────────────────

class _TimingRow extends StatelessWidget {
  final _TimingEntry entry;
  final DateTime now;
  final bool showDivider;

  const _TimingRow({
    required this.entry,
    required this.now,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isPast = entry.time.isBefore(now);
    final isNext = !isPast;

    final diff = entry.time.difference(now);
    final countdownText =
        isPast ? '✓' : AppDateUtils.formatDuration(diff);

    final accent = isPast ? colors.textFaint : colors.emerald;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceMd,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isPast
                      ? colors.textFaint.withValues(alpha: 0.08)
                      : colors.iconBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  border: isPast
                      ? null
                      : Border.all(color: colors.iconBorder),
                ),
                child: Icon(
                  entry.icon,
                  color: accent,
                  size: 14,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Text(
                  entry.label,
                  style: TextStyle(
                    color: isPast ? colors.textFaint : colors.textPrimary,
                    fontSize: AppConstants.fontBody,
                    fontWeight:
                        isNext ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                AppDateUtils.formatTimeShort(entry.time),
                style: TextStyle(
                  color: isPast ? colors.textFaint : colors.textPrimary,
                  fontSize: AppConstants.fontBody,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
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
          Divider(
            height: 1,
            indent: AppConstants.spaceLg,
            color: colors.divider,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// LOADING / ERROR
// ─────────────────────────────────────────────

class _PrayerLoading extends StatelessWidget {
  const _PrayerLoading();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: CircularProgressIndicator(
        color: colors.emerald,
      ),
    );
  }
}

class _PrayerError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PrayerError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFEF4444),
            size: 40,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            l10n.error,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: AppConstants.fontSubtitle,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: AppConstants.fontCaption,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
