import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/models/amol_models.dart';
import '../../l10n/generated/app_localizations.dart';

/// Daily Amol tracker. Shows the shipped default Amols and lets the
/// user tick them off. (Persistence is wired in a later iteration —
/// the UI is fully functional with in-memory state.)
class AmolScreen extends ConsumerStatefulWidget {
  const AmolScreen({super.key});

  @override
  ConsumerState<AmolScreen> createState() => _AmolScreenState();
}

class _AmolScreenState extends ConsumerState<AmolScreen> {
  /// Local in-memory state; replaced with DB later.
  final Map<String, int> _counts = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final amols = DefaultAmols.all;

    final done = amols.where((a) {
      final c = _counts[a.id] ?? 0;
      return a.targetCount != null && c >= a.targetCount!;
    }).length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.amolTitle)),
      body: Column(
        children: [
          _ProgressHeader(
            done: done,
            total: amols.length,
            l10n: l10n,
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceLg,
                vertical: AppConstants.spaceLg,
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
    final progress = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: const BoxDecoration(
        color: AppConstants.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppConstants.dividerColor, width: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppConstants.emeraldPrimary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                l10n.amolTracker,
                style: const TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$done / $total',
                style: const TextStyle(
                  color: AppConstants.emeraldPrimary,
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
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
              backgroundColor: AppConstants.surfaceDarker,
              valueColor: const AlwaysStoppedAnimation(
                AppConstants.emeraldPrimary,
              ),
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
    final target = amol.targetCount ?? 1;
    final isDone = count >= target;

    return InkWell(
      onTap: onIncrement,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: AppConstants.surfaceDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: isDone
                ? AppConstants.emeraldPrimary.withValues(alpha: 0.5)
                : AppConstants.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDone
                    ? AppConstants.emeraldPrimary.withValues(alpha: 0.18)
                    : AppConstants.surfaceDarker,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Icon(
                _iconFor(amol.category),
                color: isDone
                    ? AppConstants.emeraldPrimary
                    : AppConstants.textMuted,
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
                    style: const TextStyle(
                      color: AppConstants.textPrimary,
                      fontSize: AppConstants.fontBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (amol.arabicText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        amol.arabicText!,
                        style: const TextStyle(
                          color: AppConstants.goldAccent,
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
                      ? AppConstants.emeraldPrimary
                      : AppConstants.surfaceDarker,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  '$count/$target',
                  style: TextStyle(
                    color: isDone
                        ? Colors.black
                        : AppConstants.textPrimary,
                    fontSize: AppConstants.fontCaption,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              )
            else
              Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone
                    ? AppConstants.emeraldPrimary
                    : AppConstants.textFaint,
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
