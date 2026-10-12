import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/settings_provider.dart';

/// Root application widget.
///
/// Wires together:
/// - Theme (dark AMOLED / light)
/// - Localization (English / Bangla / Arabic)
/// - Routing (single-source navigator)
/// - Riverpod-driven settings state
class AmalghorApp extends ConsumerWidget {
  const AmalghorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final locale = settings.locale;
    final themeMode = settings.themeMode;

    return MaterialApp.router(
      // ─── Identification ────────────────────────
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ─── Theme ─────────────────────────────────
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      // ─── Localization ──────────────────────────
      locale: locale,
      supportedLocales: AppConstants.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supported) {
        // If user hasn't picked a locale manually, try to match device locale.
        if (deviceLocale != null) {
          for (final loc in supported) {
            if (loc.languageCode == deviceLocale.languageCode) return loc;
          }
        }
        return const Locale('en');
      },

      // ─── Routing ───────────────────────────────
      routerConfig: ref.watch(routerProvider),

      // ─── Global builders ───────────────────────
      builder: (context, child) {
        // Clamp text scaling to prevent layout breaks on accessibility sizes.
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(
              mediaQuery.textScaler.scale(1.0).clamp(0.85, 1.30),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
