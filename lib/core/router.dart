import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/amol/amol_screen.dart';
import '../features/home/home_screen.dart';
import '../features/location/location_picker_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/quran/quran_screen.dart';
import '../features/ramadan/ramadan_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';

/// Route paths — single source of truth.
class Routes {
  Routes._();
  static const String home = '/';
  static const String prayer = '/prayer';
  static const String quran = '/quran';
  static const String ramadan = '/ramadan';
  static const String amol = '/amol';
  static const String settings = '/settings';
  static const String location = '/location';
}

/// Riverpod-wrapped GoRouter.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      // ─── Shell (bottom navigation) ─────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: Routes.prayer,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PrayerScreen()),
          ),
          GoRoute(
            path: Routes.quran,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: QuranScreen()),
          ),
          GoRoute(
            path: Routes.ramadan,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RamadanScreen()),
          ),
          GoRoute(
            path: Routes.amol,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AmolScreen()),
          ),
        ],
      ),

      // ─── Full-screen (no bottom nav) ───────────
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.location,
        builder: (context, state) => const LocationPickerScreen(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
