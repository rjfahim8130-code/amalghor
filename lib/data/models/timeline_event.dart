import 'package:flutter/material.dart';

/// Semantic category of a timeline event.
enum TimelineEventKind {
  prayer,
  astronomical,
  islamicWindow,
  forbiddenWindow,
}

/// A single event in the 13-point daily timeline.
@immutable
class TimelineEvent {
  final String key;
  final DateTime time;
  final IconData icon;
  final TimelineEventKind kind;

  const TimelineEvent({
    required this.key,
    required this.time,
    required this.icon,
    required this.kind,
  });

  bool isPast(DateTime now) => now.isAfter(time);
  bool isCurrent(DateTime now, DateTime next) =>
      now.isAfter(time) && now.isBefore(next);
}

/// Builds the canonical 13-event timeline for a given day.
class TimelineBuilder {
  TimelineBuilder._();

  static List<TimelineEvent> build({
    required DateTime lastThird,
    required DateTime imsak,
    required DateTime fajr,
    required DateTime sunrise,
    required DateTime ishraq,
    required DateTime solarNoon,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime sunset,
    required DateTime maghrib,
    required DateTime isha,
    required DateTime midnight,
  }) {
    return <TimelineEvent>[
      TimelineEvent(
        key: 'lastThird',
        time: lastThird,
        icon: Icons.nightlight_round,
        kind: TimelineEventKind.islamicWindow,
      ),
      TimelineEvent(
        key: 'imsak',
        time: imsak,
        icon: Icons.alarm,
        kind: TimelineEventKind.islamicWindow,
      ),
      TimelineEvent(
        key: 'fajr',
        time: fajr,
        icon: Icons.mosque,
        kind: TimelineEventKind.prayer,
      ),
      TimelineEvent(
        key: 'sunrise',
        time: sunrise,
        icon: Icons.wb_twilight,
        kind: TimelineEventKind.astronomical,
      ),
      TimelineEvent(
        key: 'ishraq',
        time: ishraq,
        icon: Icons.wb_sunny_outlined,
        kind: TimelineEventKind.islamicWindow,
      ),
      TimelineEvent(
        key: 'solarNoon',
        time: solarNoon,
        icon: Icons.brightness_high,
        kind: TimelineEventKind.forbiddenWindow,
      ),
      TimelineEvent(
        key: 'dhuhr',
        time: dhuhr,
        icon: Icons.mosque,
        kind: TimelineEventKind.prayer,
      ),
      TimelineEvent(
        key: 'asr',
        time: asr,
        icon: Icons.mosque,
        kind: TimelineEventKind.prayer,
      ),
      TimelineEvent(
        key: 'sunset',
        time: sunset,
        icon: Icons.wb_twilight,
        kind: TimelineEventKind.astronomical,
      ),
      TimelineEvent(
        key: 'maghrib',
        time: maghrib,
        icon: Icons.restaurant,
        kind: TimelineEventKind.prayer,
      ),
      TimelineEvent(
        key: 'isha',
        time: isha,
        icon: Icons.mosque,
        kind: TimelineEventKind.prayer,
      ),
      TimelineEvent(
        key: 'midnight',
        time: midnight,
        icon: Icons.dark_mode,
        kind: TimelineEventKind.islamicWindow,
      ),
    ];
  }

  static int currentIndex(List<TimelineEvent> events, DateTime now) {
    for (int i = events.length - 1; i >= 0; i--) {
      if (!events[i].time.isAfter(now)) return i;
    }
    return 0;
  }

  static int nextIndex(List<TimelineEvent> events, DateTime now) {
    for (int i = 0; i < events.length; i++) {
      if (events[i].time.isAfter(now)) return i;
    }
    return events.length - 1;
  }
}
