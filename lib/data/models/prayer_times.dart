import 'package:flutter/foundation.dart';

/// Immutable data model representing all prayer and astronomical times
/// for a single day at a specific location.
///
/// This model is intentionally free of any calculation logic — it is a
/// pure data container produced by the calculation engine and consumed
/// by UI, database, and PDF layers.
@immutable
class PrayerTimes {
  final DateTime date;
  final double latitude;
  final double longitude;

  // ─── The 5 daily prayers ─────────────────────
  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  // ─── Astronomical anchors ────────────────────
  final DateTime sunrise;
  final DateTime solarNoon;
  final DateTime sunset;

  // ─── Extended Islamic timings ────────────────
  final DateTime imsak;         // Sehri end (typically Fajr − 5 min)
  final DateTime midnight;      // Islamic midnight (mid of Maghrib→Fajr)
  final DateTime lastThird;     // Last third of night (Tahajjud time)
  final DateTime firstThird;    // First third of night

  // ─── Contextual derived times ────────────────
  final DateTime ishraq;        // Sunrise + ~20 min (Duha prayer start)
  final DateTime iftar;         // Equals Maghrib for practical purposes
  final DateTime suhoorEnd;     // Alias of Imsak, more user-friendly name

  const PrayerTimes({
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunrise,
    required this.solarNoon,
    required this.sunset,
    required this.imsak,
    required this.midnight,
    required this.lastThird,
    required this.firstThird,
    required this.ishraq,
    required this.iftar,
    required this.suhoorEnd,
  });

  // ─────────────────────────────────────────────
  // COMPUTED HELPERS
  // ─────────────────────────────────────────────

  /// All five obligatory prayers keyed by a stable string id.
  Map<String, DateTime> get fivePrayers => {
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };

  /// Returns the next prayer strictly after [now], or Fajr of the next
  /// conceptual day if all today's prayers have passed.
  ///
  /// The returned tuple carries the prayer key for localization.
  ({String key, DateTime time}) nextPrayer(DateTime now) {
    final entries = fivePrayers.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final e in entries) {
      if (e.value.isAfter(now)) {
        return (key: e.key, time: e.value);
      }
    }
    // All passed today — next is Fajr tomorrow.
    return (key: 'fajr', time: fajr.add(const Duration(days: 1)));
  }

  /// Returns the currently active prayer (the most recent one that has
  /// started and whose window has not yet closed), or null before Fajr.
  ///
  /// A prayer's "window" here is simply the interval until the next prayer.
  ({String key, DateTime start, DateTime end})? currentPrayer(DateTime now) {
    final entries = <MapEntry<String, DateTime>>[
      MapEntry('fajr', fajr),
      MapEntry('sunrise', sunrise),
      MapEntry('dhuhr', dhuhr),
      MapEntry('asr', asr),
      MapEntry('maghrib', maghrib),
      MapEntry('isha', isha),
    ];

    for (int i = entries.length - 1; i >= 0; i--) {
      if (!entries[i].value.isAfter(now)) {
        final start = entries[i].value;
        final end = i + 1 < entries.length
            ? entries[i + 1].value
            : isha.add(const Duration(hours: 6)); // till late night
        return (key: entries[i].key, start: start, end: end);
      }
    }
    return null;
  }

  /// Duration until the next prayer.
  Duration timeUntilNext(DateTime now) {
    final n = nextPrayer(now);
    return n.time.difference(now);
  }

  /// Duration since the current prayer started (elapsed within its window).
  Duration? elapsedInCurrent(DateTime now) {
    final c = currentPrayer(now);
    if (c == null) return null;
    return now.difference(c.start);
  }

  /// True if the current moment falls within the "forbidden" windows:
  /// - Sunrise ± a few minutes
  /// - Solar noon ± a few minutes
  /// - Sunset ± a few minutes
  bool isForbiddenWindow(DateTime now) {
    bool within(DateTime anchor, int minutes) {
      final diff = now.difference(anchor).inMinutes;
      return diff.abs() <= minutes;
    }

    return within(sunrise, 15) || within(solarNoon, 5) || within(sunset, 15);
  }

  /// Convenience: returns the timeline event key for the given moment.
  /// See [TimelineEvent] for the full enumeration of phases.
  String phaseKey(DateTime now) {
    if (now.isBefore(imsak)) return 'lastThird';
    if (now.isBefore(fajr)) return 'imsak';
    if (now.isBefore(sunrise)) return 'fajr';
    if (now.isBefore(ishraq)) return 'sunrise';
    if (now.isBefore(solarNoon.subtract(const Duration(hours: 1)))) {
      return 'ishraq';
    }
    if (now.isBefore(dhuhr)) return 'solarNoon';
    if (now.isBefore(asr)) return 'dhuhr';
    if (now.isBefore(sunset)) return 'asr';
    if (now.isBefore(iftar)) return 'sunset';
    if (now.isBefore(isha)) return 'maghrib';
    if (now.isBefore(midnight)) return 'isha';
    return 'midnight';
  }

  // ─────────────────────────────────────────────
  // SERIALIZATION (for SQLite cache)
  // ─────────────────────────────────────────────

  /// JSON-safe map. All DateTimes stored as ISO-8601 strings.
  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'fajr': fajr.toIso8601String(),
        'dhuhr': dhuhr.toIso8601String(),
        'asr': asr.toIso8601String(),
        'maghrib': maghrib.toIso8601String(),
        'isha': isha.toIso8601String(),
        'sunrise': sunrise.toIso8601String(),
        'solar_noon': solarNoon.toIso8601String(),
        'sunset': sunset.toIso8601String(),
        'imsak': imsak.toIso8601String(),
        'midnight': midnight.toIso8601String(),
        'last_third': lastThird.toIso8601String(),
        'first_third': firstThird.toIso8601String(),
        'ishraq': ishraq.toIso8601String(),
        'iftar': iftar.toIso8601String(),
        'suhoor_end': suhoorEnd.toIso8601String(),
      };

  factory PrayerTimes.fromMap(Map<String, dynamic> m) {
    DateTime parse(String key) => DateTime.parse(m[key] as String);
    return PrayerTimes(
      date: parse('date'),
      latitude: (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] as num).toDouble(),
      fajr: parse('fajr'),
      dhuhr: parse('dhuhr'),
      asr: parse('asr'),
      maghrib: parse('maghrib'),
      isha: parse('isha'),
      sunrise: parse('sunrise'),
      solarNoon: parse('solar_noon'),
      sunset: parse('sunset'),
      imsak: parse('imsak'),
      midnight: parse('midnight'),
      lastThird: parse('last_third'),
      firstThird: parse('first_third'),
      ishraq: parse('ishraq'),
      iftar: parse('iftar'),
      suhoorEnd: parse('suhoor_end'),
    );
  }

  // ─────────────────────────────────────────────
  // COPY-WITH (used by cluster engine for rounding)
  // ─────────────────────────────────────────────
  PrayerTimes copyWith({
    DateTime? date,
    double? latitude,
    double? longitude,
    DateTime? fajr,
    DateTime? dhuhr,
    DateTime? asr,
    DateTime? maghrib,
    DateTime? isha,
    DateTime? sunrise,
    DateTime? solarNoon,
    DateTime? sunset,
    DateTime? imsak,
    DateTime? midnight,
    DateTime? lastThird,
    DateTime? firstThird,
    DateTime? ishraq,
    DateTime? iftar,
    DateTime? suhoorEnd,
  }) {
    return PrayerTimes(
      date: date ?? this.date,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      sunrise: sunrise ?? this.sunrise,
      solarNoon: solarNoon ?? this.solarNoon,
      sunset: sunset ?? this.sunset,
      imsak: imsak ?? this.imsak,
      midnight: midnight ?? this.midnight,
      lastThird: lastThird ?? this.lastThird,
      firstThird: firstThird ?? this.firstThird,
      ishraq: ishraq ?? this.ishraq,
      iftar: iftar ?? this.iftar,
      suhoorEnd: suhoorEnd ?? this.suhoorEnd,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimes &&
          other.date == date &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.fajr == fajr &&
          other.dhuhr == dhuhr &&
          other.asr == asr &&
          other.maghrib == maghrib &&
          other.isha == isha;

  @override
  int get hashCode => Object.hash(
        date,
        latitude,
        longitude,
        fajr,
        dhuhr,
        asr,
        maghrib,
        isha,
      );
}
