import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';

/// Application entry point.
///
/// Initializes:
///   - Flutter bindings
///   - Portrait orientation lock
///   - System UI styling
///   - intl locale data
///   - SharedPreferences (MUST be ready before ProviderScope)
///   - Local notifications (non-fatal)
///   - Riverpod container with SharedPreferences override
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI style.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConstants.amoledBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize locale data for intl-based date formatting.
  await initializeDateFormatting();

  // ─────────────────────────────────────────────
  // SharedPreferences — MUST resolve before runApp().
  // Without this override, sharedPreferencesProvider throws
  // UnimplementedError and the app shows a blank screen.
  // ─────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();

  // Bootstrap notifications (non-fatal if it fails).
  try {
    await NotificationService.instance.initialize();
  } catch (_) {
    // Notifications are optional — app still works without them.
  }

  runApp(
    ProviderScope(
      overrides: [
        // This override is what fixes the blank screen.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const AmalghorApp(),
    ),
  );
}
