import 'package:flutter/foundation.dart';

/// Immutable model holding every prayer and Islamic timing for a
/// single day at a specific location.
///
/// All times are safety-adjusted where appropriate:
///   - Sehri safety  = Fajr − 7 min
///   - Sehri actual  = Fajr − 5 min
///   - Iftar safety  = Maghrib + 3 min
///   - Iftar actual  = Maghrib
///
/// Night division timings (Hanafi et al.):
///   - firstThirdEnd   = Maghrib + 1/3 × night
///   - islamicMidnight = Maghrib + 1/2 × night
///   - lastThirdStart  = Maghrib + 2/3 × night
///   - ishaMustahab    = Isha    + 1/3 × (nextFajr − Isha)
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
  final DateTime sunset;
  final DateTime solarNoon;

  // ─── Sehri / Iftar (safety + actual) ─────────
  final DateTime sehriSafety;
  final DateTime sehriActual;
  final DateTime iftarSafety;
  final DateTime iftarActual;

  // ─── Extended Islamic windows ────────────────
  final DateTime tahajjudStart;     // = lastThirdStart
  final DateTime lastThirdStart;
  final DateTime islamicMidnight;
  final DateTime firstThirdEnd;

  // ─── Contextual ──────────────────────────────
  final DateTime ishraq;            // Sunrise + 20 min
  final DateTime ishaMustahab;      // Isha + 1/3 × (nextFajr − Isha)

  // ─── Next-day Fajr (for night-window maths) ──
  final DateTime nextFajr;

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
    required this.sunset,
    required this.solarNoon,
    required this.sehriSafety,
    required this.sehriActual,
    required this.iftarSafety,
    required this.iftarActual,
    required this.tahajjudStart,
    required this.lastThirdStart,
    required this.islamicMidnight,
    required this.firstThirdEnd,
    required this.ishraq,
    required this.ishaMustahab,
    required this.nextFajr,
  });

  // ─────────────────────────────────────────────
  // COMPUTED HELPERS
  // ─────────────────────────────────────────────

  Map<String, DateTime> get fivePrayers => {
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };

  /// Next prayer strictly after [now], or tomorrow's Fajr.
  ({String key, DateTime time}) nextPrayer(DateTime now) {
    final entries = fivePrayers.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final e in entries) {
      if (e.value.isAfter(now)) {
        return (key: e.key, time: e.value);
      }
    }
    return (key: 'fajr', time: nextFajr);
  }

  /// Currently active window, or null before Fajr.
  ({String key, DateTime start, DateTime end})? currentPrayer(DateTime now) {
    final entries = <MapEntry<String, DateTime>>[
      MapEntry('fajr', fajr),
      MapEntry('sunrise', sunrise),
      MapEntry('ishraq', ishraq),
      MapEntry('dhuhr', dhuhr),
      MapEntry('asr', asr),
      MapEntry('sunset', sunset),
      MapEntry('maghrib', maghrib),
      MapEntry('isha', isha),
    ];

    for (int i = entries.length - 1; i >= 0; i--) {
      if (!entries[i].value.isAfter(now)) {
        final start = entries[i].value;
        final end = i + 1 < entries.length
            ? entries[i + 1].value
            : nextFajr;
        return (key: entries[i].key, start: start, end: end);
      }
    }
    return null;
  }

  Duration timeUntilNext(DateTime now) {
    final n = nextPrayer(now);
    return n.time.difference(now);
  }

  /// All timings in chronological order — used by the multi-countdown
  /// widget on the home screen.
  List<({String key, DateTime time, String label})> allTimings(DateTime now) {
    return [
      (key: 'tahajjud', time: lastThirdStart, label: 'তাহাজ্জুদ'),
      (key: 'sehri', time: sehriSafety, label: 'সেহরি'),
      (key: 'fajr', time: fajr, label: 'ফজর'),
      (key: 'sunrise', time: sunrise, label: 'সূর্যোদয়'),
      (key: 'ishraq', time: ishraq, label: 'ইশরাক'),
      (key: 'dhuhr', time: dhuhr, label: 'যোহর'),
      (key: 'asr', time: asr, label: 'আসর'),
      (key: 'sunset', time: sunset, label: 'সূর্যাস্ত'),
      (key: 'iftar', time: iftarSafety, label: 'ইফতার'),
      (key: 'maghrib', time: maghrib, label: 'মাগরিব'),
      (key: 'isha', time: isha, label: 'এশা'),
      (key: 'ishaMustahab', time: ishaMustahab, label: 'মুস্তাহাব এশা'),
      (key: 'midnight', time: islamicMidnight, label: 'রাত অর্ধেক'),
    ];
  }

  // ─────────────────────────────────────────────
  // SERIALIZATION
  // ─────────────────────────────────────────────
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
        'sunset': sunset.toIso8601String(),
        'solar_noon': solarNoon.toIso8601String(),
        'sehri_safety': sehriSafety.toIso8601String(),
        'sehri_actual': sehriActual.toIso8601String(),
        'iftar_safety': iftarSafety.toIso8601String(),
        'iftar_actual': iftarActual.toIso8601String(),
        'tahajjud_start': tahajjudStart.toIso8601String(),
        'last_third_start': lastThirdStart.toIso8601String(),
        'islamic_midnight': islamicMidnight.toIso8601String(),
        'first_third_end': firstThirdEnd.toIso8601String(),
        'ishraq': ishraq.toIso8601String(),
        'isha_mustahab': ishaMustahab.toIso8601String(),
        'next_fajr': nextFajr.toIso8601String(),
      };

  factory PrayerTimes.fromMap(Map<String, dynamic> m) {
    DateTime p(String k) => DateTime.parse(m[k] as String);
    return PrayerTimes(
      date: p('date'),
      latitude: (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] as num).toDouble(),
      fajr: p('fajr'),
      dhuhr: p('dhuhr'),
      asr: p('asr'),
      maghrib: p('maghrib'),
      isha: p('isha'),
      sunrise: p('sunrise'),
      sunset: p('sunset'),
      solarNoon: p('solar_noon'),
      sehriSafety: p('sehri_safety'),
      sehriActual: p('sehri_actual'),
      iftarSafety: p('iftar_safety'),
      iftarActual: p('iftar_actual'),
      tahajjudStart: p('tahajjud_start'),
      lastThirdStart: p('last_third_start'),
      islamicMidnight: p('islamic_midnight'),
      firstThirdEnd: p('first_third_end'),
      ishraq: p('ishraq'),
      ishaMustahab: p('isha_mustahab'),
      nextFajr: p('next_fajr'),
    );
  }

  // ─────────────────────────────────────────────
  // COPY-WITH
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
    DateTime? sunset,
    DateTime? solarNoon,
    DateTime? sehriSafety,
    DateTime? sehriActual,
    DateTime? iftarSafety,
    DateTime? iftarActual,
    DateTime? tahajjudStart,
    DateTime? lastThirdStart,
    DateTime? islamicMidnight,
    DateTime? firstThirdEnd,
    DateTime? ishraq,
    DateTime? ishaMustahab,
    DateTime? nextFajr,
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
      sunset: sunset ?? this.sunset,
      solarNoon: solarNoon ?? this.solarNoon,
      sehriSafety: sehriSafety ?? this.sehriSafety,
      sehriActual: sehriActual ?? this.sehriActual,
      iftarSafety: iftarSafety ?? this.iftarSafety,
      iftarActual: iftarActual ?? this.iftarActual,
      tahajjudStart: tahajjudStart ?? this.tahajjudStart,
      lastThirdStart: lastThirdStart ?? this.lastThirdStart,
      islamicMidnight: islamicMidnight ?? this.islamicMidnight,
      firstThirdEnd: firstThirdEnd ?? this.firstThirdEnd,
      ishraq: ishraq ?? this.ishraq,
      ishaMustahab: ishaMustahab ?? this.ishaMustahab,
      nextFajr: nextFajr ?? this.nextFajr,
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
