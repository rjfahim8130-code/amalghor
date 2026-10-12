import 'package:flutter/foundation.dart';

/// Source of the currently selected location.
enum LocationSource {
  /// Fetched from device GPS.
  gps,

  /// Manually chosen by the user from a dropdown or search.
  manual,

  /// Fallback default (Dhaka) used before the user picks anything.
  fallback,
}

/// Immutable location descriptor.
@immutable
class LocationModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final String displayName;
  final String? city;
  final String? district;
  final String? country;
  final String? countryCode;
  final LocationSource source;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.displayName,
    this.city,
    this.district,
    this.country,
    this.countryCode,
    this.source = LocationSource.fallback,
  });

  /// Default location — Dhaka, Bangladesh.
  static const LocationModel fallback = LocationModel(
    latitude: 23.8103,
    longitude: 90.4125,
    timezone: 'Asia/Dhaka',
    displayName: 'Dhaka, Bangladesh',
    city: 'Dhaka',
    district: 'Dhaka',
    country: 'Bangladesh',
    countryCode: 'BD',
    source: LocationSource.fallback,
  );

  String get shortLabel => city ?? displayName.split(',').first.trim();

  String get fullLabel {
    if (city != null && country != null) return '$city, $country';
    return displayName;
  }

  // ─────────────────────────────────────────────
  // SERIALIZATION
  // ─────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
        'displayName': displayName,
        'city': city,
        'district': district,
        'country': country,
        'countryCode': countryCode,
        'source': source.name,
      };

  factory LocationModel.fromMap(Map<String, dynamic> m) {
    return LocationModel(
      latitude: (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] as num).toDouble(),
      timezone: m['timezone'] as String? ?? 'Asia/Dhaka',
      displayName: m['displayName'] as String? ?? 'Unknown',
      city: m['city'] as String?,
      district: m['district'] as String?,
      country: m['country'] as String?,
      countryCode: m['countryCode'] as String?,
      source: LocationSource.values.firstWhere(
        (e) => e.name == m['source'],
        orElse: () => LocationSource.manual,
      ),
    );
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? timezone,
    String? displayName,
    String? city,
    String? district,
    String? country,
    String? countryCode,
    LocationSource? source,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      displayName: displayName ?? this.displayName,
      city: city ?? this.city,
      district: district ?? this.district,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.timezone == timezone &&
          other.displayName == displayName;

  @override
  int get hashCode => Object.hash(latitude, longitude, timezone, displayName);
}

/// A predefined location entry used by the manual location picker.
@immutable
class LocationEntry {
  final String name;
  final String country;
  final String countryCode;
  final String timezone;
  final double latitude;
  final double longitude;

  const LocationEntry({
    required this.name,
    required this.country,
    required this.countryCode,
    required this.timezone,
    required this.latitude,
    required this.longitude,
  });

  LocationModel toModel() => LocationModel(
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
        displayName: '$name, $country',
        city: name,
        country: country,
        countryCode: countryCode,
        source: LocationSource.manual,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'country': country,
        'countryCode': countryCode,
        'timezone': timezone,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory LocationEntry.fromMap(Map<String, dynamic> m) => LocationEntry(
        name: m['name'] as String,
        country: m['country'] as String,
        countryCode: m['countryCode'] as String,
        timezone: m['timezone'] as String,
        latitude: (m['latitude'] as num).toDouble(),
        longitude: (m['longitude'] as num).toDouble(),
      );
}
