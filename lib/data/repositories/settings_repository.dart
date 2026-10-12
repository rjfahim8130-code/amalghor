import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/settings_model.dart';

/// Persists user settings in SharedPreferences as a flat key-value
/// store. Each field has its own key so that partial updates are
/// cheap and forward-compatible.
class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  /// Load the current settings. Missing keys fall back to defaults.
  SettingsModel load() {
    return SettingsModel(
      locale: Locale(_prefs.getString(AppConstants.keyLocale) ?? 'en'),
      themeMode: _readThemeMode(),
      madhhab: _readMadhhab(),
      calcMethod: _readCalcMethod(),
      calendarPrimary: _readCalendarPrimary(),
      notifFajr: _prefs.getBool(AppConstants.keyNotifFajr) ?? true,
      notifDhuhr: _prefs.getBool(AppConstants.keyNotifDhuhr) ?? true,
      notifAsr: _prefs.getBool(AppConstants.keyNotifAsr) ?? true,
      notifMaghrib: _prefs.getBool(AppConstants.keyNotifMaghrib) ?? true,
      notifIsha: _prefs.getBool(AppConstants.keyNotifIsha) ?? true,
      notifSehri: _prefs.getBool(AppConstants.keyNotifSehri) ?? true,
      notifIftar: _prefs.getBool(AppConstants.keyNotifIftar) ?? true,
    );
  }

  /// Persist the entire settings snapshot.
  Future<void> save(SettingsModel s) async {
    await _prefs.setString(AppConstants.keyLocale, s.locale.languageCode);
    await _prefs.setString(AppConstants.keyThemeMode, s.themeMode.name);
    await _prefs.setString(AppConstants.keyMadhhab, s.madhhab.name);
    await _prefs.setString(
      AppConstants.keyCalculationMethod,
      s.calcMethod.name,
    );
    await _prefs.setString(
      AppConstants.keyCalendarPrimary,
      s.calendarPrimary.name,
    );
    await _prefs.setBool(AppConstants.keyNotifFajr, s.notifFajr);
    await _prefs.setBool(AppConstants.keyNotifDhuhr, s.notifDhuhr);
    await _prefs.setBool(AppConstants.keyNotifAsr, s.notifAsr);
    await _prefs.setBool(AppConstants.keyNotifMaghrib, s.notifMaghrib);
    await _prefs.setBool(AppConstants.keyNotifIsha, s.notifIsha);
    await _prefs.setBool(AppConstants.keyNotifSehri, s.notifSehri);
    await _prefs.setBool(AppConstants.keyNotifIftar, s.notifIftar);
  }

  Future<void> reset() async {
    await save(const SettingsModel());
  }

  // ─────────────────────────────────────────────
  // INTERNAL READERS
  // ─────────────────────────────────────────────
  ThemeMode _readThemeMode() {
    final raw = _prefs.getString(AppConstants.keyThemeMode);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  MadhhabType _readMadhhab() {
    final raw = _prefs.getString(AppConstants.keyMadhhab);
    return MadhhabType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => MadhhabType.hanafi,
    );
  }

  CalcMethodType _readCalcMethod() {
    final raw = _prefs.getString(AppConstants.keyCalculationMethod);
    return CalcMethodType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => CalcMethodType.karachi,
    );
  }

  CalendarPrimary _readCalendarPrimary() {
    final raw = _prefs.getString(AppConstants.keyCalendarPrimary);
    return CalendarPrimary.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => CalendarPrimary.english,
    );
  }
}
