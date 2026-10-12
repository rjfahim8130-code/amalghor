import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/location_model.dart';

/// Persists the user's chosen location in SharedPreferences and
/// provides the static catalogue of all 64 Bangladeshi districts
/// plus selected international cities.
///
/// This repository is the single source of truth for:
///   - The currently selected location
///   - The list of predefined locations for the manual picker
class LocationRepository {
  final SharedPreferences _prefs;

  LocationRepository(this._prefs);

  // ─────────────────────────────────────────────
  // CURRENT LOCATION — PERSISTENCE
  // ─────────────────────────────────────────────

  /// Load the currently saved location, or the fallback (Dhaka)
  /// if nothing has been saved yet.
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

  /// Persist the given location.
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

  /// Clear all persisted location data.
  Future<void> clear() async {
    await _prefs.remove(AppConstants.keyLatitude);
    await _prefs.remove(AppConstants.keyLongitude);
    await _prefs.remove(AppConstants.keyTimezone);
    await _prefs.remove(AppConstants.keyLocationName);
    await _prefs.remove(AppConstants.keyManualLocation);
  }
  // ─────────────────────────────────────────────
// STATIC CATALOGUE — ALL 64 DISTRICTS
// ─────────────────────────────────────────────

/// All 8 divisions of Bangladesh, each containing its districts.
static const Map<String, List<LocationEntry>> divisions = {
  // ─────────────────────────────────────────────
  // DHAKA DIVISION — 13 districts
  // ─────────────────────────────────────────────
  'Dhaka': [
    LocationEntry(
      name: 'Dhaka',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.8103,
      longitude: 90.4125,
    ),
    LocationEntry(
      name: 'Gazipur',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.0024,
      longitude: 90.4262,
    ),
    LocationEntry(
      name: 'Narayanganj',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.6238,
      longitude: 90.4996,
    ),
    LocationEntry(
      name: 'Tangail',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.2513,
      longitude: 89.9167,
    ),
    LocationEntry(
      name: 'Kishoreganj',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.4449,
      longitude: 90.7766,
    ),
    LocationEntry(
      name: 'Manikganj',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.8617,
      longitude: 90.0003,
    ),
    LocationEntry(
      name: 'Munshiganj',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.5422,
      longitude: 90.5305,
    ),
    LocationEntry(
      name: 'Narsingdi',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.9322,
      longitude: 90.7151,
    ),
    LocationEntry(
      name: 'Faridpur',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.6070,
      longitude: 89.8429,
    ),
    LocationEntry(
      name: 'Gopalganj',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.0051,
      longitude: 89.8266,
    ),
    LocationEntry(
      name: 'Madaripur',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.1640,
      longitude: 90.1897,
    ),
    LocationEntry(
      name: 'Rajbari',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.7574,
      longitude: 89.6445,
    ),
    LocationEntry(
      name: 'Shariatpur',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.2423,
      longitude: 90.4348,
    ),
  ],

  // ─────────────────────────────────────────────
  // CHATTOGRAM DIVISION — 11 districts
  // ─────────────────────────────────────────────
  'Chattogram': [
    LocationEntry(
      name: 'Chattogram',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.3569,
      longitude: 91.7832,
    ),
    LocationEntry(
      name: "Cox's Bazar",
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 21.4272,
      longitude: 92.0058,
    ),
    LocationEntry(
      name: 'Cumilla',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.4607,
      longitude: 91.1809,
    ),
    LocationEntry(
      name: 'Brahmanbaria',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.9571,
      longitude: 91.1119,
    ),
    LocationEntry(
      name: 'Chandpur',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.2333,
      longitude: 90.6712,
    ),
    LocationEntry(
      name: 'Feni',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.0159,
      longitude: 91.3976,
    ),
    LocationEntry(
      name: 'Noakhali',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.8696,
      longitude: 91.0995,
    ),
    LocationEntry(
      name: 'Lakshmipur',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.9447,
      longitude: 90.8283,
    ),
    LocationEntry(
      name: 'Bandarban',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.1953,
      longitude: 92.2184,
    ),
    LocationEntry(
      name: 'Rangamati',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.6533,
      longitude: 92.1735,
    ),
    LocationEntry(
      name: 'Khagrachhari',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.1193,
      longitude: 91.9847,
    ),
  ],

  // ─────────────────────────────────────────────
  // RAJSHAHI DIVISION — 8 districts
  // ─────────────────────────────────────────────
  'Rajshahi': [
    LocationEntry(
      name: 'Rajshahi',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.3745,
      longitude: 88.6042,
    ),
    LocationEntry(
      name: 'Bogura',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.8465,
      longitude: 89.3773,
    ),
    LocationEntry(
      name: 'Pabna',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.0064,
      longitude: 89.2372,
    ),
    LocationEntry(
      name: 'Sirajganj',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.4534,
      longitude: 89.7007,
    ),
    LocationEntry(
      name: 'Natore',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.4206,
      longitude: 89.0003,
    ),
    LocationEntry(
      name: 'Naogaon',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.7936,
      longitude: 88.9318,
    ),
    LocationEntry(
      name: 'Chapainawabganj',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 24.5965,
      longitude: 88.2775,
    ),
    LocationEntry(
      name: 'Joypurhat',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 25.0968,
      longitude: 89.0227,
    ),
  ],

  // ─────────────────────────────────────────────
  // KHULNA DIVISION — 10 districts
  // ─────────────────────────────────────────────
  'Khulna': [
    LocationEntry(
      name: 'Khulna',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.8456,
      longitude: 89.5403,
    ),
    LocationEntry(
      name: 'Jashore',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.1667,
      longitude: 89.2083,
    ),
    LocationEntry(
      name: 'Satkhira',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.7185,
      longitude: 89.0705,
    ),
    LocationEntry(
      name: 'Bagerhat',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 22.6516,
      longitude: 89.7859,
    ),
    LocationEntry(
      name: 'Kushtia',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.9013,
      longitude: 89.1206,
    ),
    LocationEntry(
      name: 'Jhenaidah',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.5448,
      longitude: 89.1539,
    ),
    LocationEntry(
      name: 'Magura',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.4855,
      longitude: 89.4198,
    ),
    LocationEntry(
      name: 'Narail',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.1725,
      longitude: 89.5127,
    ),
    LocationEntry(
      name: 'Chuadanga',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.6402,
      longitude: 88.8416,
    ),
    LocationEntry(
      name: 'Meherpur',
      country: 'Bangladesh',
      countryCode: 'BD',
      timezone: 'Asia/Dhaka',
      latitude: 23.7622,
      longitude: 88.6318,
    ),
  ],
      // ─────────────────────────────────────────────
    // BARISHAL DIVISION — 6 districts
    // ─────────────────────────────────────────────
    'Barishal': [
      LocationEntry(
        name: 'Barishal',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 22.7010,
        longitude: 90.3535,
      ),
      LocationEntry(
        name: 'Patuakhali',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 22.3596,
        longitude: 90.3298,
      ),
      LocationEntry(
        name: 'Bhola',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 22.6859,
        longitude: 90.6482,
      ),
      LocationEntry(
        name: 'Pirojpur',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 22.5841,
        longitude: 89.9723,
      ),
      LocationEntry(
        name: 'Barguna',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 22.1596,
        longitude: 90.1266,
      ),
      LocationEntry(
        name: 'Jhalokati',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 22.6406,
        longitude: 90.1987,
      ),
    ],

    // ─────────────────────────────────────────────
    // SYLHET DIVISION — 4 districts
    // ─────────────────────────────────────────────
    'Sylhet': [
      LocationEntry(
        name: 'Sylhet',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 24.8949,
        longitude: 91.8687,
      ),
      LocationEntry(
        name: 'Moulvibazar',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 24.4829,
        longitude: 91.7774,
      ),
      LocationEntry(
        name: 'Habiganj',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 24.3745,
        longitude: 91.4155,
      ),
      LocationEntry(
        name: 'Sunamganj',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 25.0658,
        longitude: 91.3950,
      ),
    ],

    // ─────────────────────────────────────────────
    // RANGPUR DIVISION — 8 districts
    // (Includes your Dinajpur)
    // ─────────────────────────────────────────────
    'Rangpur': [
      LocationEntry(
        name: 'Rangpur',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 25.7439,
        longitude: 89.2752,
      ),
      LocationEntry(
        name: 'Dinajpur',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 25.6217,
        longitude: 88.6354,
      ),
      LocationEntry(
        name: 'Gaibandha',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 25.3282,
        longitude: 89.5286,
      ),
      LocationEntry(
        name: 'Kurigram',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 25.8072,
        longitude: 89.6295,
      ),
      LocationEntry(
        name: 'Lalmonirhat',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 25.9923,
        longitude: 89.2847,
      ),
      LocationEntry(
        name: 'Nilphamari',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 25.9314,
        longitude: 88.8560,
      ),
      LocationEntry(
        name: 'Panchagarh',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 26.3411,
        longitude: 88.5541,
      ),
      LocationEntry(
        name: 'Thakurgaon',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 26.0337,
        longitude: 88.4616,
      ),
    ],

    // ─────────────────────────────────────────────
    // MYMENSINGH DIVISION — 4 districts
    // ─────────────────────────────────────────────
    'Mymensingh': [
      LocationEntry(
        name: 'Mymensingh',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 24.7471,
        longitude: 90.4203,
      ),
      LocationEntry(
        name: 'Jamalpur',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 24.9375,
        longitude: 89.9372,
      ),
      LocationEntry(
        name: 'Netrokona',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 24.8709,
        longitude: 90.7279,
      ),
      LocationEntry(
        name: 'Sherpur',
        country: 'Bangladesh',
        countryCode: 'BD',
        timezone: 'Asia/Dhaka',
        latitude: 25.0205,
        longitude: 90.0153,
      ),
    ],
  };

  /// Selected international cities for users abroad.
  static const List<LocationEntry> international = [
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
      name: 'Kuala Lumpur',
      country: 'Malaysia',
      countryCode: 'MY',
      timezone: 'Asia/Kuala_Lumpur',
      latitude: 3.1390,
      longitude: 101.6869,
    ),
    LocationEntry(
      name: 'London',
      country: 'United Kingdom',
      countryCode: 'GB',
      timezone: 'Europe/London',
      latitude: 51.5074,
      longitude: -0.1278,
    ),
    LocationEntry(
      name: 'New York',
      country: 'United States',
      countryCode: 'US',
      timezone: 'America/New_York',
      latitude: 40.7128,
      longitude: -74.0060,
    ),
  ];

  // ─────────────────────────────────────────────
  // HELPER METHODS
  // ─────────────────────────────────────────────

  /// Flat list of all 64 Bangladeshi districts.
  static List<LocationEntry> get allDistricts {
    final list = <LocationEntry>[];
    for (final districts in divisions.values) {
      list.addAll(districts);
    }
    return list;
  }

  /// All distinct division names in display order.
  static List<String> get divisionNames => divisions.keys.toList();

  /// Districts belonging to a given division.
  List<LocationEntry> byDivision(String division) {
    return divisions[division] ?? const [];
  }

  /// Case-insensitive search across all districts and international
  /// cities. Empty query returns an empty list.
  List<LocationEntry> search(String query) {
    if (query.trim().isEmpty) return const [];
    final q = query.trim().toLowerCase();
    final results = <LocationEntry>[];

    for (final d in allDistricts) {
      if (d.name.toLowerCase().contains(q) ||
          d.country.toLowerCase().contains(q)) {
        results.add(d);
      }
    }
    for (final i in international) {
      if (i.name.toLowerCase().contains(q) ||
          i.country.toLowerCase().contains(q)) {
        results.add(i);
      }
    }
    return results;
  }
}
