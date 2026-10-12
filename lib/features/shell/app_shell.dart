import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/router.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shell wrapper that hosts the persistent bottom navigation bar
/// across the five primary tabs.
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.toString();

    final tabs = <_NavTab>[
      _NavTab(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l10n.navHome,
        route: Routes.home,
      ),
      _NavTab(
        icon: Icons.mosque_outlined,
        activeIcon: Icons.mosque,
        label: l10n.navPrayer,
        route: Routes.prayer,
      ),
      _NavTab(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: l10n.navQuran,
        route: Routes.quran,
      ),
      _NavTab(
        icon: Icons.nightlight_outlined,
        activeIcon: Icons.nightlight_round,
        label: l10n.navRamadan,
        route: Routes.ramadan,
      ),
      _NavTab(
        icon: Icons.check_circle_outline,
        activeIcon: Icons.check_circle,
        label: l10n.navAmol,
        route: Routes.amol,
      ),
    ];

    final index = tabs.indexWhere(
      (t) => location == t.route || location.startsWith('${t.route}/'),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppConstants.dividerColor, width: 0.6),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: index >= 0 ? index : 0,
          onTap: (i) => context.go(tabs[i].route),
          items: tabs
              .map(
                (t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                  label: t.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
