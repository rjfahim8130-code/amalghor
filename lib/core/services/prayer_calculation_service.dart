import 'package:adhan/adhan.dart';
import 'package:amalghor/core/constants/app_constants.dart';
import 'package:amalghor/core/models/prayer_times_model.dart';

class PrayerCalculationService {
  static CalculationParameters _getParameters(Madhhab madhhab) {
    CalculationParameters params;

    // Using Muslim World League as base, then adjust Asr
    params = CalculationMethod.muslim_world_league.getParameters();

    switch (madhhab) {
      case Madhhab.hanafi:
        params.madhab = Madhab.hanafi;
        // Hanafi often uses 18° for Fajr/Isha in many regions, but MWL is 18° already
        break;
      case Madhhab.shafi:
      case Madhhab.maliki:
      case Madhhab.hanbali:
        params.madhab = Madhab.shafi;
        break;
    }

    // High latitude rule
    params.highLatitudeRule = HighLatitudeRule.middle_of_the_night;

    return params;
  }

  static PrayerTimesModel calculateForDate({
    required double latitude,
    required double longitude,
    required DateTime date,
    required Madhhab madhhab,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = _getParameters(madhhab);

    final dateComponents = DateComponents.from(date);
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    // Solar Noon approximation (midway between sunrise and sunset)
    final solarNoon = prayerTimes.sunrise.add(
      Duration(
        milliseconds: prayerTimes.sunset.difference(prayerTimes.sunrise).inMilliseconds ~/ 2,
      ),
    );

    // Ishraq is approx 15-20 min after sunrise
    final ishraq = prayerTimes.sunrise.add(const Duration(minutes: 20));

    // Last third of the night (for Tahajjud)
    final nightDuration = prayerTimes.fajr.difference(prayerTimes.isha);
    final lastThird = prayerTimes.isha.add(
      Duration(milliseconds: (nightDuration.inMilliseconds * 2) ~/ 3),
    );

    // Tahajjud start roughly after Isha + some time, but commonly last third
    final tahajjudStart = lastThird;

    return PrayerTimesModel(
      date: DateTime(date.year, date.month, date.day),
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      solarNoon: solarNoon,
      suhoorEnd: prayerTimes.fajr, // Suhoor ends at Fajr
      iftar: prayerTimes.maghrib, // Iftar at Maghrib
      ishraq: ishraq,
      tahajjudStart: tahajjudStart,
      lastThirdOfNight: lastThird,
    );
  }

  /// Calculate for a range of days and return list
  static List<PrayerTimesModel> calculateRange({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required int days,
    required Madhhab madhhab,
  }) {
    final list = <PrayerTimesModel>[];
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      list.add(calculateForDate(
        latitude: latitude,
        longitude: longitude,
        date: date,
        madhhab: madhhab,
      ));
    }
    return list;
  }

  /// Calculate full year
  static List<PrayerTimesModel> calculateYear({
    required double latitude,
    required double longitude,
    required int year,
    required Madhhab madhhab,
  }) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31);
    final days = end.difference(start).inDays + 1;
    return calculateRange(
      latitude: latitude,
      longitude: longitude,
      startDate: start,
      days: days,
      madhhab: madhhab,
    );
  }

  /// Get current prayer status based on now
  static CurrentPrayerStatus getCurrentStatus(PrayerTimesModel today) {
    final now = DateTime.now();

    final times = [
      (PrayerName.fajr, today.fajr),
      (PrayerName.sunrise, today.sunrise),
      (PrayerName.dhuhr, today.dhuhr),
      (PrayerName.asr, today.asr),
      (PrayerName.maghrib, today.maghrib),
      (PrayerName.isha, today.isha),
    ];

    // Find current and next
    PrayerName? current;
    PrayerName next = PrayerName.fajr;
    DateTime? currentEnd;
    DateTime nextStart = today.fajr.add(const Duration(days: 1)); // next day fajr fallback
    bool isPrayerTime = false;

    for (int i = 0; i < times.length; i++) {
      final name = times[i].$1;
      final time = times[i].$2;

      if (now.isBefore(time)) {
        next = name;
        nextStart = time;
        break;
      } else {
        // Check if we are still in this prayer window (until next prayer)
        final nextTime = i < times.length - 1
            ? times[i + 1].$2
            : today.fajr.add(const Duration(days: 1));

        if (now.isBefore(nextTime)) {
          // Special handling for non-prayer events
          if (name == PrayerName.sunrise) {
            current = null;
            isPrayerTime = false;
          } else {
            current = name;
            currentEnd = nextTime;
            isPrayerTime = true;
          }
          next = i < times.length - 1 ? times[i + 1].$1 : PrayerName.fajr;
          nextStart = nextTime;
        }
      }
    }

    // After Isha
    if (now.isAfter(today.isha)) {
      current = PrayerName.isha;
      isPrayerTime = true;
      next = PrayerName.fajr;
      nextStart = today.fajr.add(const Duration(days: 1));
      currentEnd = nextStart;
    }

    final remaining = nextStart.difference(now);

    String statusBn;
    String statusEn;

    if (isPrayerTime && current != null) {
      statusBn = '${current.bn} এর সময় চলছে';
      statusEn = '${current.en} time is ongoing';
    } else if (current == null && now.isAfter(today.sunrise) && now.isBefore(today.dhuhr)) {
      statusBn = 'সূর্যোদয় হয়ে গেছে';
      statusEn = 'Sunrise has passed';
    } else {
      statusBn = 'পরবর্তী নামাজের অপেক্ষা';
      statusEn = 'Waiting for next prayer';
    }

    return CurrentPrayerStatus(
      currentPrayer: current,
      nextPrayer: next,
      currentEndTime: currentEnd,
      nextStartTime: nextStart,
      remaining: remaining,
      isPrayerTime: isPrayerTime,
      statusBn: statusBn,
      statusEn: statusEn,
    );
  }
}
