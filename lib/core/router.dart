import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/amol/amol_screen.dart';
import '../features/home/home_screen.dart';
import '../features/location/location_picker_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/quran/bookmark_feature.dart';
import '../features/quran/quran_screen.dart';
import '../features/quran/surah_reader_screen.dart';
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
  static const String quranBookmarks = '/quran/bookmarks';
  static const String surahReader = '/quran/:surahNumber';
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
            routes: [
              // Nested: /quran/bookmarks
              GoRoute(
                path: 'bookmarks',
                builder: (context, state) => const BookmarkScreen(),
              ),
              // Nested: /quran/:surahNumber?ayah=N
              GoRoute(
                path: ':surahNumber',
                builder: (context, state) {
                  final surahParam =
                      state.pathParameters['surahNumber'] ?? '1';
                  final surahNumber = int.tryParse(surahParam) ?? 1;
                  final ayahParam = state.uri.queryParameters['ayah'];
                  final initialAyah =
                      ayahParam != null ? int.tryParse(ayahParam) : null;
                  return SurahReaderScreen(
                    surahNumber: surahNumber,
                    initialAyah: initialAyah,
                  );
                },
              ),
            ],
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
      backgroundColor: const Color(0xFF0B0F12),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFEF4444),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.uri}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
