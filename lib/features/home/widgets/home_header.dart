import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/router.dart';
import '../../../data/models/location_model.dart';
import '../../../providers/location_provider.dart';

/// Top header for the Home screen.
///
/// Contains:
///   - A tappable location chip (icon + short label).
///     Tapping it triggers a GPS refresh in place.
///     Long-pressing it opens the location picker.
///   - A settings icon on the right that pushes to /settings.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(currentLocationProvider);
    final isRefreshing = ref.watch(isRefreshingLocationProvider);
    final notifier = ref.read(locationProvider.notifier);

    // Show any refresh error as a snackbar.
    ref.listen<LocationState>(locationProvider, (prev, next) {
      if (next.lastError != null && prev?.lastError != next.lastError) {
        _showError(context, next.lastError!);
        notifier.clearError();
      }
    });

    return Row(
      children: [
        // ─── Location chip ──────────────────────
        Expanded(
          child: InkWell(
            onTap: isRefreshing
                ? null
                : () => _handleRefresh(context, ref),
            onLongPress: () => context.push(Routes.location),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
                vertical: AppConstants.spaceSm,
              ),
              decoration: BoxDecoration(
                color: AppConstants.surfaceDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                border: Border.all(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _locationIcon(isRefreshing),
                  const SizedBox(width: AppConstants.spaceSm),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _headerLabel(context, loc, isRefreshing),
                          style: const TextStyle(
                            color: AppConstants.textPrimary,
                            fontSize: AppConstants.fontBody,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isRefreshing && loc.country != null)
                          Text(
                            loc.country!,
                            style: const TextStyle(
                              color: AppConstants.textFaint,
                              fontSize: AppConstants.fontMicro,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: AppConstants.spaceSm),

        // ─── Settings icon ──────────────────────
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.push(Routes.settings),
          icon: const Icon(
            Icons.settings_outlined,
            color: AppConstants.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  Widget _locationIcon(bool isRefreshing) {
    if (isRefreshing) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppConstants.emeraldPrimary,
        ),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppConstants.emeraldPrimary.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.location_on,
        color: AppConstants.emeraldPrimary,
        size: 14,
      ),
    );
  }

  String _headerLabel(
    BuildContext context,
    LocationModel loc,
    bool isRefreshing,
  ) {
    if (isRefreshing) return 'Fetching location...';
    if (loc.source == LocationSource.fallback) return 'Tap to set location';
    return loc.shortLabel;
  }

  Future<void> _handleRefresh(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(locationProvider.notifier).refreshFromGps();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showError(BuildContext context, String code) {
    final message = _errorMessage(code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _errorMessage(String code) {
    switch (code) {
      case 'services_disabled':
        return 'Please enable location services.';
      case 'permission_denied':
        return 'Location permission denied.';
      case 'permission_denied_forever':
        return 'Location permission permanently denied. '
            'Enable it in app settings.';
      default:
        return 'Could not update location.';
    }
  }
}
