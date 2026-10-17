import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/alarm_service.dart';
import 'settings_provider.dart';

/// Provider for the singleton [AlarmService].
final alarmServiceProvider = Provider<AlarmService>((ref) {
  return AlarmService.instance;
});

/// Notifier that owns the user's alarm list.
class AlarmNotifier extends StateNotifier<List<UserAlarm>> {
  final AlarmService _service;

  AlarmNotifier(this._service) : super(_service.loadAll());

  Future<void> add(UserAlarm alarm) async {
    await _service.add(alarm);
    state = _service.loadAll();
  }

  Future<void> update(UserAlarm alarm) async {
    await _service.update(alarm);
    state = _service.loadAll();
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    state = _service.loadAll();
  }

  Future<void> toggle(UserAlarm alarm, bool enabled) async {
    await _service.toggle(alarm, enabled);
    state = _service.loadAll();
  }

  Future<void> preview(UserAlarm alarm) async {
    await _service.preview(alarm);
  }
}

final alarmProvider =
    StateNotifierProvider<AlarmNotifier, List<UserAlarm>>((ref) {
  final service = ref.watch(alarmServiceProvider);
  ref.watch(sharedPreferencesProvider);
  return AlarmNotifier(service);
});
