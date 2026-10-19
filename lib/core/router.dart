import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/alarm/alarm_screen.dart';
import '../features/amol/amol_screen.dart';
import '../features/asma/asma_screen.dart';
import '../features/calendar/islamic_calendar_screen.dart';
import '../features/dua/dua_category_screen.dart';
import '../features/dua/dua_detail_screen.dart';
import '../features/dua/dua_list_screen.dart';
import '../features/home/home_screen.dart';
import '../features/location/location_picker_screen.dart';
import '../features/notification/notification_screen.dart';
import '../features/pdf/pdf_preview_screen.dart';
import '../features/pdf/pdf_settings_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/quran/bookmark_feature.dart';
import '../features/quran/mushaf_reader_screen.dart';
import '../features/quran/quran_mode_select_screen.dart';
import '../features/quran/quran_screen.dart';
import '../features/quran/surah_reader_screen.dart';
import '../features/ramadan/ramadan_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/tasbih/tasbih_screen.dart';
import '../l10n/generated/app_localizations.dart';

class Routes {
  Routes._();
  static const String home = '/';
  static const String prayer = '/prayer';
  static const String quran = '/quran';
  static const String quranRegular = '/quran/regular';
  static const String quranMushaf = '/quran/mushaf';
  static const String ramadan = '/ramadan';
  static const String amol = '/amol';
  static const String settings = '/settings';
  static const String location = '/location';
  static const String quranBookmarks = '/quran/bookmarks';
  static const String surahReader = '/quran/:surahNumber';
  static const String pdfSettings = '/pdf';
  static const String pdfPreview = '/pdf/preview';
  static const String qibla = '/qibla';
  static const String tasbih = '/tasbih';
  static const String asma = '/asma';
  static const String calendar = '/calendar';
  static const String dua = '/dua';
  static const String duaCategory = '/dua/category/:categoryId';
  static const String duaDetail = '/dua/detail/:duaId';
  static const String alarms = '/alarms';
  static const String notifications = '/notifications';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    routes: <RouteBase>[
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
          // Quran tab → mode select (Hafezi / Regular)
          GoRoute(
            path: Routes.quran,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: QuranModeSelectScreen()),
            routes: [
              GoRoute(
                path: 'regular',
                builder: (context, state) => const QuranScreen(),
              ),
              GoRoute(
                path: 'bookmarks',
                builder: (context, state) => const BookmarkScreen(),
              ),
              GoRoute(
                path: 'mushaf',
                builder: (context, state) {
                  final pageParam = state.uri.queryParameters['page'];
                  final page = int.tryParse(pageParam ?? '');
                  return MushafReaderScreen(initialPage: page);
                },
              ),
              // :surahNumber must come after regular/mushaf/bookmarks
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
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.location,
        builder: (context, state) => const LocationPickerScreen(),
      ),
      GoRoute(
        path: Routes.pdfSettings,
        builder: (context, state) => const PdfSettingsScreen(),
      ),
      GoRoute(
        path: Routes.pdfPreview,
        builder: (context, state) => const PdfPreviewScreen(),
      ),
      GoRoute(
        path: Routes.qibla,
        builder: (context, state) => const QiblaScreen(),
      ),
      GoRoute(
        path: Routes.tasbih,
        builder: (context, state) => const TasbihScreen(),
      ),
      GoRoute(
        path: Routes.asma,
        builder: (context, state) => const AsmaScreen(),
      ),
      GoRoute(
        path: Routes.calendar,
        builder: (context, state) => const IslamicCalendarScreen(),
      ),
      GoRoute(
        path: Routes.dua,
        builder: (context, state) => const DuaListScreen(),
      ),
      GoRoute(
        path: Routes.duaCategory,
        builder: (context, state) {
          final id = state.pathParameters['categoryId'] ?? '';
          return DuaCategoryScreen(categoryId: id);
        },
      ),
      GoRoute(
        path: Routes.duaDetail,
        builder: (context, state) {
          final id = state.pathParameters['duaId'] ?? '';
          return DuaDetailScreen(duaId: id);
        },
      ),
      GoRoute(
        path: Routes.alarms,
        builder: (context, state) => const AlarmScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
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
                Text(
                  l10n.pageNotFound,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                  ),
                  child: Text(l10n.goHome),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
});
