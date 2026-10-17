import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants.dart';
import 'providers/notification_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConstants.amoledBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await initializeDateFormatting();

  final prefs = await SharedPreferences.getInstance();

  // Initialize notifications (non-fatal on failure).
  try {
    await NotificationService.instance.initialize();
  } catch (_) {
    // Ignore — app still works without notifications.
  }

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Schedule prayer notifications in the background on launch.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _bootstrapNotifications(container);
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AmalghorApp(),
    ),
  );
}

/// Ask for permissions once (silently — Android will prompt), then
/// schedule today's prayer notifications.
Future<void> _bootstrapNotifications(ProviderContainer container) async {
  try {
    // Small delay to let the first frame settle.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // Ask for permission (silent no-op if already granted).
    await container.read(notificationProvider.notifier).requestPermission();

    // Wait for prayer times to be available.
    await container.read(currentDayPrayerProvider.future);

    // Schedule notifications.
    await container.read(notificationProvider.notifier).reschedule();
  } catch (_) {
    // Never block the app on a notification failure.
  }
}
