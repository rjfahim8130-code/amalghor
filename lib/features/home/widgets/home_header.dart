import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../core/router.dart';
import '../../../data/models/location_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/location_provider.dart';

/// Top header for the Home screen.
///
/// Auto-adapts to dark or light mode via [AppColors].
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final loc = ref.watch(currentLocationProvider);
    final isRefreshing = ref.watch(isRefreshingLocationProvider);
    final notifier = ref.read(locationProvider.notifier);

    ref.listen<LocationState>(locationProvider, (prev, next) {
      if (next.lastError != null && prev?.lastError != next.lastError) {
        _showError(context, l10n, next.lastError!);
        notifier.clearError();
      }
    });

    return Row(
      children: [
        // ─── Brand mark ───────────────────────
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: colors.brandGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            boxShadow: colors.emeraldGlowSmall,
          ),
          child: const Icon(
            Icons.mosque_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: AppConstants.spaceMd),

        // ─── App name + tagline ───────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.appName,
                style: TextStyle(
                  color: colors.emerald,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                l10n.appTagline,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 10.5,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // ─── Location chip ────────────────────
        InkWell(
          onTap: isRefreshing ? null : () => _handleRefresh(context, ref),
          onLongPress: () => context.push(Routes.location),
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              border: Border.all(
                color: colors.border,
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _locationIcon(colors, isRefreshing),
                const SizedBox(width: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 78),
                  child: Text(
                    _chipLabel(loc, isRefreshing, l10n),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppConstants.spaceXs),

        // ─── Settings ─────────────────────────
        IconButton(
          tooltip: l10n.settings,
          onPressed: () => context.push(Routes.settings),
          icon: Icon(
            Icons.settings_outlined,
            color: colors.textPrimary,
            size: 22,
          ),
          splashRadius: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
        ),
      ],
    );
  }

  Widget _locationIcon(AppColors colors, bool isRefreshing) {
    if (isRefreshing) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.emerald,
        ),
      );
    }
    return Icon(
      Icons.location_on_rounded,
      color: colors.emerald,
      size: 14,
    );
  }

  String _chipLabel(
    LocationModel loc,
    bool isRefreshing,
    AppLocalizations l10n,
  ) {
    if (isRefreshing) return l10n.searchingLocation;
    if (loc.source == LocationSource.fallback) {
      return l10n.location;
    }
    final label = loc.city ?? loc.displayName.split(',').first.trim();
    return label;
  }

  Future<void> _handleRefresh(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ref.read(locationProvider.notifier).refreshFromGps();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.locationUpdated),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showError(
    BuildContext context,
    AppLocalizations l10n,
    String code,
  ) {
    final message = _errorMessage(code, l10n);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _errorMessage(String code, AppLocalizations l10n) {
    switch (code) {
      case 'services_disabled':
        return l10n.enableLocationServices;
      case 'permission_denied':
        return l10n.locationPermissionDeniedShort;
      case 'permission_denied_forever':
        return l10n.locationPermissionPermanentlyDenied;
      default:
        return l10n.locationUpdateFailed;
    }
  }
}
