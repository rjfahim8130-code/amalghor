import 'package:flutter/material.dart';

/// Context-aware color palette.
///
/// Usage:
///   final c = AppColors.of(context);
///   Container(color: c.pageBackground, child: ...)
///
/// Resolves all UI colors based on the current theme brightness.
class AppColors {
  final bool isDark;
  const AppColors._(this.isDark);

  factory AppColors.of(BuildContext context) {
    return AppColors._(
      Theme.of(context).brightness == Brightness.dark,
    );
  }

  factory AppColors.ofBrightness(Brightness brightness) {
    return AppColors._(brightness == Brightness.dark);
  }

  // ─────────────────────────────────────────────
  // BACKGROUNDS
  // ─────────────────────────────────────────────

  /// Full-page scaffold background.
  Color get pageBackground =>
      isDark ? const Color(0xFF080B0E) : const Color(0xFFF0F7F3);

  /// Standard card background.
  Color get cardBackground =>
      isDark ? const Color(0xFF111A1E) : const Color(0xFFFFFFFF);

  /// Slightly darker/lighter cards (nested items).
  Color get cardBackgroundSubtle =>
      isDark ? const Color(0xFF0D1418) : const Color(0xFFF6FBF8);

  /// Tool tile background.
  Color get toolTileBackground =>
      isDark ? const Color(0xFF0F1F1A) : const Color(0xFFFFFFFF);

  /// Top-level surface that isn't quite a card (inputs, chips).
  Color get surfaceElevated =>
      isDark ? const Color(0xFF111A1E) : const Color(0xFFFFFFFF);

  /// Deepest inset (behind ticker areas, progress tracks).
  Color get surfaceInset =>
      isDark ? const Color(0xFF080B0E) : const Color(0xFFE5F0EA);

  /// Bottom navigation bar background.
  Color get navBackground =>
      isDark ? const Color(0xFF080B0E) : const Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────
  // TEXT
  // ─────────────────────────────────────────────

  /// Primary heading text.
  Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0B3D2E);

  /// Body text on cards.
  Color get textSecondary =>
      isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F4A3A);

  /// Muted captions.
  Color get textMuted =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF5F6E67);

  /// Very faint text (hints, disabled).
  Color get textFaint =>
      isDark ? const Color(0xFF6B7280) : const Color(0xFF8A9A91);

  /// Text on emerald-filled buttons.
  Color get textOnEmerald =>
      isDark ? Colors.black : Colors.white;

  // ─────────────────────────────────────────────
  // ACCENTS (same hue, different intensity)
  // ─────────────────────────────────────────────

  /// Primary emerald — greener in dark, slightly deeper in light.
  Color get emerald =>
      isDark ? const Color(0xFF10B981) : const Color(0xFF059669);

  /// Emerald for badges/icons on light surfaces.
  Color get emeraldSoft =>
      isDark ? const Color(0xFF10B981) : const Color(0xFF0E8A6B);

  /// Emerald glow (for shadows).
  Color get emeraldGlow =>
      isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.25)
          : const Color(0xFF059669).withValues(alpha: 0.10);

  /// Cyan accent (Hijri date, clock icon).
  Color get cyan =>
      isDark ? const Color(0xFF22D3EE) : const Color(0xFF0891B2);

  /// Gold accent (Bangla date, Friday marker).
  Color get gold =>
      isDark ? const Color(0xFFD4A24A) : const Color(0xFFB7862B);

  // ─────────────────────────────────────────────
  // BORDERS & DIVIDERS
  // ─────────────────────────────────────────────

  /// Card border color.
  Color get border =>
      isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.30)
          : const Color(0xFFB5D9C5);

  /// Softer border for nested items.
  Color get borderSubtle =>
      isDark
          ? const Color(0xFF1F2937)
          : const Color(0xFFDCEAE1);

  /// Strong border for emphasis.
  Color get borderStrong =>
      isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.55)
          : const Color(0xFF7BBF9B);

  /// Divider lines.
  Color get divider =>
      isDark ? const Color(0xFF1F2937) : const Color(0xFFD5E5DC);

  // ─────────────────────────────────────────────
  // GRADIENTS
  // ─────────────────────────────────────────────

  /// Big clock card background.
  LinearGradient get clockGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xFF0E1A16), Color(0xFF0D1418)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : const LinearGradient(
          colors: [Color(0xFFE8F5EE), Color(0xFFD4EDDF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  /// Current prayer card background.
  LinearGradient get prayerCardGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xFF0D1F18), Color(0xFF0D1418)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFEEF9F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  /// Tool tile background.
  LinearGradient get toolTileGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xFF0F1F1A), Color(0xFF0A1310)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF1F9F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  /// Top glow gradient (behind header).
  LinearGradient get topGlow => isDark
      ? const LinearGradient(
          colors: [Color(0x1410B981), Color(0x00000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : const LinearGradient(
          colors: [Color(0x15059669), Color(0x00000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  /// Brand mark gradient.
  LinearGradient get brandGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF036B4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  // ─────────────────────────────────────────────
  // SHADOWS
  // ─────────────────────────────────────────────

  List<BoxShadow> get emeraldGlowSmall => [
        BoxShadow(
          color: isDark
              ? const Color(0xFF10B981).withValues(alpha: 0.15)
              : const Color(0xFF059669).withValues(alpha: 0.06),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  List<BoxShadow> get emeraldGlowMedium => [
        BoxShadow(
          color: isDark
              ? const Color(0xFF10B981).withValues(alpha: 0.22)
              : const Color(0xFF059669).withValues(alpha: 0.08),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ];

  /// Light mode uses subtle white card shadows instead of glows.
  List<BoxShadow> get cardShadow => isDark
      ? emeraldGlowSmall
      : [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ];

  // ─────────────────────────────────────────────
  // ICON BACKGROUNDS
  // ─────────────────────────────────────────────

  /// Icon circle background (behind tool icons).
  Color get iconBackground => isDark
      ? const Color(0xFF10B981).withValues(alpha: 0.14)
      : const Color(0xFFD4EDDF);

  /// Icon circle border.
  Color get iconBorder => isDark
      ? const Color(0xFF10B981).withValues(alpha: 0.30)
      : const Color(0xFFA7D9BF);

  // ─────────────────────────────────────────────
  // SPECIAL SURFACES
  // ─────────────────────────────────────────────

  /// The inner "next prayer" card inside the current status card.
  Color get innerCard => isDark
      ? const Color(0xFF080B0E).withValues(alpha: 0.50)
      : const Color(0xFFE1F1E7);

  /// The chip inside the clock card's date row.
  Color get calendarChip => isDark
      ? const Color(0xFF080B0E).withValues(alpha: 0.55)
      : const Color(0xFFFFFFFF);
}
