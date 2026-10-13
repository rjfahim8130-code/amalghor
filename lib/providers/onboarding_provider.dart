import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import 'settings_provider.dart';

/// Notifier that owns the "has the user completed onboarding" flag.
class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  OnboardingNotifier(this._prefs)
      : super(_prefs.getBool(AppConstants.keyOnboarded) ?? false);

  /// Marks onboarding as completed and persists the flag.
  Future<void> complete() async {
    await _prefs.setBool(AppConstants.keyOnboarded, true);
    state = true;
  }

  /// Debug helper — resets the flag.
  Future<void> reset() async {
    await _prefs.setBool(AppConstants.keyOnboarded, false);
    state = false;
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs);
});
