import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:amalghor/core/services/app_settings_service.dart';
import 'package:amalghor/core/theme/app_theme.dart';
import 'package:amalghor/core/constants/app_constants.dart';
import 'package:amalghor/features/home/presentation/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final settings = AppSettingsService();
  await settings.init();

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: const AmalghorApp(),
    ),
  );
}

class AmalghorApp extends StatelessWidget {
  const AmalghorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsService>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode == ThemeModeOption.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const MainShell(),
        );
      },
    );
  }
}
