import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

/// Central theme factory.
///
/// Provides two themes:
/// - [dark] — Deep AMOLED black with emerald accents (default)
/// - [light] — Clean light theme for daytime / accessibility
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────
  // DARK THEME (default)
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
      // ─── Text ────────────────────────────────
      textTheme: _buildTextTheme(base.textTheme, isDark: true),

      // ─── AppBar ──────────────────────────────
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

      // ─── Cards ───────────────────────────────
      cardTheme: CardThemeData(
        color: AppConstants.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          side: BorderSide(
            color: AppConstants.emeraldPrimary.withValues(alpha: 0.20),
            width: 1.0,
          ),
        ),
      ),

      // ─── Buttons ─────────────────────────────
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

      // ─── Inputs ──────────────────────────────
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

      // ─── Switches & Sliders ──────────────────
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

      // ─── Dividers ────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppConstants.dividerColor,
        thickness: 0.6,
        space: 0.6,
      ),

      // ─── Bottom Navigation ───────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.amoledBlack,
        selectedItemColor: AppConstants.emeraldPrimary,
        unselectedItemColor: AppConstants.textFaint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: AppConstants.fontMicro,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(fontSize: AppConstants.fontMicro),
      ),

      // ─── Icons ───────────────────────────────
      iconTheme: const IconThemeData(
        color: AppConstants.textPrimary,
        size: 22,
      ),

      // ─── Progress ────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppConstants.emeraldPrimary,
      ),

      // ─── Snackbar ────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.surfaceDark,
        contentTextStyle: const TextStyle(color: AppConstants.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── Dialog ──────────────────────────────
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
      primary: AppConstants.emeraldPrimary,
      onPrimary: Colors.white,
      secondary: AppConstants.goldAccent,
      surface: AppConstants.lightSurface,
      onSurface: AppConstants.lightTextPrimary,
      error: Color(0xFFDC2626),
      outline: Color(0xFFE5E7EB),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppConstants.lightBg,
      canvasColor: AppConstants.lightBg,
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme, isDark: false),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.lightBg,
        foregroundColor: AppConstants.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: AppConstants.lightTextPrimary,
          fontSize: AppConstants.fontHeading,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 0.6,
        space: 0.6,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.lightSurface,
        selectedItemColor: AppConstants.emeraldPrimary,
        unselectedItemColor: AppConstants.lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SHARED TEXT THEME
  // ─────────────────────────────────────────────
  static TextTheme _buildTextTheme(TextTheme base, {required bool isDark}) {
    final primary = isDark
        ? AppConstants.textPrimary
        : AppConstants.lightTextPrimary;
    final muted = isDark
        ? AppConstants.textMuted
        : AppConstants.lightTextMuted;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: primary,
        fontSize: AppConstants.fontDisplay,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: primary,
        fontSize: AppConstants.fontTitle,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primary,
        fontSize: AppConstants.fontHeading,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primary,
        fontSize: AppConstants.fontSubtitle,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: primary,
        fontSize: AppConstants.fontSubtitle,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: primary,
        fontSize: AppConstants.fontBody,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: muted,
        fontSize: AppConstants.fontCaption,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: muted,
        fontSize: AppConstants.fontMicro,
        letterSpacing: 0.4,
      ),
    );
  }
}
