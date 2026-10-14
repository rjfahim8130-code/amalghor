import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/router.dart';
import '../../../data/models/location_model.dart';
import '../../../providers/location_provider.dart';

/// Top header for the Home screen.
///
/// Layout (left → right):
///   1. Brand mark — small emerald-square with mosque icon
///   2. App name — "আমলঘর" (emerald) + tagline (muted)
///   3. Location chip — tappable to refresh GPS; long-press opens picker
///   4. Settings icon
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
        // ─── 1. Brand mark ────────────────────
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppConstants.brandChipGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            boxShadow: AppConstants.emeraldGlowSmall,
          ),
          child: const Icon(
            Icons.mosque_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: AppConstants.spaceMd),

        // ─── 2. App name + tagline ────────────
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'আমলঘর',
                style: TextStyle(
                  color: AppConstants.emeraldPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'ইবাদতের পথে, সবসময়',
                style: TextStyle(
                  color: AppConstants.textMuted,
                  fontSize: 10.5,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // ─── 3. Location chip ─────────────────
        InkWell(
          onTap: isRefreshing
              ? null
              : () => _handleRefresh(context, ref),
          onLongPress: () => context.push(Routes.location),
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppConstants.surfaceDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              border: Border.all(
                color: AppConstants.emeraldPrimary.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _locationIcon(isRefreshing),
                const SizedBox(width: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 78),
                  child: Text(
                    _chipLabel(loc, isRefreshing),
                    style: const TextStyle(
                      color: AppConstants.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: AppConstants.textMuted,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppConstants.spaceXs),

        // ─── 4. Settings ──────────────────────
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.push(Routes.settings),
          icon: const Icon(
            Icons.settings_outlined,
            color: AppConstants.textPrimary,
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

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  Widget _locationIcon(bool isRefreshing) {
    if (isRefreshing) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppConstants.emeraldPrimary,
        ),
      );
    }
    return const Icon(
      Icons.location_on_rounded,
      color: AppConstants.emeraldPrimary,
      size: 14,
    );
  }

  String _chipLabel(LocationModel loc, bool isRefreshing) {
    if (isRefreshing) return 'খোঁজা হচ্ছে';
    if (loc.source == LocationSource.fallback) {
      return 'লোকেশন';
    }
    // Prefer city name only; fall back to first segment of displayName.
    final label = loc.city ?? loc.displayName.split(',').first.trim();
    return label;
  }

  Future<void> _handleRefresh(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(locationProvider.notifier).refreshFromGps();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('লোকেশন আপডেট হয়েছে'),
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
        return 'লোকেশন সার্ভিস চালু করুন।';
      case 'permission_denied':
        return 'লোকেশন অনুমতি দেওয়া হয়নি।';
      case 'permission_denied_forever':
        return 'লোকেশন অনুমতি স্থায়ীভাবে বন্ধ। '
            'সেটিংস থেকে চালু করুন।';
      default:
        return 'লোকেশন আপডেট করা যায়নি।';
    }
  }
}
