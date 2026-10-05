import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:amalghor/core/services/app_settings_service.dart';
import 'package:amalghor/core/theme/app_theme.dart';
import 'package:amalghor/features/home/presentation/home_screen.dart';
import 'package:amalghor/features/prayer/presentation/prayer_screen.dart';
import 'package:amalghor/features/quran/presentation/quran_screen.dart';
import 'package:amalghor/features/ramadan/presentation/ramadan_screen.dart';
import 'package:amalghor/features/amal/presentation/amal_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PrayerScreen(),
    QuranScreen(),
    RamadanScreen(),
    AmalScreen(),
  ];

  DateTime? _lastBackPress;

  Future<bool> _onWillPop() async {
    // If not on Home, go back to Home first
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }

    // Double back to exit
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppSettingsService>().t(
                  'আবার ব্যাক চাপুন অ্যাপ থেকে বের হতে',
                  'Press back again to exit',
                ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.cardElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsService>();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                HapticFeedback.lightImpact();
                setState(() => _currentIndex = index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_rounded),
                  activeIcon: const Icon(Icons.home_rounded),
                  label: settings.t('হোম', 'Home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.mosque_rounded),
                  activeIcon: const Icon(Icons.mosque_rounded),
                  label: settings.t('নামাজ', 'Prayer'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.menu_book_rounded),
                  activeIcon: const Icon(Icons.menu_book_rounded),
                  label: settings.t('কুরআন', 'Quran'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.nightlight_round),
                  activeIcon: const Icon(Icons.nightlight_round),
                  label: settings.t('রমজান', 'Ramadan'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  activeIcon: const Icon(Icons.check_circle_rounded),
                  label: settings.t('আমল', 'Amal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
