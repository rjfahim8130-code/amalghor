import 'package:adhan/adhan.dart' as adhan;

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
  PrayerTimes calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
    MadhhabType madhhab = MadhhabType.hanafi,
    CalcMethodType method = CalcMethodType.karachi,
    double? fajrAngle,
    double? ishaAngle,
  }) {
    final coordinates = adhan.Coordinates(latitude, longitude);
    final params = _buildParameters(
      madhhab: madhhab,
      method: method,
      fajrAngle: fajrAngle,
      ishaAngle: ishaAngle,
    );

    final dateComponents =
        adhan.DateComponents(date.year, date.month, date.day);
    final raw = adhan.PrayerTimes(coordinates, dateComponents, params);

    return _mapToDomain(
      raw: raw,
      date: date,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Compute prayer times for an entire month.
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
    final total = _isLeap(year) ? 366 : 365;
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
  adhan.CalculationParameters _buildParameters({
    required MadhhabType madhhab,
    required CalcMethodType method,
    double? fajrAngle,
    double? ishaAngle,
  }) {
    adhan.CalculationParameters params;
    switch (method) {
      case CalcMethodType.karachi:
        params = adhan.CalculationMethod.karachi.getParameters();
        break;
      case CalcMethodType.mwl:
        params = adhan.CalculationMethod.muslim_world_league.getParameters();
        break;
      case CalcMethodType.ummAlQura:
        params = adhan.CalculationMethod.umm_al_qura.getParameters();
        break;
      case CalcMethodType.egyptian:
        params = adhan.CalculationMethod.egyptian.getParameters();
        break;
      case CalcMethodType.isna:
        params = adhan.CalculationMethod.north_america.getParameters();
        break;
      case CalcMethodType.tehran:
        params = adhan.CalculationMethod.tehran.getParameters();
        break;
      case CalcMethodType.shiaIthnaAshari:
        params = adhan.CalculationMethod.other.getParameters();
        params.fajrAngle = 16.0;
        params.ishaAngle = 14.0;
        break;
    }

    params.madhab =
        madhhab == MadhhabType.hanafi ? adhan.Madhab.hanafi : adhan.Madhab.shafi;

    if (fajrAngle != null) params.fajrAngle = fajrAngle;
    if (ishaAngle != null) params.ishaAngle = ishaAngle;

    return params;
  }

  PrayerTimes _mapToDomain({
    required adhan.PrayerTimes raw,
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    final fajr = raw.fajr;
    final sunrise = raw.sunrise;
    final dhuhr = raw.dhuhr;
    final asr = raw.asr;
    final maghrib = raw.maghrib;
    final isha = raw.isha;

    final sunset = maghrib;
    final solarNoon = sunrise.add(
      Duration(
        milliseconds: sunset.difference(sunrise).inMilliseconds ~/ 2,
      ),
    );

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
