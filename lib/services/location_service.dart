import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../data/models/location_model.dart';

/// Thrown when the location cannot be resolved.
class LocationException implements Exception {
  final String code;
  final String message;
  const LocationException(this.code, this.message);

  @override
  String toString() => 'LocationException($code): $message';
}

/// Service that resolves the user's current location via GPS,
/// reverse-geocodes it to a human-readable place name, and picks up
/// the device's IANA timezone identifier.
class LocationService {
  const LocationService();

  /// Resolve the current position + place + timezone in one call.
  Future<LocationModel> resolveCurrent() async {
    // 1. Ensure location services are enabled.
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      throw const LocationException(
        'services_disabled',
        'Location services are disabled.',
      );
    }

    // 2. Check and request permission.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(
        'permission_denied',
        'Location permission was denied.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'permission_denied_forever',
        'Location permission permanently denied.',
      );
    }

    // 3. Fetch the high-accuracy position.
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 20),
    );

    // 4. Reverse-geocode to get city / country.
    String? city;
    String? district;
    String? country;
    String? countryCode;
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        city = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea;
        district = p.subAdministrativeArea;
        country = p.country;
        countryCode = p.isoCountryCode?.toUpperCase();
      }
    } catch (_) {
      // Geocoding failed — this is non-fatal, we still have lat/lng.
    }

    // 5. Determine the IANA timezone.
    String timezone = 'UTC';
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      timezone = tzInfo.identifier;
    } catch (_) {
      // Fallback below.
    }

    final displayName = _buildDisplayName(city, country);

    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      timezone: timezone,
      displayName: displayName,
      city: city,
      district: district,
      country: country,
      countryCode: countryCode,
      source: LocationSource.gps,
    );
  }

  /// Compute the distance in km between two lat/lng pairs.
  double distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000.0;
  }

  /// Open the OS location settings screen.
  Future<bool> openSettings() => Geolocator.openLocationSettings();

  /// Open the app's permission settings.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  String _buildDisplayName(String? city, String? country) {
    if (city != null && country != null) return '$city, $country';
    if (city != null) return city;
    if (country != null) return country;
    return 'Unknown location';
  }
}
