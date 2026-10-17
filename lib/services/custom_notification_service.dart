import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// A user-defined custom (silent) push notification.
@immutable
class UserNotification {
  final String id;
  final String title;
  final String body;
  final int hour;
  final int minute;
  final Set<int> daysOfWeek;
  final bool enabled;

  const UserNotification({
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

  UserNotification copyWith({
    String? title,
    String? body,
    int? hour,
    int? minute,
    Set<int>? daysOfWeek,
    bool? enabled,
  }) {
    return UserNotification(
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

  factory UserNotification.fromMap(Map<String, dynamic> m) {
    return UserNotification(
      id: m['id'] as String,
      title: m['title'] as String? ?? '📖 নোটিফিকেশন',
      body: m['body'] as String? ?? '',
      hour: m['hour'] as int,
      minute: m['minute'] as int,
      daysOfWeek:
          (m['daysOfWeek'] as List?)?.map((e) => e as int).toSet() ?? {},
      enabled: m['enabled'] as bool? ?? true,
    );
  }
}

/// Manage user-defined custom notifications (silent pushes).
///
/// These appear in the system tray but do NOT play a sound or vibrate.
class CustomNotificationService {
  CustomNotificationService._();
  static final CustomNotificationService instance =
      CustomNotificationService._();

  static const String _key = 'notifications.list';
  static const String _channelId = 'amalghor_custom_notif_channel';
  static const String _channelName = 'Custom Notifications';
  static const String _channelDesc =
      'User-defined silent push notifications for reminders';

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
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: false,
      showBadge: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  List<UserNotification> loadAll() {
    final raw = _prefs?.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list
          .map((e) => UserNotification.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<UserNotification> list) async {
    final raw = json.encode(list.map((a) => a.toMap()).toList());
    await _prefs?.setString(_key, raw);
  }

  Future<void> add(UserNotification n) async {
    final list = loadAll();
    list.add(n);
    await saveAll(list);
    await _schedule(n);
  }

  Future<void> update(UserNotification n) async {
    final list = loadAll();
    final idx = list.indexWhere((a) => a.id == n.id);
    if (idx == -1) return;
    list[idx] = n;
    await saveAll(list);
    await _cancel(n.id);
    if (n.enabled) await _schedule(n);
  }

  Future<void> delete(String id) async {
    final list = loadAll();
    list.removeWhere((a) => a.id == id);
    await saveAll(list);
    await _cancel(id);
  }

  Future<void> toggle(UserNotification n, bool enabled) async {
    await update(n.copyWith(enabled: enabled));
  }

  Future<void> _schedule(UserNotification n) async {
    if (!n.enabled) return;

    final baseId = _idFor(n.id);
    final days =
        n.daysOfWeek.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : n.daysOfWeek;

    for (final day in days) {
      await _plugin.zonedSchedule(
        baseId + day * 1000,
        n.title,
        n.body,
        _nextInstanceOf(day, n.hour, n.minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            playSound: false,
            enableVibration: false,
            category: AndroidNotificationCategory.reminder,
            styleInformation: BigTextStyleInformation(n.body),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
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

  Future<void> preview(UserNotification n) async {
    await _plugin.show(
      9997,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: false,
          enableVibration: false,
        ),
      ),
    );
  }
}
