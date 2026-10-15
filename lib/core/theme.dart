import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

/// Central theme factory.
///
/// Provides two themes:
/// - [dark] — Deep AMOLED black with emerald accents (default)
/// - [light] — Cream white with mint green accents
///
/// All widget colors should come from [AppColors] (see app_colors.dart),
/// NOT from this file. This file only wires up Material's own widgets.
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────
  // SHARED LIGHT PALETTE
  // ─────────────────────────────────────────────
  static const Color _lightBg = Color(0xFFF0F7F3);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF0B3D2E);
  static const Color _lightTextMuted = Color(0xFF5F6E67);
  static const Color _lightBorder = Color(0xFFB5D9C5);
  static const Color _lightDivider = Color(0xFFD5E5DC);
  static const Color _lightEmerald = Color(0xFF059669);

  // ─────────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────────
  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppConstants.emeraldPrimary,
      onPrimary: Colors.black,
      secondary: AppConstants.goldAccent,
      onSecondary: Colors.black,
      surface: AppConstants.surfaceDark,
      onSurface: AppConstants.textPrimary,
      surfaceContainerHighest: AppConstants.surfaceDarker,
      error: Color(0xFFEF4444),
      onError: Colors.white,
      outline: AppConstants.dividerColor,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppConstants.deepDark,
      canvasColor: AppConstants.deepDark,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: _buildDarkTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.deepDark,
        foregroundColor: AppConstants.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: AppConstants.textPrimary,
          fontSize: AppConstants.fontHeading,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          side: BorderSide(
            color: AppConstants.emeraldPrimary.withValues(alpha: 0.20),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.emeraldPrimary,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceXl,
            vertical: AppConstants.spaceLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSubtitle,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.emeraldPrimary,
          side: const BorderSide(color: AppConstants.emeraldPrimary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceXl,
            vertical: AppConstants.spaceLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.emeraldPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(
            color: AppConstants.emeraldPrimary.withValues(alpha: 0.20),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(
            color: AppConstants.emeraldPrimary,
            width: 1.5,
          ),
        ),
        hintStyle: const TextStyle(color: AppConstants.textFaint),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppConstants.emeraldPrimary;
          }
          return AppConstants.textFaint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppConstants.emeraldPrimary.withValues(alpha: 0.35);
          }
          return AppConstants.dividerColor;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppConstants.dividerColor,
        thickness: 0.6,
        space: 0.6,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.amoledBlack,
        selectedItemColor: AppConstants.emeraldPrimary,
        unselectedItemColor: AppConstants.textFaint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(
        color: AppConstants.textPrimary,
        size: 22,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppConstants.emeraldPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.surfaceDark,
        contentTextStyle: const TextStyle(color: AppConstants.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppConstants.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          side: BorderSide(
            color: AppConstants.emeraldPrimary.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: _lightEmerald,
      onPrimary: Colors.white,
      secondary: Color(0xFFB7862B),
      onSecondary: Colors.white,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      surfaceContainerHighest: Color(0xFFEEF9F3),
      error: Color(0xFFDC2626),
      onError: Colors.white,
      outline: _lightBorder,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBg,
      canvasColor: _lightBg,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: _buildLightTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBg,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: AppConstants.fontHeading,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          side: const BorderSide(color: _lightBorder, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightEmerald,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceXl,
            vertical: AppConstants.spaceLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSubtitle,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightEmerald,
          side: const BorderSide(color: _lightEmerald),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceXl,
            vertical: AppConstants.spaceLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightEmerald,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: _lightEmerald, width: 1.5),
        ),
        hintStyle: const TextStyle(color: _lightTextMuted),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return _lightTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightEmerald.withValues(alpha: 0.55);
          }
          return _lightDivider;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightDivider,
        thickness: 0.6,
        space: 0.6,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: _lightEmerald,
        unselectedItemColor: _lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(
        color: _lightTextPrimary,
        size: 22,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _lightEmerald,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightSurface,
        contentTextStyle: const TextStyle(color: _lightTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          side: const BorderSide(color: _lightBorder),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TEXT THEMES
  // ─────────────────────────────────────────────
  static TextTheme _buildDarkTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: AppConstants.textPrimary,
        fontSize: AppConstants.fontDisplay,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: AppConstants.textPrimary,
        fontSize: AppConstants.fontTitle,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: AppConstants.textPrimary,
        fontSize: AppConstants.fontHeading,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: AppConstants.textPrimary,
        fontSize: AppConstants.fontSubtitle,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: AppConstants.textPrimary,
        fontSize: AppConstants.fontSubtitle,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: AppConstants.textPrimary,
        fontSize: AppConstants.fontBody,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: AppConstants.textMuted,
        fontSize: AppConstants.fontCaption,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: AppConstants.textMuted,
        fontSize: AppConstants.fontMicro,
        letterSpacing: 0.4,
      ),
    );
  }

  static TextTheme _buildLightTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: _lightTextPrimary,
        fontSize: AppConstants.fontDisplay,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: _lightTextPrimary,
        fontSize: AppConstants.fontTitle,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: _lightTextPrimary,
        fontSize: AppConstants.fontHeading,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: _lightTextPrimary,
        fontSize: AppConstants.fontSubtitle,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: _lightTextPrimary,
        fontSize: AppConstants.fontSubtitle,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: _lightTextPrimary,
        fontSize: AppConstants.fontBody,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: _lightTextMuted,
        fontSize: AppConstants.fontCaption,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: _lightTextMuted,
        fontSize: AppConstants.fontMicro,
        letterSpacing: 0.4,
      ),
    );
  }
}
