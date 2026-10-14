import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../../data/models/prayer_times.dart';
import '../../providers/clock_provider.dart';
import '../../providers/prayer_provider.dart';
import '../home/widgets/home_header.dart';
import '../home/widgets/live_clock_card.dart';
import '../home/widgets/tri_calendar_row.dart';

/// Prayer timeline screen — mirrors the Home design language and
/// adds the full daily timings list with live countdowns.
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerAsync = ref.watch(currentDayPrayerProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppConstants.emeraldPrimary,
          backgroundColor: AppConstants.surfaceDark,
          onRefresh: () async {
            ref.invalidate(currentDayPrayerProvider);
            await ref.read(currentDayPrayerProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.space2xl,
            ),
            children: [
              // ─── Header (same as Home) ──────────
              const HomeHeader(),
              const SizedBox(height: AppConstants.spaceLg),

              prayerAsync.when(
                loading: () => const _PrayerLoading(),
                error: (e, _) => _PrayerError(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(currentDayPrayerProvider),
                ),
                data: (prayer) => _PrayerBody(prayer: prayer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BODY — mirrors Home + adds the full timings list
// ─────────────────────────────────────────────
class _PrayerBody extends ConsumerWidget {
  final PrayerTimes prayer;

  const _PrayerBody({required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNow = ref.watch(clockProvider);
    final now = asyncNow.value ?? DateTime.now();

    final timings = prayer.allTimings(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Live clock
        LiveClockCard(prayer: prayer),
        const SizedBox(height: AppConstants.spaceLg),

        // 2. Tri-calendar row
        const TriCalendarRow(),
        const SizedBox(height: AppConstants.spaceLg),

        // 3. Full timings list
        _TimingsListCard(
          timings: timings,
          now: now,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TIMINGS LIST CARD
// ─────────────────────────────────────────────

class _TimingsListCard extends StatelessWidget {
  final List<({String key, DateTime time, String label})> timings;
  final DateTime now;

  const _TimingsListCard({
    required this.timings,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.spaceSm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppConstants.emeraldPrimary,
                  size: 18,
                ),
                SizedBox(width: AppConstants.spaceSm),
                Text(
                  'আজকের সময়সূচি',
                  style: TextStyle(
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

// ─────────────────────────────────────────────
// TIMING ROW
// ─────────────────────────────────────────────

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

    final diff = entry.time.difference(now);
    final countdownText =
        isPast ? '✓' : AppDateUtils.formatDuration(diff);

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
      case 'ishaMustahab':
        return Icons.star_outline;
      default:
        return Icons.schedule;
    }
  }
}

// ─────────────────────────────────────────────
// LOADING / ERROR
// ─────────────────────────────────────────────

class _PrayerLoading extends StatelessWidget {
  const _PrayerLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: CircularProgressIndicator(
          color: AppConstants.emeraldPrimary,
        ),
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
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFEF4444),
            size: 40,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          const Text(
            'ত্রুটি',
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontSubtitle,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontCaption,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('আবার চেষ্টা করুন'),
          ),
        ],
      ),
    );
  }
}
