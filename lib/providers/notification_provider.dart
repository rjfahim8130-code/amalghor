import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/prayer_times.dart';
import '../data/models/settings_model.dart';
import '../services/notification_service.dart';
import 'location_provider.dart';
import 'prayer_provider.dart';
import 'settings_provider.dart';

/// Provider for the singleton [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

/// The permission status of the notification subsystem.
enum NotificationPermissionStatus {
  unknown,
  granted,
  denied,
}

/// Notifier that owns notification permission + scheduling state.
class NotificationNotifier
    extends StateNotifier<NotificationPermissionStatus> {
  final NotificationService _service;
  final Ref _ref;

  NotificationNotifier(this._service, this._ref)
      : super(NotificationPermissionStatus.unknown);

  /// Ask the OS for notification permission and update state.
  Future<bool> requestPermission() async {
    final granted = await _service.requestPermissions();
    state = granted
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
    return granted;
  }

  /// Reschedule everything for today based on the current prayer times
  /// and the user's per-prayer toggles.
  Future<void> reschedule() async {
    final settings = _ref.read(settingsProvider);
    final prayerAsync = _ref.read(currentDayPrayerProvider);

    final prayer = prayerAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );
    if (prayer == null) return;

    await _scheduleFromSettings(prayer, settings);
  }

  /// Cancel all pending notifications.
  Future<void> cancelAll() => _service.cancelAll();

  Future<void> _scheduleFromSettings(
    PrayerTimes prayer,
    SettingsModel settings,
  ) async {
    await _service.scheduleDaily(
      times: prayer,
      labelBuilder: _label,
      fajr: settings.notifFajr,
      dhuhr: settings.notifDhuhr,
      asr: settings.notifAsr,
      maghrib: settings.notifMaghrib,
      isha: settings.notifIsha,
      sehri: settings.notifSehri,
      iftar: settings.notifIftar,
      tahajjud: false,
    );
  }

  String _label(String key) {
    switch (key) {
      case 'fajr':
        return 'ফজর';
      case 'dhuhr':
        return 'যোহর';
      case 'asr':
        return 'আসর';
      case 'maghrib':
        return 'মাগরিব';
      case 'isha':
        return 'এশা';
      case 'sehri':
        return 'সেহরি';
      case 'iftar':
        return 'ইফতার';
      case 'tahajjud':
        return 'তাহাজ্জুদ';
      default:
        return key;
    }
  }
}

/// Public provider for the notification notifier.
final notificationProvider = StateNotifierProvider<
    NotificationNotifier, NotificationPermissionStatus>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationNotifier(service, ref);
});

/// Convenience: boolean permission state.
final notificationGrantedProvider = Provider<bool>((ref) {
  final status = ref.watch(notificationProvider);
  return status == NotificationPermissionStatus.granted;
});

/// Provider watching the current location so we can invalidate
/// schedules whenever the location changes.
final notificationRescheduleTriggerProvider = Provider<void>((ref) {
  // Watch location and settings — when they change, schedule is stale.
  ref.watch(currentLocationProvider);
  ref.watch(settingsProvider);
});
