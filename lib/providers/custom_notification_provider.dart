import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/custom_notification_service.dart';
import 'settings_provider.dart';

/// Provider for the singleton [CustomNotificationService].
final customNotificationServiceProvider =
    Provider<CustomNotificationService>((ref) {
  return CustomNotificationService.instance;
});

/// Notifier that owns the user's custom notification list.
class CustomNotificationNotifier
    extends StateNotifier<List<UserNotification>> {
  final CustomNotificationService _service;

  CustomNotificationNotifier(this._service) : super(_service.loadAll());

  Future<void> add(UserNotification n) async {
    await _service.add(n);
    state = _service.loadAll();
  }

  Future<void> update(UserNotification n) async {
    await _service.update(n);
    state = _service.loadAll();
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    state = _service.loadAll();
  }

  Future<void> toggle(UserNotification n, bool enabled) async {
    await _service.toggle(n, enabled);
    state = _service.loadAll();
  }

  Future<void> preview(UserNotification n) async {
    await _service.preview(n);
  }
}

final customNotificationProvider = StateNotifierProvider<
    CustomNotificationNotifier, List<UserNotification>>((ref) {
  final service = ref.watch(customNotificationServiceProvider);
  ref.watch(sharedPreferencesProvider);
  return CustomNotificationNotifier(service);
});
