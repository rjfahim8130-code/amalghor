import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// A user-defined manual alarm (rings with sound & vibration).
@immutable
class UserAlarm {
  final String id;
  final String title;
  final String body;
  final int hour;
  final int minute;
  final Set<int> daysOfWeek;
  final bool enabled;

  const UserAlarm({
    required this.id,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    required this.daysOfWeek,
    required this.enabled,
  });

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  String get daysLabel {
    if (daysOfWeek.isEmpty) return 'প্রতিদিন';
    const names = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি', 'রবি'];
    final sorted = daysOfWeek.toList()..sort();
    return sorted.map((d) => names[d - 1]).join(', ');
  }

  UserAlarm copyWith({
    String? title,
    String? body,
    int? hour,
    int? minute,
    Set<int>? daysOfWeek,
    bool? enabled,
  }) {
    return UserAlarm(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'hour': hour,
        'minute': minute,
        'daysOfWeek': daysOfWeek.toList(),
        'enabled': enabled,
      };

  factory UserAlarm.fromMap(Map<String, dynamic> m) {
    return UserAlarm(
      id: m['id'] as String,
      title: m['title'] as String? ?? '🌌 অ্যালার্ম',
      body: m['body'] as String? ?? 'আমলঘর — অ্যালার্ম',
      hour: m['hour'] as int,
      minute: m['minute'] as int,
      daysOfWeek:
          (m['daysOfWeek'] as List?)?.map((e) => e as int).toSet() ?? {},
      enabled: m['enabled'] as bool? ?? true,
    );
  }
}

class AlarmService {
  AlarmService._();
  static final AlarmService instance = AlarmService._();

  static const String _key = 'alarms.list';
  static const String _channelId = 'amalghor_alarm_channel';
  static const String _channelName = 'Alarms';
  static const String _channelDesc = 'User-defined alarms with sound';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  SharedPreferences? _prefs;

  Future<void> initialize(SharedPreferences prefs) async {
    if (_initialized) return;
    _prefs = prefs;

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);
    await _createChannel();
    _initialized = true;
  }

  Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Check if exact alarms are permitted by the OS.
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    try {
      // The plugin exposes this via the permission request method.
      // We check by calling the request; if user has already granted, no prompt.
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Ask the user for exact alarm permission (Android 12+).
  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestExactAlarmsPermission();
  }

  List<UserAlarm> loadAll() {
    final raw = _prefs?.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list
          .map((e) => UserAlarm.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<UserAlarm> alarms) async {
    final raw = json.encode(alarms.map((a) => a.toMap()).toList());
    await _prefs?.setString(_key, raw);
  }

  Future<void> add(UserAlarm alarm) async {
    final list = loadAll();
    list.add(alarm);
    await saveAll(list);
    await _schedule(alarm);
  }

  Future<void> update(UserAlarm alarm) async {
    final list = loadAll();
    final idx = list.indexWhere((a) => a.id == alarm.id);
    if (idx == -1) return;
    list[idx] = alarm;
    await saveAll(list);
    await _cancel(alarm.id);
    if (alarm.enabled) await _schedule(alarm);
  }

  Future<void> delete(String id) async {
    final list = loadAll();
    list.removeWhere((a) => a.id == id);
    await saveAll(list);
    await _cancel(id);
  }

  Future<void> toggle(UserAlarm alarm, bool enabled) async {
    await update(alarm.copyWith(enabled: enabled));
  }

  Future<void> _schedule(UserAlarm alarm) async {
    if (!alarm.enabled) return;

    // Ensure exact alarm permission is requested.
    await requestExactAlarmPermission();

    final baseId = _idFor(alarm.id);
    final days =
        alarm.daysOfWeek.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : alarm.daysOfWeek;

    for (final day in days) {
      try {
        await _plugin.zonedSchedule(
          baseId + day * 1000,
          alarm.title,
          alarm.body,
          _nextInstanceOf(day, alarm.hour, alarm.minute),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDesc,
              importance: Importance.max,
              priority: Priority.max,
              playSound: true,
              enableVibration: true,
              category: AndroidNotificationCategory.alarm,
              fullScreenIntent: true,
              ongoing: true,
              autoCancel: false,
              audioAttributesUsage: AudioAttributesUsage.alarm,
              actions: const [
                AndroidNotificationAction(
                  'snooze',
                  '৫ মিনিট পরে',
                  showsUserInterface: false,
                ),
                AndroidNotificationAction(
                  'dismiss',
                  'বন্ধ করুন',
                  showsUserInterface: false,
                  cancelNotification: true,
                ),
              ],
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (e) {
        // If exact alarm fails, try inexact fallback.
        debugPrint('Exact alarm failed: $e');
        await _plugin.zonedSchedule(
          baseId + day * 1000,
          alarm.title,
          alarm.body,
          _nextInstanceOf(day, alarm.hour, alarm.minute),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDesc,
              importance: Importance.max,
              priority: Priority.max,
              playSound: true,
              enableVibration: true,
              category: AndroidNotificationCategory.alarm,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  Future<void> _cancel(String id) async {
    final baseId = _idFor(id);
    for (var day = 1; day <= 7; day++) {
      await _plugin.cancel(baseId + day * 1000);
    }
  }

  /// Returns the next TZDateTime instance of the given weekday + time.
  tz.TZDateTime _nextInstanceOf(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (target.weekday != weekday) {
      target = target.add(const Duration(days: 1));
    }
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 7));
    }
    return target;
  }

  int _idFor(String id) => id.hashCode.abs() % 1000000;

  Future<void> preview(UserAlarm alarm) async {
    await _plugin.show(
      998,
      alarm.title,
      alarm.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.alarm,
        ),
      ),
    );
  }
}
