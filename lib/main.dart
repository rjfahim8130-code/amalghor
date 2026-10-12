import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/constants.dart';
import 'services/notification_service.dart';

/// Application entry point.
///
/// Responsibilities:
/// - Ensures Flutter bindings are ready
/// - Locks portrait orientation
/// - Initializes locale data for date formatting
/// - Bootstraps the local notification subsystem
/// - Boots the Riverpod provider container
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode — this is a dashboard-style app.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI style: transparent status bar, dark nav bar.
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

  // Bootstrap notifications (non-fatal if it fails).
  try {
    await NotificationService.instance.initialize();
  } catch (_) {
    // Notifications are optional — app still works without them.
  }

  runApp(
    const ProviderScope(
      child: AmalghorApp(),
    ),
  );
}
