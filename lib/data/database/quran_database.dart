import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/quran_models.dart';

/// Dedicated SQLite database for the Quran module.
///
/// This is intentionally kept separate from the app's main database
/// so that:
///   - The Quran data can be pre-loaded once and never touched again.
///   - The user's main settings/amol data is not impacted by Quran
///     migrations.
///
/// On first launch, [ensureLoaded] parses three plain-text files
/// (Arabic, English, Bangla) from `assets/data/` and inserts every
/// Ayah into the `ayahs` table.
class QuranDatabase {
  QuranDatabase._();
  static final QuranDatabase instance = QuranDatabase._();

  static const String _dbName = 'quran.db';
  static const int _dbVersion = 1;

  static const String _tableSurahs = 'surahs';
  static const String _tableAyahs = 'ayahs';
  static const String _tableMeta = 'meta';

  Database? _db;

  /// Get the database, initializing it if necessary.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  // ─────────────────────────────────────────────
  // OPEN & CREATE
  // ─────────────────────────────────────────────
  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Surahs metadata
    await db.execute('''
      CREATE TABLE $_tableSurahs (
        number INTEGER PRIMARY KEY,
        name_arabic TEXT NOT NULL,
        name_english TEXT NOT NULL,
        name_bangla TEXT NOT NULL,
        name_transliteration TEXT NOT NULL,
        total_ayahs INTEGER NOT NULL,
        revelation_place TEXT NOT NULL
      )
    ''');

    // Ayahs — one row per verse
    await db.execute('''
      CREATE TABLE $_tableAyahs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah INTEGER NOT NULL,
        ayah INTEGER NOT NULL,
        text_arabic TEXT NOT NULL,
        text_bangla TEXT,
        text_english TEXT,
        UNIQUE(surah, ayah)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_ayahs_surah ON $_tableAyahs (surah, ayah)
    ''');

    // Metadata key-value store (e.g., "loaded": "true")
    await db.execute('''
      CREATE TABLE $_tableMeta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // ─────────────────────────────────────────────
  // LOAD FROM ASSETS (one-time)
  // ─────────────────────────────────────────────

  /// Ensure all Surah + Ayah data is loaded. Safe to call multiple
  /// times — the second call returns quickly if data already exists.
  Future<void> ensureLoaded({
    void Function(String stage, double progress)? onProgress,
  }) async {
    final db = await database;

    // Fast path — already loaded.
    final loaded = await db.query(
      _tableMeta,
      where: 'key = ?',
      whereArgs: ['loaded'],
      limit: 1,
    );
    if (loaded.isNotEmpty && loaded.first['value'] == '1') {
      onProgress?.call('complete', 1.0);
      return;
    }

    // 1. Load metadata JSON.
    onProgress?.call('Loading metadata...', 0.05);
    final metaRaw = await rootBundle.loadString(
      'assets/data/quran_metadata.json',
    );
    final metaJson = json.decode(metaRaw) as Map<String, dynamic>;
    final surahsRaw = (metaJson['surahs'] as List).cast<Map<String, dynamic>>();
    final surahs = surahsRaw.map(SurahMeta.fromMap).toList();

    // 2. Load three translation files.
    onProgress?.call('Loading Arabic text...', 0.15);
    final arabic = await _loadPipeFile('assets/data/quran_arabic.txt');

    onProgress?.call('Loading English text...', 0.30);
    final english = await _loadPipeFile('assets/data/quran_english.txt');

    onProgress?.call('Loading Bangla text...', 0.45);
    final bangla = await _loadPipeFile('assets/data/bn.bengali.txt');

    // 3. Insert everything in a single transaction.
    onProgress?.call('Building database...', 0.55);
    await db.transaction((txn) async {
      final surahBatch = txn.batch();
      for (final s in surahs) {
        surahBatch.insert(_tableSurahs, {
          'number': s.number,
          'name_arabic': s.nameArabic,
          'name_english': s.nameEnglish,
          'name_bangla': s.nameBangla,
          'name_transliteration': s.nameTransliteration,
          'total_ayahs': s.totalAyahs,
          'revelation_place': s.revelationPlace,
        });
      }
      await surahBatch.commit(noResult: true);

      onProgress?.call('Inserting verses...', 0.70);

      final ayahBatch = txn.batch();
      var count = 0;

      for (final entry in arabic.entries) {
        final surahNum = entry.key;
        final arabicAyahs = entry.value;

        for (var i = 0; i < arabicAyahs.length; i++) {
          final ayahNum = i + 1;

          final englishText =
              english[surahNum] != null && i < english[surahNum]!.length
                  ? english[surahNum]![i]
                  : null;

          final banglaText =
              bangla[surahNum] != null && i < bangla[surahNum]!.length
                  ? bangla[surahNum]![i]
                  : null;

          ayahBatch.insert(_tableAyahs, {
            'surah': surahNum,
            'ayah': ayahNum,
            'text_arabic': arabicAyahs[i],
            'text_english': englishText,
            'text_bangla': banglaText,
          });

          count++;
        }
      }

      await ayahBatch.commit(noResult: true);

      onProgress?.call('Finalizing...', 0.95);

      await txn.insert(_tableMeta, {
        'key': 'loaded',
        'value': '1',
      });
      await txn.insert(_tableMeta, {
        'key': 'total_ayahs',
        'value': count.toString(),
      });
    });

    onProgress?.call('complete', 1.0);
  }

    // ─────────────────────────────────────────────
  // INTERNAL — FILE LOADER
  // ─────────────────────────────────────────────

  /// Parse a plain-text Quran file where each line looks like:
  ///   `surahNumber|ayahNumber|text`
  ///
  /// Returns a map from surah number → list of ayah texts in order.
  Future<Map<int, List<String>>> _loadPipeFile(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final lines = raw.split('\n');
    final result = <int, List<String>>{};

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Split into at most 3 parts (text may contain '|').
      final parts = trimmed.split('|');
      if (parts.length < 3) continue;

      final surahNum = int.tryParse(parts[0].trim());
      if (surahNum == null) continue;

      // Skip the ayah number (parts[1]) — we rely on list order.
      final text = parts.sublist(2).join('|').trim();

      result.putIfAbsent(surahNum, () => []).add(text);
    }

    return result;
  }

  // ─────────────────────────────────────────────
  // QUERIES — SURAHS
  // ─────────────────────────────────────────────

  /// Fetch all 114 Surahs, sorted by number.
  Future<List<SurahMeta>> getAllSurahs() async {
    final db = await database;
    final rows = await db.query(_tableSurahs, orderBy: 'number ASC');
    return rows.map(_rowToSurah).toList();
  }

  /// Fetch a single Surah by its number.
  Future<SurahMeta?> getSurah(int number) async {
    final db = await database;
    final rows = await db.query(
      _tableSurahs,
      where: 'number = ?',
      whereArgs: [number],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToSurah(rows.first);
  }

  // ─────────────────────────────────────────────
  // QUERIES — AYAHS
  // ─────────────────────────────────────────────

  /// Fetch all ayahs of a given Surah, in order.
  Future<List<Ayah>> getAyahsOfSurah(int surahNumber) async {
    final db = await database;
    final rows = await db.query(
      _tableAyahs,
      where: 'surah = ?',
      whereArgs: [surahNumber],
      orderBy: 'ayah ASC',
    );
    return rows.map(_rowToAyah).toList();
  }

  /// Fetch a single Ayah.
  Future<Ayah?> getAyah(int surahNumber, int ayahNumber) async {
    final db = await database;
    final rows = await db.query(
      _tableAyahs,
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surahNumber, ayahNumber],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _rowToAyah(rows.first);
  }

  // ─────────────────────────────────────────────
  // STATS
  // ─────────────────────────────────────────────

  /// Get the total number of ayahs stored.
  Future<int> getTotalAyahs() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM $_tableAyahs',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  /// Whether the Quran data has been loaded.
  Future<bool> isLoaded() async {
    final db = await database;
    final rows = await db.query(
      _tableMeta,
      where: 'key = ?',
      whereArgs: ['loaded'],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == '1';
  }

  /// Wipe everything. Used only for debugging / re-loading.
  Future<void> reset() async {
    final db = await database;
    await db.delete(_tableSurahs);
    await db.delete(_tableAyahs);
    await db.delete(_tableMeta);
  }

  // ─────────────────────────────────────────────
  // ROW MAPPERS
  // ─────────────────────────────────────────────

  SurahMeta _rowToSurah(Map<String, Object?> row) => SurahMeta(
        number: row['number'] as int,
        nameArabic: row['name_arabic'] as String,
        nameEnglish: row['name_english'] as String,
        nameBangla: row['name_bangla'] as String,
        nameTransliteration: row['name_transliteration'] as String,
        totalAyahs: row['total_ayahs'] as int,
        revelationPlace: row['revelation_place'] as String,
      );

  Ayah _rowToAyah(Map<String, Object?> row) => Ayah(
        surahNumber: row['surah'] as int,
        ayahNumber: row['ayah'] as int,
        textArabic: row['text_arabic'] as String,
        textBangla: row['text_bangla'] as String?,
        textEnglish: row['text_english'] as String?,
      );

  /// Close the database (used in tests).
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
