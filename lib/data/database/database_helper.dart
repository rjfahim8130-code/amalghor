import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants.dart';
import '../models/amol_models.dart';
import '../models/prayer_times.dart';
import '../models/quran_models.dart';

/// Singleton SQLite wrapper for the app's main database.
///
/// Tables:
///   - prayer_cache     : rolling cache of computed prayer times
///   - quran_bookmarks  : user bookmarks (kept here for convenience)
///   - amol_tracker     : per-day Amol completion records
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createPrayerCache(db);
    await _createQuranBookmarks(db);
    await _createAmolTracker(db);
  }

  Future<void> _createPrayerCache(Database db) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tablePrayerCache} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_key TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        madhhab TEXT NOT NULL,
        method TEXT NOT NULL,
        fajr TEXT NOT NULL,
        dhuhr TEXT NOT NULL,
        asr TEXT NOT NULL,
        maghrib TEXT NOT NULL,
        isha TEXT NOT NULL,
        sunrise TEXT NOT NULL,
        solar_noon TEXT NOT NULL,
        sunset TEXT NOT NULL,
        imsak TEXT NOT NULL,
        midnight TEXT NOT NULL,
        last_third TEXT NOT NULL,
        first_third TEXT NOT NULL,
        ishraq TEXT NOT NULL,
        iftar TEXT NOT NULL,
        suhoor_end TEXT NOT NULL,
        UNIQUE(date_key, latitude, longitude, madhhab, method)
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_prayer_cache_date
      ON ${AppConstants.tablePrayerCache} (date_key)
    ''');
  }

  Future<void> _createQuranBookmarks(Database db) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableBookmarks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah INTEGER NOT NULL,
        ayah INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        note TEXT
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_bookmarks_surah
      ON ${AppConstants.tableBookmarks} (surah, ayah)
    ''');
  }

  Future<void> _createAmolTracker(Database db) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableAmolTracker} (
        amolId TEXT NOT NULL,
        dateIso TEXT NOT NULL,
        completedCount INTEGER NOT NULL DEFAULT 0,
        isDone INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (amolId, dateIso)
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_amol_date
      ON ${AppConstants.tableAmolTracker} (dateIso)
    ''');
  }

  // ─────────────────────────────────────────────
  // PRAYER CACHE
  // ─────────────────────────────────────────────

  Future<void> upsertPrayerTimes({
    required PrayerTimes times,
    required String madhhab,
    required String method,
  }) async {
    final db = await database;
    final dateKey = _dateKey(times.date);

    await db.insert(
      AppConstants.tablePrayerCache,
      {
        'date_key': dateKey,
        'latitude': times.latitude,
        'longitude': times.longitude,
        'madhhab': madhhab,
        'method': method,
        'fajr': times.fajr.toIso8601String(),
        'dhuhr': times.dhuhr.toIso8601String(),
        'asr': times.asr.toIso8601String(),
        'maghrib': times.maghrib.toIso8601String(),
        'isha': times.isha.toIso8601String(),
        'sunrise': times.sunrise.toIso8601String(),
        'solar_noon': times.solarNoon.toIso8601String(),
        'sunset': times.sunset.toIso8601String(),
        'imsak': times.sehriSafety.toIso8601String(),
        'midnight': times.islamicMidnight.toIso8601String(),
        'last_third': times.lastThirdStart.toIso8601String(),
        'first_third': times.firstThirdEnd.toIso8601String(),
        'ishraq': times.ishraq.toIso8601String(),
        'iftar': times.iftarSafety.toIso8601String(),
        'suhoor_end': times.sehriActual.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertPrayerTimesBatch(List<Map<String, Object?>> rows) async {
    final db = await database;
    final batch = db.batch();
    for (final r in rows) {
      batch.insert(
        AppConstants.tablePrayerCache,
        r,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<PrayerTimes?> getPrayerTimes({
    required DateTime date,
    required double latitude,
    required double longitude,
    required String madhhab,
    required String method,
  }) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.tablePrayerCache,
      where:
          'date_key = ? AND latitude = ? AND longitude = ? AND madhhab = ? AND method = ?',
      whereArgs: [
        _dateKey(date),
        latitude,
        longitude,
        madhhab,
        method,
      ],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final m = rows.first;
    DateTime p(String k) => DateTime.parse(m[k] as String);

    // Recompute derived times from stored anchors.
    final fajr = p('fajr');
    final maghrib = p('maghrib');
    final isha = p('isha');
    final sehriSafety = p('imsak');
    final sehriActual = p('suhoor_end');
    final iftarSafety = p('iftar');
    final lastThird = p('last_third');
    final firstThird = p('first_third');
    final midnight = p('midnight');

    // nextFajr ≈ fajr + 1 day (approximation; the exact value comes
    // from the calculation engine when computing fresh).
    final nextFajr = fajr.add(const Duration(days: 1));
    final ishaToFajr = nextFajr.difference(isha);
    final ishaMustahab = isha.add(
      Duration(milliseconds: ishaToFajr.inMilliseconds ~/ 3),
    );

    return PrayerTimes(
      date: fajr,
      latitude: (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] as num).toDouble(),
      fajr: fajr,
      dhuhr: p('dhuhr'),
      asr: p('asr'),
      maghrib: maghrib,
      isha: isha,
      sunrise: p('sunrise'),
      sunset: p('sunset'),
      solarNoon: p('solar_noon'),
      sehriSafety: sehriSafety,
      sehriActual: sehriActual,
      iftarSafety: iftarSafety,
      iftarActual: maghrib,
      tahajjudStart: lastThird,
      lastThirdStart: lastThird,
      islamicMidnight: midnight,
      firstThirdEnd: firstThird,
      ishraq: p('ishraq'),
      ishaMustahab: ishaMustahab,
      nextFajr: nextFajr,
    );
  }

  Future<void> clearPrayerCache() async {
    final db = await database;
    await db.delete(AppConstants.tablePrayerCache);
  }

  Future<void> prunePrayerCache({int days = 30}) async {
    final db = await database;
    final cutoff = DateTime.now()
        .subtract(Duration(days: days))
        .toIso8601String()
        .substring(0, 10);
    await db.delete(
      AppConstants.tablePrayerCache,
      where: 'date_key < ?',
      whereArgs: [cutoff],
    );
  }

  // ─────────────────────────────────────────────
  // QURAN BOOKMARKS
  // ─────────────────────────────────────────────

  Future<int> addBookmark({
    required int surah,
    required int ayah,
    String? note,
  }) async {
    final db = await database;
    return db.insert(
      AppConstants.tableBookmarks,
      {
        'surah': surah,
        'ayah': ayah,
        'createdAt': DateTime.now().toIso8601String(),
        'note': note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<QuranBookmark>> getBookmarks() async {
    final db = await database;
    final rows = await db.query(
      AppConstants.tableBookmarks,
      orderBy: 'createdAt DESC',
    );
    return rows
        .map(
          (m) => QuranBookmark(
            id: m['id'] as int,
            surahNumber: m['surah'] as int,
            ayahNumber: m['ayah'] as int,
            createdAt: DateTime.parse(m['createdAt'] as String),
            note: m['note'] as String?,
          ),
        )
        .toList();
  }

  Future<void> deleteBookmark(int id) async {
    final db = await database;
    await db.delete(
      AppConstants.tableBookmarks,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────────────────────────
  // AMOL TRACKER
  // ─────────────────────────────────────────────

  Future<void> upsertAmolProgress({
    required String amolId,
    required String dateIso,
    required int completedCount,
    required bool isDone,
  }) async {
    final db = await database;
    await db.insert(
      AppConstants.tableAmolTracker,
      {
        'amolId': amolId,
        'dateIso': dateIso,
        'completedCount': completedCount,
        'isDone': isDone ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AmolProgress>> getAmolProgressForDate(String dateIso) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.tableAmolTracker,
      where: 'dateIso = ?',
      whereArgs: [dateIso],
    );
    return rows.map((m) => AmolProgress.fromMap(m)).toList();
  }

  Future<void> resetAmolProgress(String dateIso) async {
    final db = await database;
    await db.delete(
      AppConstants.tableAmolTracker,
      where: 'dateIso = ?',
      whereArgs: [dateIso],
    );
  }

  // ─────────────────────────────────────────────
  // HOUSEKEEPING
  // ─────────────────────────────────────────────

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
