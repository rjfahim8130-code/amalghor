import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../data/models/prayer_times.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/notification_provider.dart';
import '../../providers/prayer_provider.dart';
import 'widgets/current_status_card.dart';
import 'widgets/home_header.dart';
import 'widgets/live_clock_card.dart';

/// Main dashboard — auto-adapts to dark or light mode.
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
                      onRetry: () =>
                          ref.invalidate(currentDayPrayerProvider),
                    ),
                    data: (prayer) => _HomeBody(prayer: prayer),
                  ),

                  const SizedBox(height: AppConstants.spaceXl),

                  // ─── Tools (scrollable) ───────
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
// TOOLS — HORIZONTAL SCROLLABLE GRID
// ─────────────────────────────────────────────

class _ToolsGrid extends ConsumerWidget {
  const _ToolsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final tools = <_ToolItem>[
      // ─── Row 1: Main tools ────────────────
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

      // ─── Row 2: Notifications + Alarm ─────
      _ToolItem(
        icon: Icons.notifications_active_outlined,
        label: 'নোটিফিকেশন',
        isAction: true,
        onTap: () => _handleNotification(context, ref),
      ),
      _ToolItem(
        icon: Icons.alarm_rounded,
        label: 'অ্যালার্ম',
        isAction: true,
        onTap: () => _handleAlarm(context, ref),
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

        // Horizontal scroll — 2 rows × N columns.
        SizedBox(
          height: 200,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.spaceMd,
              crossAxisSpacing: AppConstants.spaceMd,
              childAspectRatio: 1.0,
            ),
            itemCount: (tools.length / 2).ceil(),
            itemBuilder: (context, colIndex) {
              final topIndex = colIndex * 2;
              final bottomIndex = topIndex + 1;
              return Column(
                children: [
                  Expanded(
                    child: _ToolTile(item: tools[topIndex]),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Expanded(
                    child: bottomIndex < tools.length
                        ? _ToolTile(item: tools[bottomIndex])
                        : const SizedBox.shrink(),
                  ),
                ],
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

  // ─────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────

  Future<void> _handleNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final colors = AppColors.of(context);
    final status = ref.read(notificationProvider);

    if (status == NotificationPermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('নোটিফিকেশন চালু আছে'),
          backgroundColor: colors.cardBackground,
          action: SnackBarAction(
            label: 'টেস্ট',
            textColor: colors.emerald,
            onPressed: () async {
              await ref.read(notificationProvider.notifier).sendTest();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('১০ সেকেন্ড পরে টেস্ট নোটিফিকেশন আসবে'),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    final granted =
        await ref.read(notificationProvider.notifier).requestPermission();
    if (!context.mounted) return;

    if (granted) {
      await ref.read(notificationProvider.notifier).reschedule();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('নোটিফিকেশন চালু হয়েছে ✅')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুমতি দেওয়া হয়নি। সেটিংস থেকে চালু করুন।'),
        ),
      );
    }
  }

  Future<void> _handleAlarm(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colors = AppColors.of(ctx);
        return AlertDialog(
          backgroundColor: colors.cardBackground,
          title: Text(
            'টেস্ট অ্যালার্ম',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: Text(
            '১০ সেকেন্ড পর একটি টেস্ট নোটিফিকেশন পাঠানো হবে। '
            'চাইলে App বন্ধ করে দেখুন কাজ করছে কিনা।',
            style: TextStyle(color: colors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('বাতিল', style: TextStyle(color: colors.textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('পাঠান', style: TextStyle(color: colors.emerald)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(notificationProvider.notifier).sendTest();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('১০ সেকেন্ড অপেক্ষা করুন — notification আসবে'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final String? route;
  final bool isAction;
  final VoidCallback? onTap;

  const _ToolItem({
    required this.icon,
    required this.label,
    this.route,
    this.isAction = false,
    this.onTap,
  });
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
        onTap: () {
          if (item.onTap != null) {
            item.onTap!();
          } else if (item.route != null) {
            context.push(item.route!);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: colors.toolTileGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: item.isAction
                  ? colors.emerald.withValues(alpha: 0.55)
                  : colors.border,
              width: 1.0,
            ),
            boxShadow: colors.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: colors.iconBorder),
                ),
                child: Icon(
                  item.icon,
                  color: colors.emerald,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppConstants.fontCaption,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
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

// ─────────────────────────────────────────────
// LOADING / ERROR
// ─────────────────────────────────────────────

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: CircularProgressIndicator(color: colors.emerald),
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
