import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../l10n/generated/app_localizations.dart';

/// Quran tab entry: choose Hafezi (tilawat) or Regular (translation).
class QuranModeSelectScreen extends ConsumerWidget {
  const QuranModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Text(
          l10n.quranTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Text(
              l10n.quranChooseMode,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: AppConstants.fontBody,
              ),
            ),
            const SizedBox(height: 24),
            _ModeCard(
              icon: Icons.menu_book_rounded,
              title: l10n.quranHafeziTitle,
              subtitle: l10n.quranHafeziSubtitle,
              colors: colors,
              onTap: () => context.push('/quran/mushaf'),
            ),
            const SizedBox(height: 16),
            _ModeCard(
              icon: Icons.translate_rounded,
              title: l10n.quranRegularTitle,
              subtitle: l10n.quranRegularSubtitle,
              colors: colors,
              onTap: () => context.push('/quran/regular'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final AppColors colors;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            gradient: colors.prayerCardGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(color: colors.border, width: 1.2),
            boxShadow: colors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: colors.iconBorder),
                ),
                child: Icon(icon, color: colors.emerald, size: 28),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppConstants.fontSubtitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: AppConstants.fontCaption,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.emerald),
            ],
          ),
        ),
      ),
    );
  }
}
