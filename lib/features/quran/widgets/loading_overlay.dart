import 'package:flutter/material.dart';

import '../../../core/constants.dart';

/// Full-screen loading overlay shown while the Quran SQLite DB is
/// being populated for the first time.
class LoadingOverlay extends StatelessWidget {
  final String stage;
  final double progress;

  const LoadingOverlay({
    super.key,
    required this.stage,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.amoledBlack.withValues(alpha: 0.94),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.space2xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppConstants.emeraldPrimary,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXl),

              // Title
              const Text(
                'Preparing the Quran',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: AppConstants.fontHeading,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),

              // Stage
              Text(
                stage,
                style: const TextStyle(
                  color: AppConstants.textMuted,
                  fontSize: AppConstants.fontBody,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceXl),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppConstants.surfaceDark,
                  valueColor: const AlwaysStoppedAnimation(
                    AppConstants.emeraldPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),

              // Percentage
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppConstants.emeraldPrimary,
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: AppConstants.spaceXl),

              // Hint
              const Text(
                'This happens only once. '
                'After this, the Quran opens instantly, fully offline.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppConstants.textFaint,
                  fontSize: AppConstants.fontCaption,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
