import 'package:adhan/adhan.dart';

import '../data/models/prayer_times.dart';
import '../data/models/settings_model.dart';

/// Core astronomical prayer-time calculation service.
///
/// Wraps the `adhan` package and returns a domain-level [PrayerTimes]
/// object. All extended Islamic timings (Imsak, midnight, last third,
/// Ishraq) are computed here so that the rest of the app never has to
/// touch the raw `adhan` API.
class AdhanService {
  const AdhanService();

  /// Compute prayer times for [date] at the given coordinates.
  ///
  /// [madhhab] controls the Asr shadow factor (Hanafi = 2, others = 1).
  /// [method] selects the Fajr/Isha angle standard.
  PrayerTimes calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
    MadhhabType madhhab = MadhhabType.hanafi,
    CalcMethodType method = CalcMethodType.karachi,
    double? fajrAngle,
    double? ishaAngle,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = _buildParameters(
      madhhab: madhhab,
      method: method,
      fajrAngle: fajrAngle,
      ishaAngle: ishaAngle,
    );

    final dateComponents = DateComponents(date.year, date.month, date.day);
    final raw = PrayerTimes(
      coordinates,
      dateComponents,
      params,
    );

    return _mapToDomain(
      raw: raw,
      date: date,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Compute prayer times for an entire month (used by PDF generator).
  List<PrayerTimes> calculateMonth({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    MadhhabType madhhab = MadhhabType.hanafi,
    CalcMethodType method = CalcMethodType.karachi,
  }) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(daysInMonth, (i) {
      final date = DateTime(year, month, i + 1);
      return calculate(
        latitude: latitude,
        longitude: longitude,
        date: date,
        madhhab: madhhab,
        method: method,
      );
    });
  }

  /// Compute prayer times for an entire Gregorian year.
  List<PrayerTimes> calculateYear({
    required double latitude,
    required double longitude,
    required int year,
    MadhhabType madhhab = MadhhabType.hanafi,
    CalcMethodType method = CalcMethodType.karachi,
  }) {
    final start = DateTime(year, 1, 1);
    final isLeap = _isLeap(year);
    final total = isLeap ? 366 : 365;
    return List.generate(total, (i) {
      final date = start.add(Duration(days: i));
      return calculate(
        latitude: latitude,
        longitude: longitude,
        date: date,
        madhhab: madhhab,
        method: method,
      );
    });
  }

  // ─────────────────────────────────────────────
  // INTERNAL
  // ─────────────────────────────────────────────
  CalculationParameters _buildParameters({
    required MadhhabType madhhab,
    required CalcMethodType method,
    double? fajrAngle,
    double? ishaAngle,
  }) {
    CalculationParameters params;
    switch (method) {
      case CalcMethodType.karachi:
        params = CalculationMethod.karachi.getParameters();
        break;
      case CalcMethodType.mwl:
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case CalcMethodType.ummAlQura:
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case CalcMethodType.egyptian:
        params = CalculationMethod.egyptian.getParameters();
        break;
      case CalcMethodType.isna:
        params = CalculationMethod.north_america.getParameters();
        break;
      case CalcMethodType.tehran:
        params = CalculationMethod.tehran.getParameters();
        break;
      case CalcMethodType.shiaIthnaAshari:
        params = CalculationMethod.other.getParameters();
        params.fajrAngle = 16.0;
        params.ishaAngle = 14.0;
        break;
    }

    params.madhab =
        madhhab == MadhhabType.hanafi ? Madhab.hanafi : Madhab.shafi;

    if (fajrAngle != null) params.fajrAngle = fajrAngle;
    if (ishaAngle != null) params.ishaAngle = ishaAngle;

    return params;
  }

  PrayerTimes _mapToDomain({
    required dynamic raw,
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    // `raw` is the adhan `PrayerTimes` object. We access it dynamically to
    // avoid a naming clash with our own domain model of the same name.
    final fajr = raw.fajr as DateTime;
    final sunrise = raw.sunrise as DateTime;
    final dhuhr = raw.dhuhr as DateTime;
    final asr = raw.asr as DateTime;
    final maghrib = raw.maghrib as DateTime;
    final isha = raw.isha as DateTime;

    // Solar noon — computed as the midpoint between sunrise and sunset
    // (i.e. Maghrib when the sun has fully set).
    final sunset = maghrib;
    final solarNoon = sunrise.add(
      Duration(
        milliseconds: sunset.difference(sunrise).inMilliseconds ~/ 2,
      ),
    );

    // Extended Islamic timings.
    final imsak = fajr.subtract(const Duration(minutes: 5));
    final nextFajr = fajr.add(const Duration(days: 1));
    final night = nextFajr.difference(maghrib);

    final midnight = maghrib.add(
      Duration(milliseconds: night.inMilliseconds ~/ 2),
    );
    final lastThird = maghrib.add(
      Duration(milliseconds: (night.inMilliseconds * 2) ~/ 3),
    );
    final firstThird = maghrib.add(
      Duration(milliseconds: night.inMilliseconds ~/ 3),
    );

    // Ishraq = sunrise + ~20 minutes (start of Duha prayer).
    final ishraq = sunrise.add(const Duration(minutes: 20));

    return PrayerTimes(
      date: date,
      latitude: latitude,
      longitude: longitude,
      fajr: fajr,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      sunrise: sunrise,
      solarNoon: solarNoon,
      sunset: sunset,
      imsak: imsak,
      midnight: midnight,
      lastThird: lastThird,
      firstThird: firstThird,
      ishraq: ishraq,
      iftar: maghrib,
      suhoorEnd: imsak,
    );
  }

  bool _isLeap(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }
}
