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
