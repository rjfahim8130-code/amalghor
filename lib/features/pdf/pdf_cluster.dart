import 'package:flutter/foundation.dart';

import '../../data/models/prayer_times.dart';

/// Granularity options for the PDF calendar clustering.
///
/// A cluster groups consecutive days whose prayer times are identical
/// when rounded to the selected granularity.
enum ClusterGranularity {
  dayWise(minutes: 0, label: 'Day-wise (365 rows)'),
  fifteenSec(minutes: 0.25, label: '15-second cluster'),
  twentySec(minutes: 0.34, label: '20-second cluster'),
  thirtySec(minutes: 0.5, label: '30-second cluster'),
  fortySec(minutes: 0.67, label: '40-second cluster'),
  oneMin(minutes: 1.0, label: '1-minute cluster');

  final double minutes;
  final String label;

  const ClusterGranularity({
    required this.minutes,
    required this.label,
  });

  bool get isDayWise => this == ClusterGranularity.dayWise;
}

/// A single row in the clustered PDF calendar.
///
/// Represents either one day (day-wise mode) or a range of days during
/// which all displayed prayer times remained identical after rounding.
@immutable
class ClusterRow {
  final DateTime startDate;
  final DateTime endDate;

  /// The prayer times used for display. For multi-day clusters, these
  /// are the rounded times from the first day of the range.
  final PrayerTimes times;

  const ClusterRow({
    required this.startDate,
    required this.endDate,
    required this.times,
  });

  bool get isSingleDay => startDate == endDate;

  int get dayCount => endDate.difference(startDate).inDays + 1;

  ClusterRow copyWith({
    DateTime? startDate,
    DateTime? endDate,
    PrayerTimes? times,
  }) {
    return ClusterRow(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      times: times ?? this.times,
    );
  }
}

/// The full PDF calendar data for one year.
@immutable
class ClusterResult {
  final int year;
  final double latitude;
  final double longitude;
  final ClusterGranularity granularity;
  final List<ClusterRow> rows;

  const ClusterResult({
    required this.year,
    required this.latitude,
    required this.longitude,
    required this.granularity,
    required this.rows,
  });

  int get totalDaysCovered =>
      rows.fold<int>(0, (sum, r) => sum + r.dayCount);
}

/// Builds clusters for a full year of prayer times.
///
/// The algorithm walks through every day, rounds each prayer time to
/// the requested granularity, and appends the day to the current
/// cluster if all displayed times match. Otherwise it starts a new
/// cluster.
///
/// Day-wise mode bypasses the rounding entirely and produces 365/366
/// rows (one per day).
ClusterResult buildClusters({
  required int year,
  required double latitude,
  required double longitude,
  required ClusterGranularity granularity,
  required List<PrayerTimes> yearTimes,
}) {
  assert(
    yearTimes.length == (isLeapYear(year) ? 366 : 365),
    'yearTimes must contain 365 or 366 entries',
  );

  if (granularity.isDayWise) {
    final rows = yearTimes
        .map(
          (t) => ClusterRow(
            startDate: t.date,
            endDate: t.date,
            times: t,
          ),
        )
        .toList();
    return ClusterResult(
      year: year,
      latitude: latitude,
      longitude: longitude,
      granularity: granularity,
      rows: rows,
    );
  }

  final rows = <ClusterRow>[];
  ClusterRow? current;

  for (final t in yearTimes) {
    final rounded = _roundTimes(t, granularity.minutes);

    if (current == null) {
      current = ClusterRow(
        startDate: t.date,
        endDate: t.date,
        times: rounded,
      );
    } else if (_timesEqual(current.times, rounded)) {
      current = current.copyWith(endDate: t.date);
    } else {
      rows.add(current);
      current = ClusterRow(
        startDate: t.date,
        endDate: t.date,
        times: rounded,
      );
    }
  }

  if (current != null) rows.add(current);

  return ClusterResult(
    year: year,
    latitude: latitude,
    longitude: longitude,
    granularity: granularity,
    rows: rows,
  );
}

// ─────────────────────────────────────────────
// INTERNAL
// ─────────────────────────────────────────────

/// Round all displayed prayer times to the nearest `granularity`
/// minutes.
PrayerTimes _roundTimes(PrayerTimes t, double granularityMinutes) {
  DateTime roundTo(DateTime dt) {
    final totalMinutes = dt.hour * 60 + dt.minute;
    final roundedTotal =
        (totalMinutes / granularityMinutes).round() * granularityMinutes;
    final h = (roundedTotal ~/ 60).toInt();
    final m = (roundedTotal % 60).round();
    // Preserve seconds as zero — clusters are minute-resolution.
    return DateTime(dt.year, dt.month, dt.day, h, m);
  }

  return t.copyWith(
    fajr: roundTo(t.fajr),
    dhuhr: roundTo(t.dhuhr),
    asr: roundTo(t.asr),
    maghrib: roundTo(t.maghrib),
    isha: roundTo(t.isha),
    sunrise: roundTo(t.sunrise),
    sunset: roundTo(t.sunset),
    sehriSafety: roundTo(t.sehriSafety),
    sehriActual: roundTo(t.sehriActual),
    iftarSafety: roundTo(t.iftarSafety),
    iftarActual: roundTo(t.iftarActual),
    ishraq: roundTo(t.ishraq),
    ishaMustahab: roundTo(t.ishaMustahab),
    lastThirdStart: roundTo(t.lastThirdStart),
    islamicMidnight: roundTo(t.islamicMidnight),
  );
}

/// Compare the display-relevant times only.
bool _timesEqual(PrayerTimes a, PrayerTimes b) {
  return _sameMinute(a.sehriSafety, b.sehriSafety) &&
      _sameMinute(a.sehriActual, b.sehriActual) &&
      _sameMinute(a.fajr, b.fajr) &&
      _sameMinute(a.sunrise, b.sunrise) &&
      _sameMinute(a.ishraq, b.ishraq) &&
      _sameMinute(a.dhuhr, b.dhuhr) &&
      _sameMinute(a.asr, b.asr) &&
      _sameMinute(a.sunset, b.sunset) &&
      _sameMinute(a.iftarSafety, b.iftarSafety) &&
      _sameMinute(a.iftarActual, b.iftarActual) &&
      _sameMinute(a.maghrib, b.maghrib) &&
      _sameMinute(a.isha, b.isha) &&
      _sameMinute(a.ishaMustahab, b.ishaMustahab) &&
      _sameMinute(a.lastThirdStart, b.lastThirdStart);
}

bool _sameMinute(DateTime a, DateTime b) =>
    a.hour == b.hour && a.minute == b.minute;

/// Leap-year helper.
bool isLeapYear(int year) {
  if (year % 400 == 0) return true;
  if (year % 100 == 0) return false;
  return year % 4 == 0;
}
