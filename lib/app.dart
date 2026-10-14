import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/onboarding_provider.dart';
import 'providers/settings_provider.dart';

/// Root application widget.
class AmalghorApp extends ConsumerWidget {
  const AmalghorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final onboarded = ref.watch(onboardingProvider);
    final locale = settings.locale;
    final themeMode = settings.themeMode;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ─── Theme ─────────────────────────────
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      // ─── Localization ──────────────────────
      locale: locale,
      supportedLocales: AppConstants.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supported) {
        if (deviceLocale != null) {
          for (final loc in supported) {
            if (loc.languageCode == deviceLocale.languageCode) return loc;
          }
        }
        return const Locale('bn');
      },

      // ─── Routing ───────────────────────────
      routerConfig: ref.watch(routerProvider),

      // ─── Builder ───────────────────────────
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clamped = MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(
              mediaQuery.textScaler.scale(1.0).clamp(0.85, 1.30),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );

        // Show onboarding until complete.
        if (!onboarded) {
          return OnboardingScreen(onComplete: () {});
        }
        return clamped;
      },
    );
  }
}
