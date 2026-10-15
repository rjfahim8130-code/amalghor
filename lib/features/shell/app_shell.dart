import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shell wrapper that hosts the persistent bottom navigation bar
/// across the five primary tabs.
///
/// Auto-adapts to dark or light mode via [AppColors].
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
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
        activeIcon: Icons.mosque_rounded,
        label: l10n.navPrayer,
        route: Routes.prayer,
      ),
      _NavTab(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
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
        icon: Icons.favorite_outline,
        activeIcon: Icons.favorite_rounded,
        label: l10n.navAmol,
        route: Routes.amol,
      ),
    ];

    final index = tabs.indexWhere(
      (t) => location == t.route || location.startsWith('${t.route}/'),
    );

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.navBackground,
          border: Border(
            top: BorderSide(
              color: colors.border.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.isDark
                  ? Colors.black.withValues(alpha: 0.30)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceSm,
              vertical: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (i) {
                final tab = tabs[i];
                final isSelected = i == (index >= 0 ? index : 0);
                return _NavItem(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () => context.go(tab.route),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NAV ITEM
// ─────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.emerald.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Icon(
                    isSelected ? tab.activeIcon : tab.icon,
                    color: isSelected
                        ? colors.emerald
                        : colors.textFaint,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  style: TextStyle(
                    color: isSelected
                        ? colors.emerald
                        : colors.textFaint,
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
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
