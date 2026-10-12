import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/location_model.dart';
import '../data/repositories/location_repository.dart';
import '../services/location_service.dart';
import 'settings_provider.dart';

// ─────────────────────────────────────────────
// PROVIDERS — DEPENDENCIES
// ─────────────────────────────────────────────

/// Provider for [LocationRepository]. Depends on SharedPreferences.
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocationRepository(prefs);
});

/// Provider for [LocationService] — GPS + geocoding.
final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

// ─────────────────────────────────────────────
// STATE SHAPE
// ─────────────────────────────────────────────

/// UI-facing state for the location system.
///
/// Carries:
///   - the currently active location
///   - a refresh-in-progress flag
///   - the last error (if any) from the last refresh attempt
class LocationState {
  final LocationModel location;
  final bool isRefreshing;
  final String? lastError;

  const LocationState({
    required this.location,
    this.isRefreshing = false,
    this.lastError,
  });

  LocationState copyWith({
    LocationModel? location,
    bool? isRefreshing,
    String? lastError,
    bool clearError = false,
  }) {
    return LocationState(
      location: location ?? this.location,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

/// Owns the active location and exposes actions for GPS refresh,
/// manual selection, and reset-to-default.
class LocationNotifier extends StateNotifier<LocationState> {
  final LocationRepository _repo;
  final LocationService _service;

  LocationNotifier(this._repo, this._service)
      : super(LocationState(location: _repo.loadCurrent()));

  /// Refresh the location from GPS.
  ///
  /// Returns `true` on success, `false` on failure. Failure reasons
  /// are stored in [LocationState.lastError].
  Future<bool> refreshFromGps() async {
    if (state.isRefreshing) return false;

    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final loc = await _service.resolveCurrent();
      await _repo.saveCurrent(loc);
      state = LocationState(location: loc);
      return true;
    } on LocationException catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        lastError: e.code,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        lastError: 'unknown',
      );
      return false;
    }
  }

  /// Persist a location picked manually by the user.
  Future<void> setManual(LocationModel loc) async {
    final manual = loc.copyWith(source: LocationSource.manual);
    await _repo.saveCurrent(manual);
    state = LocationState(location: manual);
  }

  /// Reset back to the shipped default (Dhaka).
  Future<void> resetToDefault() async {
    await _repo.saveCurrent(LocationModel.fallback);
    state = LocationState(location: LocationModel.fallback);
  }

  /// Clear any stored error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ─────────────────────────────────────────────
// PROVIDERS — PUBLIC API
// ─────────────────────────────────────────────

/// The primary provider — watch this from any screen.
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final repo = ref.watch(locationRepositoryProvider);
  final service = ref.watch(locationServiceProvider);
  return LocationNotifier(repo, service);
});

/// Convenience: get just the active [LocationModel].
final currentLocationProvider = Provider<LocationModel>((ref) {
  return ref.watch(locationProvider).location;
});

/// Convenience: get just the refreshing flag.
final isRefreshingLocationProvider = Provider<bool>((ref) {
  return ref.watch(locationProvider).isRefreshing;
});

// ─────────────────────────────────────────────
// STATIC CATALOGUE PROVIDERS
// ─────────────────────────────────────────────

/// All divisions with their districts.
final locationDivisionsProvider =
    Provider<Map<String, List<LocationEntry>>>((ref) {
  return LocationRepository.divisions;
});

/// Flat list of all 64 districts.
final allDistrictsProvider = Provider<List<LocationEntry>>((ref) {
  return LocationRepository.allDistricts;
});

/// Division names in display order.
final divisionNamesProvider = Provider<List<String>>((ref) {
  return LocationRepository.divisionNames;
});

/// Selected international cities.
final internationalLocationsProvider =
    Provider<List<LocationEntry>>((ref) {
  return LocationRepository.international;
});

/// Family provider — districts of a given division.
final districtsByDivisionProvider =
    Provider.family<List<LocationEntry>, String>((ref, division) {
  final repo = ref.watch(locationRepositoryProvider);
  return repo.byDivision(division);
});

/// Family provider — search results for a query.
///
/// Returns an empty list for empty queries (as opposed to all
/// locations) so the UI can hide the results section cleanly.
final locationSearchProvider =
    Provider.family<List<LocationEntry>, String>((ref, query) {
  final repo = ref.watch(locationRepositoryProvider);
  return repo.search(query);
});
