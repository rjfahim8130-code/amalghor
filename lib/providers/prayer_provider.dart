import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/prayer_times.dart';
import '../data/models/settings_model.dart';
import '../data/repositories/prayer_repository.dart';
import '../services/adhan_service.dart';
import 'location_provider.dart';
import 'settings_provider.dart';

/// Provider for [AdhanService].
final adhanServiceProvider = Provider<AdhanService>((ref) {
  return const AdhanService();
});

/// Provider for [PrayerRepository].
final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepository(
    adhan: ref.watch(adhanServiceProvider),
  );
});

/// Inputs required to compute a prayer schedule.
class PrayerQuery {
  final double latitude;
  final double longitude;
  final DateTime date;
  final MadhhabType madhhab;
  final CalcMethodType method;

  const PrayerQuery({
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.madhhab,
    required this.method,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerQuery &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.date.year == date.year &&
          other.date.month == date.month &&
          other.date.day == date.day &&
          other.madhhab == madhhab &&
          other.method == method;

  @override
  int get hashCode => Object.hash(
        latitude,
        longitude,
        date.year,
        date.month,
        date.day,
        madhhab,
        method,
      );
}

/// The query describing *today's* prayer times, derived from the
/// current location and settings.
final todayPrayerQueryProvider = Provider<PrayerQuery>((ref) {
  final loc = ref.watch(locationProvider);
  final settings = ref.watch(settingsProvider);
  final now = DateTime.now();
  return PrayerQuery(
    latitude: loc.latitude,
    longitude: loc.longitude,
    date: DateTime(now.year, now.month, now.day),
    madhhab: settings.madhhab,
    method: settings.calcMethod,
  );
});

/// Future provider that resolves today's prayer times.
///
/// Cached by [PrayerQuery] — changing location/settings/madhhab
/// invalidates the cache and recomputes.
final todayPrayerProvider =
    FutureProvider.family<PrayerTimes, PrayerQuery>((ref, query) async {
  final repo = ref.watch(prayerRepositoryProvider);
  return repo.getForDate(
    latitude: query.latitude,
    longitude: query.longitude,
    date: query.date,
    madhhab: query.madhhab,
    method: query.method,
  );
});

/// Convenience: today's prayer times for the *current* query.
final currentDayPrayerProvider = FutureProvider<PrayerTimes>((ref) async {
  final query = ref.watch(todayPrayerQueryProvider);
  return ref.watch(todayPrayerProvider(query).future);
});

/// Family provider: prayer times for any given [DateTime] on the
/// currently selected location/settings.
final prayerForDateProvider =
    FutureProvider.family<PrayerTimes, DateTime>((ref, date) async {
  final loc = ref.watch(locationProvider);
  final settings = ref.watch(settingsProvider);
  final repo = ref.watch(prayerRepositoryProvider);

  return repo.getForDate(
    latitude: loc.latitude,
    longitude: loc.longitude,
    date: DateTime(date.year, date.month, date.day),
    madhhab: settings.madhhab,
    method: settings.calcMethod,
  );
});

/// Family provider: whole month of prayer times.
final prayerForMonthProvider =
    FutureProvider.family<List<PrayerTimes>, ({int year, int month})>(
        (ref, args) async {
  final loc = ref.watch(locationProvider);
  final settings = ref.watch(settingsProvider);
  final repo = ref.watch(prayerRepositoryProvider);

  return repo.getForMonth(
    latitude: loc.latitude,
    longitude: loc.longitude,
    year: args.year,
    month: args.month,
    madhhab: settings.madhhab,
    method: settings.calcMethod,
  );
});

/// Family provider: whole year of prayer times. Used by the PDF
/// generator and by the yearly planner.
final prayerForYearProvider =
    FutureProvider.family<List<PrayerTimes>, int>((ref, year) async {
  final loc = ref.watch(locationProvider);
  final settings = ref.watch(settingsProvider);
  final repo = ref.watch(prayerRepositoryProvider);

  return repo.getForYear(
    latitude: loc.latitude,
    longitude: loc.longitude,
    year: year,
    madhhab: settings.madhhab,
    method: settings.calcMethod,
  );
});

/// A derived provider giving the next prayer tuple for "now".
final nextPrayerProvider = Provider<({String key, DateTime time})?>((ref) {
  final async = ref.watch(currentDayPrayerProvider);
  return async.maybeWhen(
    data: (times) => times.nextPrayer(DateTime.now()),
    orElse: () => null,
  );
});
