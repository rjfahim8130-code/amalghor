import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/models/tasbih_models.dart';
import '../../providers/tasbih_provider.dart';

/// Main Tasbih counter screen.
///
/// Layout:
///   - Top: horizontal scroll of Tasbih chips (one per dhikr)
///   - Center: big circular counter with tap target
///   - Bottom: reset + lifetime stats
class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> {
  String _selectedId = DefaultTasbihs.all.first.id;

  @override
  Widget build(BuildContext context) {
    final tasbihs = ref.watch(tasbihListProvider);
    final selected = ref.watch(tasbihByIdProvider(_selectedId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('তাসবীহ'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh),
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Tasbih chips ─────────────────
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

            // ─── Big circular counter ─────────
            if (selected != null) _CounterSection(tasbih: selected),

            const Spacer(),

            // ─── Footer stats ────────────────
            if (selected != null) _StatsFooter(tasbihId: selected.id),

            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceDark,
        title: const Text(
          'Reset today\'s count?',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: const Text(
          'This will set today\'s counter back to zero.',
          style: TextStyle(color: AppConstants.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
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
                ? AppConstants.emeraldPrimary.withValues(alpha: 0.20)
                : AppConstants.surfaceDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            border: Border.all(
              color: selected
                  ? AppConstants.emeraldPrimary
                  : AppConstants.dividerColor,
              width: selected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tasbih.titleAr,
                style: TextStyle(
                  color: selected
                      ? AppConstants.emeraldPrimary
                      : AppConstants.textPrimary,
                  fontSize: AppConstants.fontBody,
                  fontFamily: 'NotoNaskhArabic',
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                tasbih.titleBn,
                style: TextStyle(
                  color: selected
                      ? AppConstants.emeraldPrimary
                      : AppConstants.textMuted,
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
    final count = ref.watch(tasbihSessionProvider(tasbih.id));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Arabic title
        Text(
          tasbih.titleAr,
          style: const TextStyle(
            color: AppConstants.goldAccent,
            fontSize: 32,
            fontFamily: 'NotoNaskhArabic',
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // Transliteration + meaning
        Text(
          tasbih.transliteration,
          style: const TextStyle(
            color: AppConstants.textPrimary,
            fontSize: AppConstants.fontSubtitle,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (tasbih.meaning != null) ...[
          const SizedBox(height: 4),
          Text(
            tasbih.meaning!,
            style: const TextStyle(
              color: AppConstants.textMuted,
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
                  AppConstants.emeraldPrimary.withValues(alpha: 0.20),
                  AppConstants.surfaceDark,
                ],
              ),
              border: Border.all(
                color: AppConstants.emeraldPrimary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: AppConstants.emeraldPrimary,
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '/ ${tasbih.target}',
                    style: const TextStyle(
                      color: AppConstants.textMuted,
                      fontSize: AppConstants.fontSubtitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spaceLg),

        // Tap hint
        const Text(
          'Tap to count  •  Long press to undo',
          style: TextStyle(
            color: AppConstants.textFaint,
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
    final lifetimeAsync = ref.watch(tasbihLifetimeProvider(tasbihId));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: AppConstants.surfaceDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppConstants.dividerColor),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              color: AppConstants.goldAccent,
              size: 22,
            ),
            const SizedBox(width: AppConstants.spaceMd),
            const Expanded(
              child: Text(
                'Lifetime total',
                style: TextStyle(
                  color: AppConstants.textMuted,
                  fontSize: AppConstants.fontBody,
                ),
              ),
            ),
            lifetimeAsync.when(
              loading: () => const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppConstants.goldAccent,
                ),
              ),
              error: (_, __) => const Text('—'),
              data: (total) => Text(
                '$total',
                style: const TextStyle(
                  color: AppConstants.goldAccent,
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
