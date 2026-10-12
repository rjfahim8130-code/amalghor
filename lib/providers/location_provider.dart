import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/location_model.dart';
import '../data/repositories/location_repository.dart';
import '../services/location_service.dart';
import 'settings_provider.dart';

/// Provider for [LocationRepository].
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocationRepository(prefs);
});

/// Provider for [LocationService].
final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

/// Notifier that owns the current [LocationModel] state.
class LocationNotifier extends StateNotifier<LocationModel> {
  final LocationRepository _repo;
  final LocationService _service;

  LocationNotifier(this._repo, this._service)
      : super(_repo.loadCurrent());

  Future<void> refreshFromGps() async {
    final loc = await _service.resolveCurrent();
    await _repo.saveCurrent(loc);
    state = loc;
  }

  Future<void> setManual(LocationModel loc) async {
    final manual = loc.copyWith(source: LocationSource.manual);
    await _repo.saveCurrent(manual);
    state = manual;
  }

  Future<void> resetToDefault() async {
    await _repo.saveCurrent(LocationModel.fallback);
    state = LocationModel.fallback;
  }
}

/// The current location state.
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationModel>((ref) {
  final repo = ref.watch(locationRepositoryProvider);
  final service = ref.watch(locationServiceProvider);
  return LocationNotifier(repo, service);
});

/// A read-only provider that exposes the shipped location catalogue.
final locationCatalogueProvider = Provider<List<LocationEntry>>((ref) {
  return LocationRepository.catalogue;
});

/// Search the catalogue by query string.
final locationSearchProvider =
    Provider.family<List<LocationEntry>, String>((ref, query) {
  return ref.watch(locationRepositoryProvider).search(query);
});

/// All distinct countries in the catalogue.
final locationCountriesProvider = Provider<List<String>>((ref) {
  return ref.watch(locationRepositoryProvider).countries();
});

/// Locations filtered by country.
final locationByCountryProvider =
    Provider.family<List<LocationEntry>, String>((ref, country) {
  return ref.watch(locationRepositoryProvider).byCountry(country);
});
