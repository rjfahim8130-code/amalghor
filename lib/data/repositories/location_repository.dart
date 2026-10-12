import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/location_model.dart';

/// Persists the user's chosen location in SharedPreferences.
///
/// Also stores a small static catalogue of well-known locations that
/// ship with the app so the manual picker works fully offline.
class LocationRepository {
  final SharedPreferences _prefs;

  LocationRepository(this._prefs);

  // ─────────────────────────────────────────────
  // CURRENT LOCATION
  // ─────────────────────────────────────────────
  LocationModel loadCurrent() {
    final lat = _prefs.getDouble(AppConstants.keyLatitude);
    final lng = _prefs.getDouble(AppConstants.keyLongitude);
    final tz = _prefs.getString(AppConstants.keyTimezone);
    final name = _prefs.getString(AppConstants.keyLocationName);
    final isManual = _prefs.getBool(AppConstants.keyManualLocation) ?? false;

    if (lat == null || lng == null) return LocationModel.fallback;

    return LocationModel(
      latitude: lat,
      longitude: lng,
      timezone: tz ?? AppConstants.defaultTimezone,
      displayName: name ?? AppConstants.defaultLocationName,
      source: isManual ? LocationSource.manual : LocationSource.gps,
    );
  }

  Future<void> saveCurrent(LocationModel loc) async {
    await _prefs.setDouble(AppConstants.keyLatitude, loc.latitude);
    await _prefs.setDouble(AppConstants.keyLongitude, loc.longitude);
    await _prefs.setString(AppConstants.keyTimezone, loc.timezone);
    await _prefs.setString(AppConstants.keyLocationName, loc.displayName);
    await _prefs.setBool(
      AppConstants.keyManualLocation,
      loc.source == LocationSource.manual,
    );
  }

  Future<void> clear() async {
    await _prefs.remove(AppConstants.keyLatitude);
    await _prefs.remove(AppConstants.keyLongitude);
    await _prefs.remove(AppConstants.keyTimezone);
    await _prefs.remove(AppConstants.keyLocationName);
    await _prefs.remove(AppConstants.keyManualLocation);
  }

  // ─────────────────────────────────────────────
  // STATIC CATALOGUE (offline)
  // ─────────────────────────────────────────────
  /// Well-known locations. The list is intentionally short — the
  /// manual picker also allows entering custom lat/lng and timezone.
  static const List<LocationEntry> catalogue = [
    // ─── Bangladesh ──────────────────────────
    LocationEntry(
      name: 'Dhaka',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.8103,
      longitude: 90.4125,
    ),
    LocationEntry(
      name: 'Chattogram',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.3569,
      longitude: 91.7832,
    ),
    LocationEntry(
      name: 'Rajshahi',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.3745,
      longitude: 88.6042,
    ),
    LocationEntry(
      name: 'Khulna',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.8456,
      longitude: 89.5403,
    ),
    LocationEntry(
      name: 'Sylhet',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.8949,
      longitude: 91.8687,
    ),
    LocationEntry(
      name: 'Barishal',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.7010,
      longitude: 90.3535,
    ),
    LocationEntry(
      name: 'Rangpur',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 25.7439,
      longitude: 89.2752,
    ),
    LocationEntry(
      name: 'Mymensingh',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.7471,
      longitude: 90.4203,
    ),

    // ─── Middle East ─────────────────────────
    LocationEntry(
      name: 'Makkah',
      country: 'Saudi Arabia',
      countryCode: 'SA',
      timezone: 'Asia/Riyadh',
      latitude: 21.3891,
      longitude: 39.8579,
    ),
    LocationEntry(
      name: 'Madinah',
      country: 'Saudi Arabia',
      countryCode: 'SA',
      timezone: 'Asia/Riyadh',
      latitude: 24.5247,
      longitude: 39.5692,
    ),
    LocationEntry(
      name: 'Riyadh',
      country: 'Saudi Arabia',
      countryCode: 'SA',
      timezone: 'Asia/Riyadh',
      latitude: 24.7136,
      longitude: 46.6753,
    ),
    LocationEntry(
      name: 'Dubai',
      country: 'UAE',
      countryCode: 'AE',
      timezone: 'Asia/Dubai',
      latitude: 25.2048,
      longitude: 55.2708,
    ),
    LocationEntry(
      name: 'Doha',
      country: 'Qatar',
      countryCode: 'QA',
      timezone: 'Asia/Qatar',
      latitude: 25.2854,
      longitude: 51.5310,
    ),
    LocationEntry(
      name: 'Cairo',
      country: 'Egypt',
      countryCode: 'EG',
      timezone: 'Africa/Cairo',
      latitude: 30.0444,
      longitude: 31.2357,
    ),
    LocationEntry(
      name: 'Istanbul',
      country: 'Turkey',
      countryCode: 'TR',
      timezone: 'Europe/Istanbul',
      latitude: 41.0082,
      longitude: 28.9784,
    ),

    // ─── South & Southeast Asia ──────────────
    LocationEntry(
      name: 'Karachi',
      country: 'Pakistan',
      countryCode: 'PK',
      timezone: 'Asia/Karachi',
      latitude: 24.8607,
      longitude: 67.0011,
    ),
    LocationEntry(
      name: 'Lahore',
      country: 'Pakistan',
      countryCode: 'PK',
      timezone: 'Asia/Karachi',
      latitude: 31.5204,
      longitude: 74.3587,
    ),
    LocationEntry(
      name: 'Delhi',
      country: 'India',
      countryCode: 'IN',
      timezone: 'Asia/Kolkata',
      latitude: 28.6139,
      longitude: 77.2090,
    ),
    LocationEntry(
      name: 'Mumbai',
      country: 'India',
      countryCode: 'IN',
      timezone: 'Asia/Kolkata',
      latitude: 19.0760,
      longitude: 72.8777,
    ),
    LocationEntry(
      name: 'Kolkata',
      country: 'India',
      countryCode: 'IN',
      timezone: 'Asia/Kolkata',
      latitude: 22.5726,
      longitude: 88.3639,
    ),
    LocationEntry(
      name: 'Kuala Lumpur',
      country: 'Malaysia',
      countryCode: 'MY',
      timezone: 'Asia/Kuala_Lumpur',
      latitude: 3.1390,
      longitude: 101.6869,
    ),
    LocationEntry(
      name: 'Jakarta',
      country: 'Indonesia',
      countryCode: 'ID',
      timezone: 'Asia/Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
    ),

    // ─── Europe & Americas ───────────────────
    LocationEntry(
      name: 'London',
      country: 'United Kingdom',
      countryCode: 'GB',
      timezone: 'Europe/London',
      latitude: 51.5074,
      longitude: -0.1278,
    ),
    LocationEntry(
      name: 'Paris',
      country: 'France',
      countryCode: 'FR',
      timezone: 'Europe/Paris',
      latitude: 48.8566,
      longitude: 2.3522,
    ),
    LocationEntry(
      name: 'Berlin',
      country: 'Germany',
      countryCode: 'DE',
      timezone: 'Europe/Berlin',
      latitude: 52.5200,
      longitude: 13.4050,
    ),
    LocationEntry(
      name: 'New York',
      country: 'United States',
      countryCode: 'US',
      timezone: 'America/New_York',
      latitude: 40.7128,
      longitude: -74.0060,
    ),
    LocationEntry(
      name: 'Toronto',
      country: 'Canada',
      countryCode: 'CA',
      timezone: 'America/Toronto',
      latitude: 43.6532,
      longitude: -79.3832,
    ),

    // ─── Africa ──────────────────────────────
    LocationEntry(
      name: 'Khartoum',
      country: 'Sudan',
      countryCode: 'SD',
      timezone: 'Africa/Khartoum',
      latitude: 15.5007,
      longitude: 32.5599,
    ),
    LocationEntry(
      name: 'Lagos',
      country: 'Nigeria',
      countryCode: 'NG',
      timezone: 'Africa/Lagos',
      latitude: 6.5244,
      longitude: 3.3792,
    ),
  ];

  /// Case-insensitive substring search across name + country.
  List<LocationEntry> search(String query) {
    if (query.trim().isEmpty) return catalogue;
    final q = query.trim().toLowerCase();
    return catalogue.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.country.toLowerCase().contains(q);
    }).toList();
  }

  /// All distinct countries in the catalogue, sorted alphabetically.
  List<String> countries() {
    final set = catalogue.map((e) => e.country).toSet().toList();
    set.sort();
    return set;
  }

  /// All locations for a given country.
  List<LocationEntry> byCountry(String country) {
    return catalogue.where((e) => e.country == country).toList();
  }
}
