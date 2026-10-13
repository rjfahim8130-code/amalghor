import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants.dart';
import '../data/models/prayer_times.dart';

/// Singleton wrapper around flutter_local_notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const int _idFajr = 1001;
  static const int _idDhuhr = 1002;
  static const int _idAsr = 1003;
  static const int _idMaghrib = 1004;
  static const int _idIsha = 1005;
  static const int _idSehri = 1101;
  static const int _idIftar = 1102;
  static const int _idTahajjud = 1103;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTap,
    );

    await _createAndroidChannel();
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> scheduleDaily({
    required PrayerTimes times,
    required String Function(String key) labelBuilder,
    bool fajr = true,
    bool dhuhr = true,
    bool asr = true,
    bool maghrib = true,
    bool isha = true,
    bool sehri = true,
    bool iftar = true,
    bool tahajjud = false,
  }) async {
    if (!_initialized) await initialize();

    await cancelAll();

    if (fajr) {
      await _scheduleAt(
        id: _idFajr,
        when: times.fajr,
        title: labelBuilder('fajr'),
        body: '${labelBuilder('fajr')} time has started.',
      );
    }
    if (dhuhr) {
      await _scheduleAt(
        id: _idDhuhr,
        when: times.dhuhr,
        title: labelBuilder('dhuhr'),
        body: '${labelBuilder('dhuhr')} time has started.',
      );
    }
    if (asr) {
      await _scheduleAt(
        id: _idAsr,
        when: times.asr,
        title: labelBuilder('asr'),
        body: '${labelBuilder('asr')} time has started.',
      );
    }
    if (maghrib) {
      await _scheduleAt(
        id: _idMaghrib,
        when: times.maghrib,
        title: labelBuilder('maghrib'),
        body: '${labelBuilder('maghrib')} time has started.',
      );
    }
    if (isha) {
      await _scheduleAt(
        id: _idIsha,
        when: times.isha,
        title: labelBuilder('isha'),
        body: '${labelBuilder('isha')} time has started.',
      );
    }
    if (sehri) {
      final t = times.sehriSafety.subtract(const Duration(minutes: 15));
      if (t.isAfter(DateTime.now())) {
        await _scheduleAt(
          id: _idSehri,
          when: t,
          title: labelBuilder('sehri'),
          body: 'সেহরি শেষ হবে ১৫ মিনিটে।',
        );
      }
    }
    if (iftar) {
      final t = times.iftarSafety.subtract(const Duration(minutes: 10));
      if (t.isAfter(DateTime.now())) {
        await _scheduleAt(
          id: _idIftar,
          when: t,
          title: labelBuilder('iftar'),
          body: 'ইফতার ১০ মিনিটে।',
        );
      }
    }
    if (tahajjud) {
      final t = times.lastThirdStart;
      if (t.isAfter(DateTime.now())) {
        await _scheduleAt(
          id: _idTahajjud,
          when: t,
          title: labelBuilder('tahajjud'),
          body: 'রাতের শেষ ১/৩ শুরু — তাহাজ্জুদের সময়।',
        );
      }
    }
  }

  Future<void> _scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (!when.isAfter(DateTime.now())) return;

    final scheduled = tz.TZDateTime.from(when, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notifChannelId,
          AppConstants.notifChannelName,
          channelDescription: AppConstants.notifChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;
    const channel = AndroidNotificationChannel(
      AppConstants.notifChannelId,
      AppConstants.notifChannelName,
      description: AppConstants.notifChannelDesc,
      importance: Importance.high,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onTap(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('Notification tapped: ${response.payload}');
    }
  }
}
