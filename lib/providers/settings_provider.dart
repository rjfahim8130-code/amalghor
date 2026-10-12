import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/settings_model.dart';
import '../data/repositories/settings_repository.dart';

/// Provider that exposes the singleton [SharedPreferences] instance.
///
/// It must be overridden in `main()` after `SharedPreferences.getInstance()`
/// has resolved.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

/// Provider exposing the [SettingsRepository] built on top of prefs.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});

/// Notifier that owns the current [SettingsModel] state.
class SettingsNotifier extends StateNotifier<SettingsModel> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(_repo.load());

  /// Change the app-wide locale.
  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await _repo.save(state);
  }

  /// Change the theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.save(state);
  }

  /// Change the Asr madhhab.
  Future<void> setMadhhab(MadhhabType madhhab) async {
    state = state.copyWith(madhhab: madhhab);
    await _repo.save(state);
  }

  /// Change the astronomical calculation method.
  Future<void> setCalcMethod(CalcMethodType method) async {
    state = state.copyWith(calcMethod: method);
    await _repo.save(state);
  }

  /// Change the primary calendar used in headers and PDF.
  Future<void> setCalendarPrimary(CalendarPrimary primary) async {
    state = state.copyWith(calendarPrimary: primary);
    await _repo.save(state);
  }

  Future<void> setNotifFajr(bool v) async {
    state = state.copyWith(notifFajr: v);
    await _repo.save(state);
  }

  Future<void> setNotifDhuhr(bool v) async {
    state = state.copyWith(notifDhuhr: v);
    await _repo.save(state);
  }

  Future<void> setNotifAsr(bool v) async {
    state = state.copyWith(notifAsr: v);
    await _repo.save(state);
  }

  Future<void> setNotifMaghrib(bool v) async {
    state = state.copyWith(notifMaghrib: v);
    await _repo.save(state);
  }

  Future<void> setNotifIsha(bool v) async {
    state = state.copyWith(notifIsha: v);
    await _repo.save(state);
  }

  Future<void> setNotifSehri(bool v) async {
    state = state.copyWith(notifSehri: v);
    await _repo.save(state);
  }

  Future<void> setNotifIftar(bool v) async {
    state = state.copyWith(notifIftar: v);
    await _repo.save(state);
  }

  /// Restore defaults.
  Future<void> reset() async {
    await _repo.reset();
    state = _repo.load();
  }
}

/// The one and only settings state provider.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});
