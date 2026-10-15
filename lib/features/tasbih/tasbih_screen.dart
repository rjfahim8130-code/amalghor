import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../data/models/tasbih_models.dart';
import '../../providers/tasbih_provider.dart';

/// Tasbih counter screen — auto-adapts to dark or light mode.
class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> {
  String _selectedId = DefaultTasbihs.all.first.id;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tasbihs = ref.watch(tasbihListProvider);
    final selected = ref.watch(tasbihByIdProvider(_selectedId));

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Text(
          'তাসবীহ',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            icon: Icon(Icons.refresh, color: colors.textPrimary),
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Tasbih chips row ─────────────
            SizedBox(
              height: 56,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceLg,
                  vertical: AppConstants.spaceSm,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: tasbihs.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppConstants.spaceSm),
                itemBuilder: (_, i) {
                  final t = tasbihs[i];
                  return _TasbihChip(
                    tasbih: t,
                    selected: t.id == _selectedId,
                    onTap: () => setState(() => _selectedId = t.id),
                  );
                },
              ),
            ),

            const Spacer(),

            if (selected != null) _CounterSection(tasbih: selected),

            const Spacer(),

            if (selected != null) _StatsFooter(tasbihId: selected.id),

            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final colors = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text(
          'Reset today\'s count?',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          'This will set today\'s counter back to zero.',
          style: TextStyle(color: colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(tasbihSessionProvider(_selectedId).notifier).reset();
    }
  }
}

// ─────────────────────────────────────────────
// TASBIH CHIP
// ─────────────────────────────────────────────

class _TasbihChip extends StatelessWidget {
  final Tasbih tasbih;
  final bool selected;
  final VoidCallback onTap;

  const _TasbihChip({
    required this.tasbih,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceSm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colors.emerald.withValues(alpha: 0.15)
                : colors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            border: Border.all(
              color: selected ? colors.emerald : colors.border,
              width: selected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tasbih.titleAr,
                style: TextStyle(
                  color: selected ? colors.emerald : colors.textPrimary,
                  fontSize: AppConstants.fontBody,
                  fontFamily: 'NotoNaskhArabic',
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                tasbih.titleBn,
                style: TextStyle(
                  color: selected ? colors.emerald : colors.textMuted,
                  fontSize: AppConstants.fontCaption,
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
// COUNTER SECTION
// ─────────────────────────────────────────────

class _CounterSection extends ConsumerWidget {
  final Tasbih tasbih;

  const _CounterSection({required this.tasbih});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final count = ref.watch(tasbihSessionProvider(tasbih.id));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Arabic title
        Text(
          tasbih.titleAr,
          style: TextStyle(
            color: colors.gold,
            fontSize: 32,
            fontFamily: 'NotoNaskhArabic',
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spaceSm),

        Text(
          tasbih.transliteration,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: AppConstants.fontSubtitle,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (tasbih.meaning != null) ...[
          const SizedBox(height: 4),
          Text(
            tasbih.meaning!,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: AppConstants.fontCaption,
            ),
          ),
        ],

        const SizedBox(height: AppConstants.spaceXl),

        // Big circular counter
        GestureDetector(
          onTap: () => _increment(ref),
          onLongPress: () => _decrement(ref),
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colors.emerald.withValues(alpha: 0.20),
                  colors.cardBackground,
                ],
              ),
              border: Border.all(
                color: colors.emerald,
                width: 3,
              ),
              boxShadow: colors.emeraldGlowMedium,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      color: colors.emerald,
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '/ ${tasbih.target}',
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: AppConstants.fontSubtitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spaceLg),

        Text(
          'Tap to count  •  Long press to undo',
          style: TextStyle(
            color: colors.textFaint,
            fontSize: AppConstants.fontMicro,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Future<void> _increment(WidgetRef ref) async {
    await HapticFeedback.lightImpact();
    await ref.read(tasbihSessionProvider(tasbih.id).notifier).increment();
  }

  Future<void> _decrement(WidgetRef ref) async {
    await HapticFeedback.mediumImpact();
    await ref.read(tasbihSessionProvider(tasbih.id).notifier).decrement();
  }
}

// ─────────────────────────────────────────────
// STATS FOOTER
// ─────────────────────────────────────────────

class _StatsFooter extends ConsumerWidget {
  final String tasbihId;

  const _StatsFooter({required this.tasbihId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final lifetimeAsync = ref.watch(tasbihLifetimeProvider(tasbihId));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(color: colors.border, width: 1.0),
          boxShadow: colors.cardShadow,
        ),
        child: Row(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: colors.gold,
              size: 22,
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Text(
                'Lifetime total',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: AppConstants.fontBody,
                ),
              ),
            ),
            lifetimeAsync.when(
              loading: () => SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.gold,
                ),
              ),
              error: (_, __) => const Text('—'),
              data: (total) => Text(
                '$total',
                style: TextStyle(
                  color: colors.gold,
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
