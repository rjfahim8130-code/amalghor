import 'package:flutter/foundation.dart';

import '../../data/models/prayer_times.dart';

/// Granularity options for the PDF calendar clustering.
enum ClusterGranularity {
  dayWise(minutes: 0, label: 'প্রতিদিন আলাদা (৩৬৫ দিন)'),
  tenSec(minutes: 0.1667, label: '১০ সেকেন্ডের গ্যাপ'),
  fifteenSec(minutes: 0.25, label: '১৫ সেকেন্ডের গ্যাপ'),
  twentySec(minutes: 0.3333, label: '২০ সেকেন্ডের গ্যাপ'),
  thirtySec(minutes: 0.5, label: '৩০ সেকেন্ডের গ্যাপ'),
  fortySec(minutes: 0.6667, label: '৪০ সেকেন্ডের গ্যাপ'),
  oneMin(minutes: 1.0, label: '১ মিনিটের গ্যাপ'),
  twoMin(minutes: 2.0, label: '২ মিনিটের গ্যাপ'),
  fiveMin(minutes: 5.0, label: '৫ মিনিটের গ্যাপ');

  final double minutes;
  final String label;

  const ClusterGranularity({
    required this.minutes,
    required this.label,
  });

  bool get isDayWise => this == ClusterGranularity.dayWise;
}

@immutable
class ClusterRow {
  final DateTime startDate;
  final DateTime endDate;
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

PrayerTimes _roundTimes(PrayerTimes t, double granularityMinutes) {
  DateTime roundTo(DateTime dt) {
    if (granularityMinutes >= 1.0) {
      final totalMin = dt.hour * 60 + dt.minute;
      final rounded =
          (totalMin / granularityMinutes).round() * granularityMinutes;
      final h = (rounded ~/ 60).toInt();
      final m = (rounded % 60).round();
      return DateTime(dt.year, dt.month, dt.day, h, m, 0);
    }

    final totalSec = dt.hour * 3600 + dt.minute * 60 + dt.second;
    final granularitySec = (granularityMinutes * 60).round();
    final rounded =
        (totalSec / granularitySec).round() * granularitySec;
    final h = rounded ~/ 3600;
    final m = (rounded % 3600) ~/ 60;
    final s = rounded % 60;
    return DateTime(dt.year, dt.month, dt.day, h, m, s);
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

bool _timesEqual(PrayerTimes a, PrayerTimes b) {
  return _sameSecond(a.sehriSafety, b.sehriSafety) &&
      _sameSecond(a.sehriActual, b.sehriActual) &&
      _sameSecond(a.fajr, b.fajr) &&
      _sameSecond(a.sunrise, b.sunrise) &&
      _sameSecond(a.ishraq, b.ishraq) &&
      _sameSecond(a.dhuhr, b.dhuhr) &&
      _sameSecond(a.asr, b.asr) &&
      _sameSecond(a.sunset, b.sunset) &&
      _sameSecond(a.iftarSafety, b.iftarSafety) &&
      _sameSecond(a.iftarActual, b.iftarActual) &&
      _sameSecond(a.maghrib, b.maghrib) &&
      _sameSecond(a.isha, b.isha) &&
      _sameSecond(a.ishaMustahab, b.ishaMustahab) &&
      _sameSecond(a.lastThirdStart, b.lastThirdStart);
}

bool _sameSecond(DateTime a, DateTime b) =>
    a.hour == b.hour && a.minute == b.minute && a.second == b.second;

bool isLeapYear(int year) {
  if (year % 400 == 0) return true;
  if (year % 100 == 0) return false;
  return year % 4 == 0;
}

enum PdfColumn {
  date,
  tahajjud,
  sehri,
  fajr,
  sunrise,
  ishraq,
  dhuhr,
  asr,
  sunset,
  iftar,
  maghrib,
  isha,
  ishaMustahab,
}

extension PdfColumnExt on PdfColumn {
  String get label {
    switch (this) {
      case PdfColumn.date:
        return 'তারিখ';
      case PdfColumn.tahajjud:
        return 'তাহাজ্জুদ';
      case PdfColumn.sehri:
        return 'সেহরি';
      case PdfColumn.fajr:
        return 'ফজর';
      case PdfColumn.sunrise:
        return 'সূর্যোদয়';
      case PdfColumn.ishraq:
        return 'ইশরাক';
      case PdfColumn.dhuhr:
        return 'যোহর';
      case PdfColumn.asr:
        return 'আসর';
      case PdfColumn.sunset:
        return 'সূর্যাস্ত';
      case PdfColumn.iftar:
        return 'ইফতার';
      case PdfColumn.maghrib:
        return 'মাগরিব';
      case PdfColumn.isha:
        return 'এশা';
      case PdfColumn.ishaMustahab:
        return 'মুস্তাহাব এশা';
    }
  }

  bool get requiresHanafi => this == PdfColumn.ishaMustahab;
}

@immutable
class PdfColumnSelection {
  final Set<PdfColumn> columns;

  const PdfColumnSelection(this.columns);

  factory PdfColumnSelection.defaultSelection({
    required bool isHanafi,
  }) {
    return PdfColumnSelection({
      PdfColumn.date,
      PdfColumn.tahajjud,
      PdfColumn.sehri,
      PdfColumn.fajr,
      PdfColumn.sunrise,
      PdfColumn.ishraq,
      PdfColumn.dhuhr,
      PdfColumn.asr,
      PdfColumn.sunset,
      PdfColumn.iftar,
      PdfColumn.maghrib,
      PdfColumn.isha,
      if (isHanafi) PdfColumn.ishaMustahab,
    });
  }

  bool contains(PdfColumn c) => columns.contains(c);

  List<PdfColumn> orderedList() {
    return PdfColumn.values.where(columns.contains).toList();
  }

  PdfColumnSelection toggle(PdfColumn c) {
    final copy = Set<PdfColumn>.from(columns);
    if (copy.contains(c)) {
      copy.remove(c);
    } else {
      copy.add(c);
    }
    return PdfColumnSelection(copy);
  }

  bool get isEmpty => columns.isEmpty;
  int get length => columns.length;

  Set<PdfColumn> get safeColumns =>
      columns.isEmpty ? {PdfColumn.date} : columns;
}
