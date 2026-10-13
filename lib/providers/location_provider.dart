import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/location_model.dart';
import '../data/repositories/location_repository.dart';
import '../services/location_service.dart';
import 'settings_provider.dart';

// ─────────────────────────────────────────────
// DEPENDENCY PROVIDERS
// ─────────────────────────────────────────────

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocationRepository(prefs);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

// ─────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────

/// UI-facing state for the location system.
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
// PUBLIC PROVIDERS
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

final locationDivisionsProvider =
    Provider<Map<String, List<LocationEntry>>>((ref) {
  return LocationRepository.divisions;
});

final allDistrictsProvider = Provider<List<LocationEntry>>((ref) {
  return LocationRepository.allDistricts;
});

final divisionNamesProvider = Provider<List<String>>((ref) {
  return LocationRepository.divisionNames;
});

final internationalLocationsProvider =
    Provider<List<LocationEntry>>((ref) {
  return LocationRepository.international;
});

final districtsByDivisionProvider =
    Provider.family<List<LocationEntry>, String>((ref, division) {
  final repo = ref.watch(locationRepositoryProvider);
  return repo.byDivision(division);
});

final locationSearchProvider =
    Provider.family<List<LocationEntry>, String>((ref, query) {
  final repo = ref.watch(locationRepositoryProvider);
  return repo.search(query);
});
