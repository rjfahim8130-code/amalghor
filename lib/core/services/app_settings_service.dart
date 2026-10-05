import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amalghor/core/constants/app_constants.dart';
import 'package:amalghor/core/services/location_service.dart';
import 'package:amalghor/core/services/prayer_calculation_service.dart';
import 'package:amalghor/core/models/prayer_times_model.dart';

class AppSettingsService extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Settings
  AppLanguage _language = AppLanguage.bangla;
  Madhhab _madhhab = Madhhab.hanafi;
  PrimaryCalendar _primaryCalendar = PrimaryCalendar.bangla;
  PdfMode _pdfMode = PdfMode.full;
  ThemeModeOption _themeMode = ThemeModeOption.dark;

  // Location
  double _latitude = AppConstants.defaultLat;
  double _longitude = AppConstants.defaultLng;
  String _locationName = AppConstants.defaultLocationName;

  // Cached prayer data (last 2 + today + next 7 = 10 days)
  List<PrayerTimesModel> _prayerCache = [];
  PrayerTimesModel? _todayPrayer;
  CurrentPrayerStatus? _currentStatus;

  // Getters
  AppLanguage get language => _language;
  Madhhab get madhhab => _madhhab;
  PrimaryCalendar get primaryCalendar => _primaryCalendar;
  PdfMode get pdfMode => _pdfMode;
  ThemeModeOption get themeMode => _themeMode;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get locationName => _locationName;
  List<PrayerTimesModel> get prayerCache => _prayerCache;
  PrayerTimesModel? get todayPrayer => _todayPrayer;
  CurrentPrayerStatus? get currentStatus => _currentStatus;

  bool get isBangla => _language == AppLanguage.bangla;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _ensureLocation();
    await refreshPrayerData();
  }

  Future<void> _loadSettings() async {
    final lang = _prefs.getString(AppConstants.keyLanguage);
    if (lang == 'english') _language = AppLanguage.english;

    final madhhabStr = _prefs.getString(AppConstants.keyMadhhab);
    if (madhhabStr != null) {
      _madhhab = Madhhab.values.firstWhere(
        (e) => e.name == madhhabStr,
        orElse: () => Madhhab.hanafi,
      );
    }

    final cal = _prefs.getString(AppConstants.keyPrimaryCalendar);
    if (cal != null) {
      _primaryCalendar = PrimaryCalendar.values.firstWhere(
        (e) => e.name == cal,
        orElse: () => PrimaryCalendar.bangla,
      );
    }

    final pdf = _prefs.getString(AppConstants.keyPdfMode);
    if (pdf != null) {
      _pdfMode = PdfMode.values.firstWhere(
        (e) => e.name == pdf,
        orElse: () => PdfMode.full,
      );
    }

    final theme = _prefs.getString(AppConstants.keyThemeMode);
    if (theme == 'light') _themeMode = ThemeModeOption.light;

    _latitude = _prefs.getDouble(AppConstants.keyLocationLat) ?? AppConstants.defaultLat;
    _longitude = _prefs.getDouble(AppConstants.keyLocationLng) ?? AppConstants.defaultLng;
    _locationName = _prefs.getString(AppConstants.keyLocationName) ?? AppConstants.defaultLocationName;
  }

  Future<void> _ensureLocation() async {
    final isFirst = _prefs.getBool(AppConstants.keyFirstLaunch) ?? true;
    if (isFirst) {
      final loc = await LocationService.getCurrentLocation();
      if (loc != null) {
        await setLocation(loc.latitude, loc.longitude, loc.locationName);
      }
      await _prefs.setBool(AppConstants.keyFirstLaunch, false);
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    await _prefs.setString(AppConstants.keyLanguage, lang.name);
    notifyListeners();
  }

  Future<void> setMadhhab(Madhhab m) async {
    _madhhab = m;
    await _prefs.setString(AppConstants.keyMadhhab, m.name);
    await refreshPrayerData();
    notifyListeners();
  }

  Future<void> setPrimaryCalendar(PrimaryCalendar c) async {
    _primaryCalendar = c;
    await _prefs.setString(AppConstants.keyPrimaryCalendar, c.name);
    notifyListeners();
  }

  Future<void> setPdfMode(PdfMode mode) async {
    _pdfMode = mode;
    await _prefs.setString(AppConstants.keyPdfMode, mode.name);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    _themeMode = mode;
    await _prefs.setString(AppConstants.keyThemeMode, mode.name);
    notifyListeners();
  }

  Future<void> setLocation(double lat, double lng, String name) async {
    _latitude = lat;
    _longitude = lng;
    _locationName = name;
    await _prefs.setDouble(AppConstants.keyLocationLat, lat);
    await _prefs.setDouble(AppConstants.keyLocationLng, lng);
    await _prefs.setString(AppConstants.keyLocationName, name);
    await refreshPrayerData();
    notifyListeners();
  }

  Future<void> refreshLocationFromGps() async {
    final loc = await LocationService.getCurrentLocation();
    if (loc != null) {
      await setLocation(loc.latitude, loc.longitude, loc.locationName);
    }
  }

  Future<void> refreshPrayerData() async {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 2));

    _prayerCache = PrayerCalculationService.calculateRange(
      latitude: _latitude,
      longitude: _longitude,
      startDate: start,
      days: 10, // past 2 + today + next 7
      madhhab: _madhhab,
    );

    _todayPrayer = _prayerCache.firstWhere(
      (p) =>
          p.date.year == today.year &&
          p.date.month == today.month &&
          p.date.day == today.day,
      orElse: () => _prayerCache[2],
    );

    _updateCurrentStatus();
    notifyListeners();
  }

  void _updateCurrentStatus() {
    if (_todayPrayer != null) {
      _currentStatus = PrayerCalculationService.getCurrentStatus(_todayPrayer!);
    }
  }

  /// Call this every second from UI to update countdown
  void tick() {
    _updateCurrentStatus();
    notifyListeners();
  }

  String t(String bn, String en) => isBangla ? bn : en;
}
