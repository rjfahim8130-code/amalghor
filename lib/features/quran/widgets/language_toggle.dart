import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../data/models/quran_models.dart';
import '../../../providers/quran_provider.dart';

/// A compact, always-visible control strip that lets the user toggle
/// which languages appear in the reader.
///
/// Layout:
///   Row 1: Preset buttons (Arabic only, Bangla only, English only, All)
///   Row 2: Individual chips — Arabic, Bangla, English
///
/// The widget observes [quranDisplayProvider] so its state is always
/// in sync with the rest of the reader.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(quranDisplayProvider);
    final notifier = ref.read(quranDisplayProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        border: const Border(
          bottom: BorderSide(color: AppConstants.dividerColor, width: 0.6),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Row 1: Language chips ────────────
          Row(
            children: [
              Expanded(
                child: _LanguageChip(
                  label: 'عربي',
                  sublabel: 'Arabic',
                  isActive: display.showArabic,
                  onTap: () => notifier.setArabic(!display.showArabic),
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: _LanguageChip(
                  label: 'বাংলা',
                  sublabel: 'Bangla',
                  isActive: display.showBangla,
                  onTap: () => notifier.setBangla(!display.showBangla),
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: _LanguageChip(
                  label: 'English',
                  sublabel: 'English',
                  isActive: display.showEnglish,
                  onTap: () => notifier.setEnglish(!display.showEnglish),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceSm),

          // ─── Row 2: Quick presets ─────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PresetButton(
                  label: 'All',
                  isSelected: display == QuranDisplayMode.allThree ||
                      (display.showArabic &&
                          display.showBangla &&
                          display.showEnglish),
                  onTap: () => notifier.applyPreset(
                    QuranDisplayMode.allThree,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceXs),
                _PresetButton(
                  label: 'عربي + বাংলা',
                  isSelected: display.showArabic &&
                      display.showBangla &&
                      !display.showEnglish,
                  onTap: () => notifier.applyPreset(
                    QuranDisplayMode.arabicBangla,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceXs),
                _PresetButton(
                  label: 'عربي + EN',
                  isSelected: display.showArabic &&
                      !display.showBangla &&
                      display.showEnglish,
                  onTap: () => notifier.applyPreset(
                    QuranDisplayMode.arabicEnglish,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceXs),
                _PresetButton(
                  label: 'বাংলা + EN',
                  isSelected: !display.showArabic &&
                      display.showBangla &&
                      display.showEnglish,
                  onTap: () => notifier.applyPreset(
                    QuranDisplayMode.banglaEnglish,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceXs),
                _PresetButton(
                  label: 'Only عربي',
                  isSelected: display.showArabic &&
                      !display.showBangla &&
                      !display.showEnglish,
                  onTap: () => notifier.applyPreset(
                    QuranDisplayMode.arabicOnly,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceXs),
                _PresetButton(
                  label: 'Only বাংলা',
                  isSelected: !display.showArabic &&
                      display.showBangla &&
                      !display.showEnglish,
                  onTap: () => notifier.applyPreset(
                    QuranDisplayMode.banglaOnly,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceXs),
                _PresetButton(
                  label: 'Only English',
                  isSelected: !display.showArabic &&
                      !display.showBangla &&
                      display.showEnglish,
                  onTap: () => notifier.applyPreset(
                    QuranDisplayMode.englishOnly,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LANGUAGE CHIP
// ─────────────────────────────────────────────
class _LanguageChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isActive;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.sublabel,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMd,
            vertical: AppConstants.spaceSm,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppConstants.emeraldPrimary.withValues(alpha: 0.15)
                : AppConstants.surfaceDarker,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: isActive
                  ? AppConstants.emeraldPrimary
                  : AppConstants.dividerColor,
              width: isActive ? 1.4 : 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? AppConstants.emeraldPrimary
                      : AppConstants.textMuted,
                  fontSize: AppConstants.fontBody,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  color: isActive
                      ? AppConstants.emeraldPrimary.withValues(alpha: 0.7)
                      : AppConstants.textFaint,
                  fontSize: AppConstants.fontMicro,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRESET BUTTON
// ─────────────────────────────────────────────
class _PresetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.isSelected,
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
            horizontal: AppConstants.spaceMd,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppConstants.emeraldPrimary.withValues(alpha: 0.20)
                : AppConstants.surfaceDarker,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            border: Border.all(
              color: isSelected
                  ? AppConstants.emeraldPrimary.withValues(alpha: 0.6)
                  : AppConstants.dividerColor,
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppConstants.emeraldPrimary
                  : AppConstants.textMuted,
              fontSize: AppConstants.fontMicro,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
