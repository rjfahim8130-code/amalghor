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
/// shows the full daily timings list with live countdowns.
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
// BODY
// ─────────────────────────────────────────────

class _PrayerBody extends ConsumerWidget {
  final PrayerTimes prayer;

  const _PrayerBody({required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNow = ref.watch(clockProvider);
    final now = asyncNow.value ?? DateTime.now();

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
        _TimingsListCard(prayer: prayer, now: now),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TIMINGS LIST CARD
// ─────────────────────────────────────────────

class _TimingsListCard extends StatelessWidget {
  final PrayerTimes prayer;
  final DateTime now;

  const _TimingsListCard({
    required this.prayer,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries(prayer);

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
          ...entries.asMap().entries.map((e) {
            final isLast = e.key == entries.length - 1;
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

  /// Builds the 14 entries in the exact order requested.
  List<_TimingEntry> _buildEntries(PrayerTimes p) {
    return [
      _TimingEntry(
        key: 'tahajjud',
        label: 'রাতের শেষ তৃতীয়াংশ / তাহাজ্জুদ',
        time: p.lastThirdStart,
        icon: Icons.nightlight_round,
      ),
      _TimingEntry(
        key: 'sehri',
        label: 'সেহরি শেষ',
        time: p.sehriActual,
        icon: Icons.alarm,
      ),
      _TimingEntry(
        key: 'fajr',
        label: 'ফজর',
        time: p.fajr,
        icon: Icons.mosque,
      ),
      _TimingEntry(
        key: 'sunrise',
        label: 'সূর্যোদয়',
        time: p.sunrise,
        icon: Icons.wb_twilight,
      ),
      _TimingEntry(
        key: 'ishraq',
        label: 'ইশরাক / দুহা',
        time: p.ishraq,
        icon: Icons.wb_sunny_outlined,
      ),
      _TimingEntry(
        key: 'solarNoon',
        label: 'মধ্য আকাশ',
        time: p.solarNoon,
        icon: Icons.brightness_high,
      ),
      _TimingEntry(
        key: 'dhuhr',
        label: 'যোহর',
        time: p.dhuhr,
        icon: Icons.mosque,
      ),
      _TimingEntry(
        key: 'asr',
        label: 'আসর',
        time: p.asr,
        icon: Icons.mosque,
      ),
      _TimingEntry(
        key: 'sunset',
        label: 'সূর্যাস্ত',
        time: p.sunset,
        icon: Icons.wb_twilight,
      ),
      _TimingEntry(
        key: 'iftar',
        label: 'ইফতার',
        time: p.iftarActual,
        icon: Icons.restaurant,
      ),
      _TimingEntry(
        key: 'maghrib',
        label: 'মাগরিব',
        time: p.maghrib,
        icon: Icons.mosque,
      ),
      _TimingEntry(
        key: 'isha',
        label: 'এশা',
        time: p.isha,
        icon: Icons.mosque,
      ),
      _TimingEntry(
        key: 'ishaMustahab',
        label: 'মুস্তাহাব এশা',
        time: p.ishaMustahab,
        icon: Icons.star_outline,
      ),
      _TimingEntry(
        key: 'midnight',
        label: 'ইসলামী মধ্যরাত / রাত অর্ধেক',
        time: p.islamicMidnight,
        icon: Icons.dark_mode,
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
                    color: isPast
                        ? AppConstants.textFaint
                        : AppConstants.textPrimary,
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
