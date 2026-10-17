import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/settings_model.dart';
import '../services/notification_service.dart';
import 'prayer_provider.dart';
import 'settings_provider.dart';

/// Provider for the singleton [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

enum NotificationPermissionStatus { unknown, granted, denied }

class NotificationNotifier
    extends StateNotifier<NotificationPermissionStatus> {
  final NotificationService _service;
  final Ref _ref;

  NotificationNotifier(this._service, this._ref)
      : super(NotificationPermissionStatus.unknown);

  Future<bool> requestPermission() async {
    final granted = await _service.requestPermissions();
    state = granted
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
    return granted;
  }

  Future<void> reschedule() async {
    final settings = _ref.read(settingsProvider);
    final prayerAsync = _ref.read(currentDayPrayerProvider);

    final prayer = prayerAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );
    if (prayer == null) return;

    await _service.scheduleDaily(
      times: prayer,
      settings: settings,
    );
  }

  Future<void> cancelAll() => _service.cancelAll();

  /// Reschedule after a settings change (per-prayer toggle or offset).
  Future<void> rescheduleForSettings(SettingsModel settings) async {
    final prayerAsync = _ref.read(currentDayPrayerProvider);
    final prayer = prayerAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );
    if (prayer == null) return;

    await _service.scheduleDaily(times: prayer, settings: settings);
  }
}

final notificationProvider = StateNotifierProvider<
    NotificationNotifier, NotificationPermissionStatus>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationNotifier(service, ref);
});

final notificationGrantedProvider = Provider<bool>((ref) {
  final status = ref.watch(notificationProvider);
  return status == NotificationPermissionStatus.granted;
});
