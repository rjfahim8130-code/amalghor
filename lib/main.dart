import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data; // ← নতুন
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/constants.dart';
import 'providers/notification_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';
import 'services/alarm_service.dart';
import 'services/custom_notification_service.dart';
import 'services/notification_service.dart';

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

  // ─── TimeZone Initialize (Must before any tz.local) ───
  tz_data.initializeTimeZones();
  try {
    final localName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localName.identifier));
  } catch (_) {
    // Fallback to UTC if detection fails
  }

  final prefs = await SharedPreferences.getInstance();

  // Initialize all three notification channels.
  try {
    await NotificationService.instance.initialize();
    await AlarmService.instance.initialize(prefs);
    await CustomNotificationService.instance.initialize(prefs);
  } catch (_) {
    // Non-fatal.
  }

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _bootstrapPrayerNotifications(container);
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AmalghorApp(),
    ),
  );
}

Future<void> _bootstrapPrayerNotifications(
  ProviderContainer container,
) async {
  try {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await container.read(notificationProvider.notifier).requestPermission();
    await container.read(currentDayPrayerProvider.future);
    await container.read(notificationProvider.notifier).reschedule();
  } catch (_) {
    // Never block the app.
  }
}
