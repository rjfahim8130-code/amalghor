import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../data/models/prayer_times.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/prayer_provider.dart';
import 'widgets/current_status_card.dart';
import 'widgets/home_header.dart';
import 'widgets/live_clock_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final prayerAsync = ref.watch(currentDayPrayerProvider);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: colors.topGlow),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: colors.emerald,
              backgroundColor: colors.cardBackground,
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
                  const SizedBox(height: AppConstants.spaceXl),
                  prayerAsync.when(
                    loading: () => const _HomeLoading(),
                    error: (e, _) => _HomeError(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(currentDayPrayerProvider),
                    ),
                    data: (prayer) => _HomeBody(prayer: prayer),
                  ),
                  const SizedBox(height: AppConstants.spaceXl),
                  const _ToolsGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
// TOOLS GRID — HORIZONTAL SCROLL, EXACT 2 ROWS
// ─────────────────────────────────────────────

class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tools = <_ToolItem>[
      _ToolItem(icon: Icons.explore_outlined, label: 'কিবলা', route: Routes.qibla),
      _ToolItem(icon: Icons.picture_as_pdf_outlined, label: 'PDF', route: Routes.pdfSettings),
      _ToolItem(icon: Icons.radio_button_checked, label: 'তাসবীহ', route: Routes.tasbih),
      _ToolItem(icon: Icons.auto_awesome_outlined, label: '৯৯ নাম', route: Routes.asma),
      _ToolItem(icon: Icons.calendar_month_outlined, label: 'ক্যালেন্ডার', route: Routes.calendar),
      _ToolItem(icon: Icons.volunteer_activism_outlined, label: 'দুআ', route: Routes.dua),
      _ToolItem(icon: Icons.notifications_active_outlined, label: 'নোটিফিকেশন', route: Routes.notifications),
      _ToolItem(icon: Icons.alarm_rounded, label: 'অ্যালার্ম', route: Routes.alarms),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.spaceXs, bottom: AppConstants.spaceMd),
          child: Row(
            children: [
              _dot(colors, 1.0),
              const SizedBox(width: 6),
              _dot(colors, 1.0),
              const SizedBox(width: 6),
              _dot(colors, 0.5),
              const SizedBox(width: AppConstants.spaceMd),
              Text(
                'টুলস',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Container(height: 1, color: colors.border.withValues(alpha: 0.35)),
              ),
            ],
          ),
        ),
        
        // Horizontal scrollable — fixed 110 width columns, 2 rows
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 2),
            itemCount: (tools.length / 2).ceil(),
            separatorBuilder: (_, __) => const SizedBox(width: AppConstants.spaceMd),
            itemBuilder: (context, colIndex) {
              final topIndex = colIndex * 2;
              final bottomIndex = topIndex + 1;
              return SizedBox(
                width: 100,
                child: Column(
                  children: [
                    Expanded(child: _ToolTile(item: tools[topIndex])),
                    const SizedBox(height: AppConstants.spaceMd),
                    Expanded(
                      child: bottomIndex < tools.length
                          ? _ToolTile(item: tools[bottomIndex])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dot(AppColors colors, double alpha) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: colors.emerald.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final String route;

  const _ToolItem({required this.icon, required this.label, required this.route});
}

class _ToolTile extends StatelessWidget {
  final _ToolItem item;

  const _ToolTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        onTap: () => context.push(item.route),
        child: Container(
          decoration: BoxDecoration(
            gradient: colors.toolTileGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(color: colors.border, width: 1.0),
            boxShadow: colors.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: colors.iconBorder),
                ),
                child: Icon(item.icon, color: colors.emerald, size: 22),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppConstants.fontCaption,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Center(child: CircularProgressIndicator(color: colors.emerald)),
    );
  }
}

class _HomeError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeError({required this.message, required this.onRetry});

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
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 40),
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
            style: TextStyle(color: colors.textMuted, fontSize: AppConstants.fontCaption),
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
