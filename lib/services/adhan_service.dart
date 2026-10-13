import 'package:adhan/adhan.dart' as adhan;

import '../data/models/prayer_times.dart';
import '../data/models/settings_model.dart';

/// Core astronomical prayer-time calculation service.
///
/// Produces a fully-computed [PrayerTimes] object including all
/// extended Islamic timings:
///   - Sehri safety & actual
///   - Iftar safety & actual
///   - Night divisions (1/3, 1/2, 2/3)
///   - Tahajjud start
///   - Ishraq
///   - Isha Mustahab (Hanafi)
class AdhanService {
  const AdhanService();

  /// Safety offsets (minutes).
  static const int sehriSafetyOffset = 7;
  static const int sehriActualOffset = 5;
  static const int iftarSafetyOffset = 3;
  static const int ishraqOffset = 20;

  PrayerTimes calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
    MadhhabType madhhab = MadhhabType.hanafi,
    CalcMethodType method = CalcMethodType.karachi,
    double? fajrAngle,
    double? ishaAngle,
  }) {
    final coords = adhan.Coordinates(latitude, longitude);
    final params = _buildParameters(
      madhhab: madhhab,
      method: method,
      fajrAngle: fajrAngle,
      ishaAngle: ishaAngle,
    );

    final dateComponents =
        adhan.DateComponents(date.year, date.month, date.day);
    final raw = adhan.PrayerTimes(coords, dateComponents, params);

    // ─── Compute tomorrow's Fajr for night maths ──
    final tomorrow = date.add(const Duration(days: 1));
    final tomorrowComponents =
        adhan.DateComponents(tomorrow.year, tomorrow.month, tomorrow.day);
    final tomorrowRaw = adhan.PrayerTimes(
      coords,
      tomorrowComponents,
      params,
    );

    return _mapToDomain(
      raw: raw,
      nextFajr: tomorrowRaw.fajr,
      date: date,
      latitude: latitude,
      longitude: longitude,
    );
  }

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
      return calculate(
        latitude: latitude,
        longitude: longitude,
        date: DateTime(year, month, i + 1),
        madhhab: madhhab,
        method: method,
      );
    });
  }

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
      return calculate(
        latitude: latitude,
        longitude: longitude,
        date: start.add(Duration(days: i)),
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
    required DateTime nextFajr,
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

    // Solar noon.
    final solarNoon = sunrise.add(
      Duration(
        milliseconds: maghrib.difference(sunrise).inMilliseconds ~/ 2,
      ),
    );

    // ─── Sehri / Iftar ───────────────────────────
    final sehriSafety =
        fajr.subtract(const Duration(minutes: sehriSafetyOffset));
    final sehriActual =
        fajr.subtract(const Duration(minutes: sehriActualOffset));
    final iftarSafety =
        maghrib.add(const Duration(minutes: iftarSafetyOffset));
    final iftarActual = maghrib;

    // ─── Night divisions (Maghrib → next Fajr) ──
    final night = nextFajr.difference(maghrib);
    final oneThird = Duration(
      milliseconds: night.inMilliseconds ~/ 3,
    );
    final halfNight = Duration(
      milliseconds: night.inMilliseconds ~/ 2,
    );

    final firstThirdEnd = maghrib.add(oneThird);
    final islamicMidnight = maghrib.add(halfNight);
    final lastThirdStart = maghrib.add(oneThird + oneThird);

    // ─── Ishraq ──────────────────────────────────
    final ishraq = sunrise.add(const Duration(minutes: ishraqOffset));

    // ─── Isha Mustahab (Isha + 1/3 × Isha→Fajr) ─
    final ishaToFajr = nextFajr.difference(isha);
    final ishaMustahab = isha.add(
      Duration(milliseconds: ishaToFajr.inMilliseconds ~/ 3),
    );

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
      sunset: maghrib,
      solarNoon: solarNoon,
      sehriSafety: sehriSafety,
      sehriActual: sehriActual,
      iftarSafety: iftarSafety,
      iftarActual: iftarActual,
      tahajjudStart: lastThirdStart,
      lastThirdStart: lastThirdStart,
      islamicMidnight: islamicMidnight,
      firstThirdEnd: firstThirdEnd,
      ishraq: ishraq,
      ishaMustahab: ishaMustahab,
      nextFajr: nextFajr,
    );
  }

  bool _isLeap(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }
}
