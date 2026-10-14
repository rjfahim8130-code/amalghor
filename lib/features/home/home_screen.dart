import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/router.dart';
import '../../data/models/prayer_times.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/prayer_provider.dart';
import 'widgets/current_status_card.dart';
import 'widgets/home_header.dart';
import 'widgets/live_clock_card.dart';

/// Main dashboard.
///
/// Layout:
///   - HomeHeader (location + settings)
///   - LiveClockCard (big clock + 3-chip date row)
///   - CurrentStatusCard (current + next prayer)
///   - Tools grid (6 tiles)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
                loading: () => const _HomeLoading(),
                error: (e, _) => _HomeError(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(currentDayPrayerProvider),
                ),
                data: (prayer) => _HomeBody(prayer: prayer),
              ),

              const SizedBox(height: AppConstants.spaceLg),

              // ─── Tools Grid ─────────────────────
              const _ToolsGrid(),
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

class _HomeBody extends StatelessWidget {
  final PrayerTimes prayer;

  const _HomeBody({required this.prayer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiveClockCard(prayer: prayer),
        const SizedBox(height: AppConstants.spaceLg),
        CurrentStatusCard(prayer: prayer),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TOOLS GRID — 6 tiles
// ─────────────────────────────────────────────

class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid();

  @override
  Widget build(BuildContext context) {
    final tools = <_ToolItem>[
      _ToolItem(
        icon: Icons.explore_outlined,
        label: 'কিবলা',
        route: Routes.qibla,
      ),
      _ToolItem(
        icon: Icons.picture_as_pdf_outlined,
        label: 'PDF',
        route: Routes.pdfSettings,
      ),
      _ToolItem(
        icon: Icons.radio_button_checked,
        label: 'তাসবীহ',
        route: Routes.tasbih,
      ),
      _ToolItem(
        icon: Icons.auto_awesome_outlined,
        label: '৯৯ নাম',
        route: Routes.asma,
      ),
      _ToolItem(
        icon: Icons.calendar_month_outlined,
        label: 'ক্যালেন্ডার',
        route: Routes.calendar,
      ),
      _ToolItem(
        icon: Icons.volunteer_activism_outlined,
        label: 'দুআ',
        route: Routes.dua,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.spaceXs,
            bottom: AppConstants.spaceMd,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.apps,
                color: AppConstants.emeraldPrimary,
                size: 18,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              const Text(
                'টুলস',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppConstants.spaceMd,
          mainAxisSpacing: AppConstants.spaceMd,
          childAspectRatio: 1.05,
          children: tools.map((t) => _ToolTile(item: t)).toList(),
        ),
      ],
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final String route;

  const _ToolItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _ToolTile extends StatelessWidget {
  final _ToolItem item;

  const _ToolTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        onTap: () => context.push(item.route),
        child: Container(
          decoration: BoxDecoration(
            color: AppConstants.surfaceDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: AppConstants.emeraldPrimary.withValues(alpha: 0.20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(
                  item.icon,
                  color: AppConstants.emeraldPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                item.label,
                style: const TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: AppConstants.fontCaption,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOADING / ERROR
// ─────────────────────────────────────────────

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

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

class _HomeError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Text(
            l10n.error,
            style: const TextStyle(
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
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
