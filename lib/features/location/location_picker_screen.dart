import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/location_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/location_provider.dart';

/// Full-screen location picker.
///
/// Two ways to set the location:
///   1. Tap the "Auto (GPS)" tile to refresh from the device.
///   2. Pick a district manually (Bangladesh) or an international city.
///
/// The screen is entirely offline — the district catalogue ships with
/// the app.
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends ConsumerState<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(locationProvider);
    final notifier = ref.read(locationProvider.notifier);

    // Listen for refresh errors and show a snackbar once.
    ref.listen<LocationState>(locationProvider, (prev, next) {
      if (next.lastError != null && prev?.lastError != next.lastError) {
        _showErrorSnack(context, next.lastError!);
        notifier.clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.location),
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            hint: l10n.searchLocation,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spaceMd,
              ),
              children: [
                // ─── Auto GPS option ─────────────────
                _AutoGpsTile(
                  isRefreshing: state.isRefreshing,
                  currentLabel: state.location.displayName,
                  onTap: () => _handleGpsRefresh(context),
                ),

                // ─── Search results or full catalogue ─
                if (_query.trim().isNotEmpty)
                  _SearchResults(
                    query: _query,
                    onSelect: (entry) => _selectEntry(context, entry),
                  )
                else ...[
                  _SectionHeader(title: '🇧🇩 Bangladesh'),
                  ..._buildDivisions(context),
                  const SizedBox(height: AppConstants.spaceLg),
                  _SectionHeader(title: '🌍 International'),
                  ..._buildInternational(context),
                ],

                const SizedBox(height: AppConstants.spaceXl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD HELPERS
  // ─────────────────────────────────────────────

  List<Widget> _buildDivisions(BuildContext context) {
    final divisions = ref.watch(locationDivisionsProvider);
    return divisions.entries.map((e) {
      return _DivisionTile(
        divisionName: e.key,
        districts: e.value,
        onSelect: (entry) => _selectEntry(context, entry),
      );
    }).toList();
  }

  List<Widget> _buildInternational(BuildContext context) {
    final cities = ref.watch(internationalLocationsProvider);
    return cities
        .map(
          (c) => _LocationTile(
            title: c.name,
            subtitle: c.country,
            onTap: () => _selectEntry(context, c),
          ),
        )
        .toList();
  }

  // ─────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────

  Future<void> _handleGpsRefresh(BuildContext context) async {
    final ok =
        await ref.read(locationProvider.notifier).refreshFromGps();
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location refreshed')),
      );
      context.pop();
    }
    // If !ok, the listener will show the error snackbar.
  }

  Future<void> _selectEntry(
    BuildContext context,
    LocationEntry entry,
  ) async {
    await ref.read(locationProvider.notifier).setManual(entry.toModel());
    if (!mounted) return;
    context.pop();
  }

  void _showErrorSnack(BuildContext context, String code) {
    final message = _errorMessage(code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _errorMessage(String code) {
    final l10n = AppLocalizations.of(context);
    switch (code) {
      case 'services_disabled':
        return l10n.locationServicesDisabled;
      case 'permission_denied':
        return l10n.locationPermissionDenied;
      case 'permission_denied_forever':
        return l10n.locationPermissionPermanentlyDenied;
      default:
        return l10n.error;
    }
  }
}

// ─────────────────────────────────────────────
// WIDGETS — SEARCH BAR
// ─────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceMd,
        AppConstants.spaceLg,
        AppConstants.spaceSm,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppConstants.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(
            Icons.search,
            color: AppConstants.textMuted,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────
// WIDGETS — AUTO GPS TILE
// ─────────────────────────────────────────────

class _AutoGpsTile extends StatelessWidget {
  final bool isRefreshing;
  final String currentLabel;
  final VoidCallback onTap;

  const _AutoGpsTile({
    required this.isRefreshing,
    required this.currentLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceSm,
      ),
      child: Material(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: InkWell(
          onTap: isRefreshing ? null : onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: AppConstants.emeraldPrimary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppConstants.emeraldPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: isRefreshing
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppConstants.emeraldPrimary,
                          ),
                        )
                      : const Icon(
                          Icons.my_location,
                          color: AppConstants.emeraldPrimary,
                          size: 22,
                        ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Auto (GPS)',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: AppConstants.fontSubtitle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRefreshing ? 'Fetching...' : currentLabel,
                        style: const TextStyle(
                          color: AppConstants.textMuted,
                          fontSize: AppConstants.fontCaption,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.refresh,
                  color: AppConstants.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGETS — SECTION HEADER
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceSm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AppConstants.emeraldPrimary,
          fontSize: AppConstants.fontCaption,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGETS — DIVISION TILE (EXPANDABLE)
// ─────────────────────────────────────────────

class _DivisionTile extends StatefulWidget {
  final String divisionName;
  final List<LocationEntry> districts;
  final ValueChanged<LocationEntry> onSelect;

  const _DivisionTile({
    required this.divisionName,
    required this.districts,
    required this.onSelect,
  });

  @override
  State<_DivisionTile> createState() => _DivisionTileState();
}

class _DivisionTileState extends State<_DivisionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceLg,
                vertical: AppConstants.spaceMd,
              ),
              child: Row(
                children: [
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: AppConstants.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Expanded(
                    child: Text(
                      widget.divisionName,
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.districts.length}',
                    style: const TextStyle(
                      color: AppConstants.textMuted,
                      fontSize: AppConstants.fontCaption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          ...widget.districts.map(
            (d) => _DistrictTile(
              entry: d,
              onTap: () => widget.onSelect(d),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// WIDGETS — DISTRICT TILE
// ─────────────────────────────────────────────

class _DistrictTile extends StatelessWidget {
  final LocationEntry entry;
  final VoidCallback onTap;

  const _DistrictTile({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.spaceXl + AppConstants.spaceLg,
            right: AppConstants.spaceLg,
            top: AppConstants.spaceSm,
            bottom: AppConstants.spaceSm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppConstants.textMuted,
                size: 16,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  entry.name,
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: AppConstants.fontBody,
                  ),
                ),
              ),
              Text(
                '${entry.latitude.toStringAsFixed(2)}°, '
                '${entry.longitude.toStringAsFixed(2)}°',
                style: const TextStyle(
                  color: AppConstants.textFaint,
                  fontSize: AppConstants.fontMicro,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGETS — LOCATION TILE (FLAT)
// ─────────────────────────────────────────────

class _LocationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LocationTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceMd,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_city_outlined,
                color: AppConstants.textMuted,
                size: 18,
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppConstants.textMuted,
                        fontSize: AppConstants.fontCaption,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppConstants.textFaint,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGETS — SEARCH RESULTS
// ─────────────────────────────────────────────

class _SearchResults extends ConsumerWidget {
  final String query;
  final ValueChanged<LocationEntry> onSelect;

  const _SearchResults({
    required this.query,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(locationSearchProvider(query));

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXl),
        child: Center(
          child: Text(
            'No results for "$query"',
            style: const TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontBody,
            ),
          ),
        ),
      );
    }

    return Column(
      children: results
          .map(
            (r) => _LocationTile(
              title: r.name,
              subtitle: r.country,
              onTap: () => onSelect(r),
            ),
          )
          .toList(),
    );
  }
}
