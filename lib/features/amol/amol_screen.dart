import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../data/models/amol_models.dart';
import '../../l10n/generated/app_localizations.dart';

/// Daily Amol tracker with progress bar and per-item tapping.
class AmolScreen extends ConsumerStatefulWidget {
  const AmolScreen({super.key});

  @override
  ConsumerState<AmolScreen> createState() => _AmolScreenState();
}

class _AmolScreenState extends ConsumerState<AmolScreen> {
  final Map<String, int> _counts = {};

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final amols = DefaultAmols.all;

    final done = amols.where((a) {
      final c = _counts[a.id] ?? 0;
      return a.targetCount != null && c >= a.targetCount!;
    }).length;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Text(
          l10n.amolTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _ProgressHeader(
            done: done,
            total: amols.length,
            l10n: l10n,
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceLg,
                AppConstants.spaceLg,
                AppConstants.spaceLg,
                AppConstants.space2xl,
              ),
              itemCount: amols.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spaceMd),
              itemBuilder: (context, i) {
                final amol = amols[i];
                return _AmolTile(
                  amol: amol,
                  localeCode: localeCode,
                  count: _counts[amol.id] ?? 0,
                  onIncrement: () {
                    setState(() {
                      final target = amol.targetCount ?? 1;
                      final current = _counts[amol.id] ?? 0;
                      _counts[amol.id] =
                          current >= target ? 0 : current + 1;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int done;
  final int total;
  final AppLocalizations l10n;

  const _ProgressHeader({
    required this.done,
    required this.total,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final progress = total == 0 ? 0.0 : done / total;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceSm,
        AppConstants.spaceLg,
        0,
      ),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        gradient: colors.prayerCardGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: colors.border, width: 1.2),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: colors.emerald,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                l10n.amolTracker,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$done / $total',
                style: TextStyle(
                  color: colors.emerald,
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.surfaceInset,
              valueColor: AlwaysStoppedAnimation(colors.emerald),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmolTile extends StatelessWidget {
  final Amol amol;
  final String localeCode;
  final int count;
  final VoidCallback onIncrement;

  const _AmolTile({
    required this.amol,
    required this.localeCode,
    required this.count,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final target = amol.targetCount ?? 1;
    final isDone = count >= target;

    return InkWell(
      onTap: onIncrement,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isDone ? colors.borderStrong : colors.border,
            width: 1.2,
          ),
          boxShadow: colors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDone
                    ? colors.emerald.withValues(alpha: 0.15)
                    : colors.iconBackground,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: isDone
                    ? Border.all(color: colors.iconBorder)
                    : null,
              ),
              child: Icon(
                _iconFor(amol.category),
                color: isDone ? colors.emerald : colors.textMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amol.titleFor(localeCode),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: AppConstants.fontBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (amol.arabicText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        amol.arabicText!,
                        style: TextStyle(
                          color: colors.gold,
                          fontSize: AppConstants.fontSubtitle,
                          fontFamily: 'NotoNaskhArabic',
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (amol.targetCount != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                  vertical: AppConstants.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: isDone
                      ? colors.emerald
                      : colors.iconBackground,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusFull),
                  border: isDone
                      ? null
                      : Border.all(color: colors.iconBorder),
                ),
                child: Text(
                  '$count/$target',
                  style: TextStyle(
                    color: isDone
                        ? colors.textOnEmerald
                        : colors.textPrimary,
                    fontSize: AppConstants.fontCaption,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              )
            else
              Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? colors.emerald : colors.textFaint,
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(AmolCategory c) {
    switch (c) {
      case AmolCategory.tasbih:
        return Icons.radio_button_checked;
      case AmolCategory.dua:
        return Icons.pan_tool_outlined;
      case AmolCategory.dhikr:
        return Icons.spa_outlined;
      case AmolCategory.quranReading:
        return Icons.menu_book_outlined;
      case AmolCategory.salat:
        return Icons.mosque_outlined;
      case AmolCategory.custom:
        return Icons.star_outline;
    }
  }
}
