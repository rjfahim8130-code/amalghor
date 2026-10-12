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

/// Service that resolves the user's current location via GPS.
class LocationService {
  const LocationService();

  Future<LocationModel> resolveCurrent() async {
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      throw const LocationException(
        'services_disabled',
        'Location services are disabled.',
      );
    }

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

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

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
    } catch (_) {}

    // ─────────────────────────────────────────
    // Timezone resolution — resilient to package API changes
    // ─────────────────────────────────────────
    String timezone = 'UTC';
    try {
      final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
      // Different package versions expose the identifier differently:
      //   - as a String directly
      //   - as an object with `.identifier`
      //   - as an object with `.name`
      if (tzInfo is String) {
        timezone = tzInfo;
      } else {
        try {
          timezone = (tzInfo.identifier as String);
        } catch (_) {
          try {
            timezone = (tzInfo.name as String);
          } catch (_) {
            timezone = 'UTC';
          }
        }
      }
    } catch (_) {
      timezone = 'UTC';
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

  double distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000.0;
  }

  Future<bool> openSettings() => Geolocator.openLocationSettings();
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  String _buildDisplayName(String? city, String? country) {
    if (city != null && country != null) return '$city, $country';
    if (city != null) return city;
    if (country != null) return country;
    return 'Unknown location';
  }
}
