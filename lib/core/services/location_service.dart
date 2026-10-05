import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amalghor/core/constants/app_constants.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String locationName;
  final String? timezone;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.timezone,
  });
}

class LocationService {
  static Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> isPermissionGranted() async {
    return await Permission.location.isGranted;
  }

  static Future<LocationResult?> getCurrentLocation() async {
    try {
      final hasPermission = await isPermissionGranted();
      if (!hasPermission) {
        final granted = await requestPermission();
        if (!granted) return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      String locationName = AppConstants.defaultLocationName;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[];
          if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
            parts.add(p.administrativeArea!);
          }
          if (p.country != null && p.country!.isNotEmpty) parts.add(p.country!);
          if (parts.isNotEmpty) locationName = parts.join(', ');
        }
      } catch (_) {}

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<LocationResult> getDefaultLocation() async {
    return LocationResult(
      latitude: AppConstants.defaultLat,
      longitude: AppConstants.defaultLng,
      locationName: AppConstants.defaultLocationName,
      timezone: AppConstants.defaultTimezone,
    );
  }
}
