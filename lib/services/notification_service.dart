import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants.dart';
import '../core/notification_messages.dart';
import '../data/models/prayer_times.dart';
import '../data/models/settings_model.dart';

/// Prayer reminder notification service.
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

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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
    await _requestExactAlarmPermission();
    _initialized = true;
  }

  Future<void> _requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestExactAlarmsPermission();
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final notificationsGranted =
          await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
      return notificationsGranted ?? false;
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

  /// Schedule prayer notifications using the user's per-prayer toggles
  /// and custom offsets.
  Future<void> scheduleDaily({
    required PrayerTimes times,
    required SettingsModel settings,
  }) async {
    if (!_initialized) await initialize();

    await cancelAll();

    // ─── Fajr ──────────────────────────────
    if (settings.notifFajr) {
      final msg = NotificationMessages.prayer(
        prayerKey: 'fajr',
        offsetMinutes: settings.offsetFajr,
      );
      final when =
          times.fajr.add(Duration(minutes: -settings.offsetFajr));
      await _scheduleAt(
        id: _idFajr,
        when: when,
        title: msg.title,
        body: msg.body,
      );
    }

    // ─── Dhuhr ─────────────────────────────
    if (settings.notifDhuhr) {
      final msg = NotificationMessages.prayer(
        prayerKey: 'dhuhr',
        offsetMinutes: settings.offsetDhuhr,
      );
      final when =
          times.dhuhr.add(Duration(minutes: -settings.offsetDhuhr));
      await _scheduleAt(
        id: _idDhuhr,
        when: when,
        title: msg.title,
        body: msg.body,
      );
    }

    // ─── Asr ───────────────────────────────
    if (settings.notifAsr) {
      final msg = NotificationMessages.prayer(
        prayerKey: 'asr',
        offsetMinutes: settings.offsetAsr,
      );
      final when =
          times.asr.add(Duration(minutes: -settings.offsetAsr));
      await _scheduleAt(
        id: _idAsr,
        when: when,
        title: msg.title,
        body: msg.body,
      );
    }

    // ─── Maghrib ───────────────────────────
    if (settings.notifMaghrib) {
      final msg = NotificationMessages.prayer(
        prayerKey: 'maghrib',
        offsetMinutes: settings.offsetMaghrib,
      );
      final when =
          times.maghrib.add(Duration(minutes: -settings.offsetMaghrib));
      await _scheduleAt(
        id: _idMaghrib,
        when: when,
        title: msg.title,
        body: msg.body,
      );
    }

    // ─── Isha ──────────────────────────────
    if (settings.notifIsha) {
      final msg = NotificationMessages.prayer(
        prayerKey: 'isha',
        offsetMinutes: settings.offsetIsha,
      );
      final when =
          times.isha.add(Duration(minutes: -settings.offsetIsha));
      await _scheduleAt(
        id: _idIsha,
        when: when,
        title: msg.title,
        body: msg.body,
      );
    }

    // ─── Sehri end ─────────────────────────
    if (settings.notifSehri) {
      final msg = NotificationMessages.sehri(settings.offsetSehri);
      final when = times.sehriSafety
          .subtract(Duration(minutes: settings.offsetSehri));
      if (when.isAfter(DateTime.now())) {
        await _scheduleAt(
          id: _idSehri,
          when: when,
          title: msg.title,
          body: msg.body,
        );
      }
    }

    // ─── Iftar ─────────────────────────────
    if (settings.notifIftar) {
      final msg = NotificationMessages.iftar(settings.offsetIftar);
      final when = times.iftarSafety
          .subtract(Duration(minutes: settings.offsetIftar));
      if (when.isAfter(DateTime.now())) {
        await _scheduleAt(
          id: _idIftar,
          when: when,
          title: msg.title,
          body: msg.body,
        );
      }
    }

    // ─── Tahajjud ──────────────────────────
    if (settings.notifTahajjud) {
      final msg = NotificationMessages.tahajjud(settings.offsetTahajjud);
      final when = times.lastThirdStart
          .subtract(Duration(minutes: settings.offsetTahajjud));
      if (when.isAfter(DateTime.now())) {
        await _scheduleAt(
          id: _idTahajjud,
          when: when,
          title: msg.title,
          body: msg.body,
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
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.reminder,
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
    );
  }

  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;
    const channel = AndroidNotificationChannel(
      AppConstants.notifChannelId,
      AppConstants.notifChannelName,
      description: AppConstants.notifChannelDesc,
      importance: Importance.max,
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
