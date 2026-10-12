import '../../services/adhan_service.dart';
import '../database/database_helper.dart';
import '../models/prayer_times.dart';
import '../models/settings_model.dart';

/// High-level repository for prayer times.
///
/// Responsibilities:
///   - Cache-aware reads: check DB first, fall back to astronomical
///     calculation, and persist the result.
///   - Bulk warm-up of a 2-year cache window (current + next year).
class PrayerRepository {
  final AdhanService _adhan;
  final DatabaseHelper _db;

  PrayerRepository({
    AdhanService? adhan,
    DatabaseHelper? db,
  })  : _adhan = adhan ?? const AdhanService(),
        _db = db ?? DatabaseHelper.instance;

  /// Get prayer times for [date] at the given coordinates.
  ///
  /// Order of resolution:
  ///   1. SQLite cache
  ///   2. Astronomical calculation (then persist)
  Future<PrayerTimes> getForDate({
    required double latitude,
    required double longitude,
    required DateTime date,
    required MadhhabType madhhab,
    required CalcMethodType method,
  }) async {
    final cached = await _db.getPrayerTimes(
      date: date,
      latitude: latitude,
      longitude: longitude,
      madhhab: madhhab.name,
      method: method.name,
    );
    if (cached != null) return cached;

    final computed = _adhan.calculate(
      latitude: latitude,
      longitude: longitude,
      date: date,
      madhhab: madhhab,
      method: method,
    );

    await _db.upsertPrayerTimes(
      times: computed,
      madhhab: madhhab.name,
      method: method.name,
    );

    return computed;
  }

  /// Fetch (or compute) prayer times for every day of a month.
  Future<List<PrayerTimes>> getForMonth({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    required MadhhabType madhhab,
    required CalcMethodType method,
  }) async {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final result = <PrayerTimes>[];
    for (int d = 1; d <= daysInMonth; d++) {
      result.add(
        await getForDate(
          latitude: latitude,
          longitude: longitude,
          date: DateTime(year, month, d),
          madhhab: madhhab,
          method: method,
        ),
      );
    }
    return result;
  }

  /// Fetch (or compute) prayer times for every day of a year.
  Future<List<PrayerTimes>> getForYear({
    required double latitude,
    required double longitude,
    required int year,
    required MadhhabType madhhab,
    required CalcMethodType method,
  }) async {
    final start = DateTime(year, 1, 1);
    final isLeap = _isLeap(year);
    final total = isLeap ? 366 : 365;

    final result = <PrayerTimes>[];
    for (int i = 0; i < total; i++) {
      result.add(
        await getForDate(
          latitude: latitude,
          longitude: longitude,
          date: start.add(Duration(days: i)),
          madhhab: madhhab,
          method: method,
        ),
      );
    }
    return result;
  }

  /// Warm up the cache for the current year and the next year.
  ///
  /// Call this once at app start (or in a background isolate) so that
  /// subsequent reads are instant. Silently ignores failures.
  Future<void> warmUpTwoYears({
    required double latitude,
    required double longitude,
    required MadhhabType madhhab,
    required CalcMethodType method,
  }) async {
    final now = DateTime.now();
    final currentYear = now.year;

    for (final year in [currentYear, currentYear + 1]) {
      final days = _isLeap(year) ? 366 : 365;
      final start = DateTime(year, 1, 1);

      final rows = <Map<String, Object?>>[];
      for (int i = 0; i < days; i++) {
        final date = start.add(Duration(days: i));
        final t = _adhan.calculate(
          latitude: latitude,
          longitude: longitude,
          date: date,
          madhhab: madhhab,
          method: method,
        );
        rows.add({
          'date_key': _dateKey(date),
          'latitude': latitude,
          'longitude': longitude,
          'madhhab': madhhab.name,
          'method': method.name,
          'fajr': t.fajr.toIso8601String(),
          'dhuhr': t.dhuhr.toIso8601String(),
          'asr': t.asr.toIso8601String(),
          'maghrib': t.maghrib.toIso8601String(),
          'isha': t.isha.toIso8601String(),
          'sunrise': t.sunrise.toIso8601String(),
          'solar_noon': t.solarNoon.toIso8601String(),
          'sunset': t.sunset.toIso8601String(),
          'imsak': t.imsak.toIso8601String(),
          'midnight': t.midnight.toIso8601String(),
          'last_third': t.lastThird.toIso8601String(),
          'first_third': t.firstThird.toIso8601String(),
          'ishraq': t.ishraq.toIso8601String(),
          'iftar': t.iftar.toIso8601String(),
          'suhoor_end': t.suhoorEnd.toIso8601String(),
        });
      }
      await _db.upsertPrayerTimesBatch(rows);
    }
  }

  /// Clear the cache and prune old rows.
  Future<void> clearCache() => _db.clearPrayerCache();
  Future<void> prune({int days = 30}) =>
      _db.prunePrayerCache(days: days);

  bool _isLeap(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
