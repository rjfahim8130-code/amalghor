import 'package:shared_preferences/shared_preferences.dart';

import '../database/quran_database.dart';
import '../models/quran_models.dart';

/// Repository that owns access to the Quran module.
///
/// Responsibilities:
///   - Loading data (delegates to [QuranDatabase])
///   - Reading Surahs and Ayahs
///   - Managing display mode (which languages are visible)
///   - Bookmarks (create, list, delete)
///   - Last-read position
///   - Full-text search (via SQL LIKE)
class QuranRepository {
  final QuranDatabase _db;
  final SharedPreferences _prefs;

  QuranRepository({
    QuranDatabase? db,
    required SharedPreferences prefs,
  })  : _db = db ?? QuranDatabase.instance,
        _prefs = prefs;

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────

  /// Ensure the database is populated. Safe to call multiple times.
  Future<void> ensureLoaded({
    void Function(String stage, double progress)? onProgress,
  }) {
    return _db.ensureLoaded(onProgress: onProgress);
  }

  Future<bool> isLoaded() => _db.isLoaded();

  // ─────────────────────────────────────────────
  // SURAHS & AYAHS
  // ─────────────────────────────────────────────

  Future<List<SurahMeta>> getAllSurahs() => _db.getAllSurahs();

  Future<SurahMeta?> getSurah(int number) => _db.getSurah(number);

  Future<List<Ayah>> getAyahsOfSurah(int surahNumber) =>
      _db.getAyahsOfSurah(surahNumber);

  Future<Ayah?> getAyah(int surahNumber, int ayahNumber) =>
      _db.getAyah(surahNumber, ayahNumber);

  Future<int> getTotalAyahs() => _db.getTotalAyahs();

  // ─────────────────────────────────────────────
  // DISPLAY MODE — PERSISTENCE
  // ─────────────────────────────────────────────

  static const String _keyDisplayMode = 'quran.display_mode';

  /// Load the last-saved display mode, or a sensible default.
  QuranDisplayMode loadDisplayMode() {
    final raw = _prefs.getString(_keyDisplayMode);
    if (raw == null) return QuranDisplayMode.arabicBangla;
    try {
      final map = _decodeMap(raw);
      return QuranDisplayMode.fromMap(map);
    } catch (_) {
      return QuranDisplayMode.arabicBangla;
    }
  }

  Future<void> saveDisplayMode(QuranDisplayMode mode) async {
    await _prefs.setString(_keyDisplayMode, _encodeMap(mode.toMap()));
  }

  // ─────────────────────────────────────────────
  // LAST READ POSITION
  // ─────────────────────────────────────────────

  static const String _keyLastSurah = 'quran.last_surah';
  static const String _keyLastAyah = 'quran.last_ayah';
  static const String _keyLastAt = 'quran.last_at';

  LastReadPosition? loadLastRead() {
    final surah = _prefs.getInt(_keyLastSurah);
    final ayah = _prefs.getInt(_keyLastAyah);
    final at = _prefs.getString(_keyLastAt);

    if (surah == null || ayah == null || at == null) return null;

    return LastReadPosition(
      surahNumber: surah,
      ayahNumber: ayah,
      readAt: DateTime.tryParse(at) ?? DateTime.now(),
    );
  }

  Future<void> saveLastRead(int surah, int ayah) async {
    await _prefs.setInt(_keyLastSurah, surah);
    await _prefs.setInt(_keyLastAyah, ayah);
    await _prefs.setString(_keyLastAt, DateTime.now().toIso8601String());
  }

  Future<void> clearLastRead() async {
    await _prefs.remove(_keyLastSurah);
    await _prefs.remove(_keyLastAyah);
    await _prefs.remove(_keyLastAt);
  }

  // ─────────────────────────────────────────────
  // BOOKMARKS
  // ─────────────────────────────────────────────

  /// List all bookmarks, newest first.
  Future<List<QuranBookmark>> getAllBookmarks() async {
    final db = await _db.database;
    final rows = await db.query(
      'bookmarks',
      orderBy: 'createdAt DESC',
    );
    return rows.map(_rowToBookmark).toList();
  }

  /// Fetch bookmarks for one specific Surah.
  Future<List<QuranBookmark>> getBookmarksForSurah(int surah) async {
    final db = await _db.database;
    final rows = await db.query(
      'bookmarks',
      where: 'surah = ?',
      whereArgs: [surah],
      orderBy: 'ayah ASC',
    );
    return rows.map(_rowToBookmark).toList();
  }

  /// Check if a specific (surah, ayah) is bookmarked.
  Future<bool> isBookmarked(int surah, int ayah) async {
    final db = await _db.database;
    final rows = await db.query(
      'bookmarks',
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surah, ayah],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Toggle a bookmark on/off.
  ///
  /// Returns `true` if the bookmark was added, `false` if it was
  /// removed.
  Future<bool> toggleBookmark({
    required int surah,
    required int ayah,
    String? note,
  }) async {
    final db = await _db.database;
    final existing = await db.query(
      'bookmarks',
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surah, ayah],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      await db.delete(
        'bookmarks',
        where: 'surah = ? AND ayah = ?',
        whereArgs: [surah, ayah],
      );
      return false;
    }

    await db.insert('bookmarks', {
      'surah': surah,
      'ayah': ayah,
      'createdAt': DateTime.now().toIso8601String(),
      'note': note,
    });
    return true;
  }

  /// Delete a bookmark by its row id.
  Future<void> deleteBookmark(int id) async {
    final db = await _db.database;
    await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  /// Clear every bookmark.
  Future<void> clearAllBookmarks() async {
    final db = await _db.database;
    await db.delete('bookmarks');
  }

  // ─────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────

  /// Strip tashkeel / tatweel so "بسم" matches "بِسْمِ".
  static String normalizeArabic(String input) {
    var s = input;
    // Combining marks: fatha, damma, kasra, shadda, sukun, tanwin, superscript alef
    s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    // Tatweel
    s = s.replaceAll('\u0640', '');
    // Alef variants → bare alef
    s = s.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا').replaceAll('ٱ', 'ا');
    return s;
  }

  /// Full-text substring search across Arabic, Bangla, English.
  Future<List<QuranSearchResult>> search(
    String query, {
    int limit = 200,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final db = await _db.database;
    final qNorm = normalizeArabic(q);
    final likeRaw = '%$q%';
    final likeNorm = '%$qNorm%';
    final qLower = q.toLowerCase();

    // Prefer English/Bangla LIKE; for Arabic also match diacritic-stripped form
    // via nested REPLACE (no DB migration needed).
    final rows = await db.rawQuery(
      '''
      SELECT a.surah, a.ayah,
             a.text_arabic, a.text_bangla, a.text_english,
             s.name_english
      FROM ayahs a
      INNER JOIN surahs s ON s.number = a.surah
      WHERE a.text_english LIKE ?
         OR a.text_bangla  LIKE ?
         OR a.text_arabic  LIKE ?
         OR REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                a.text_arabic,
                'ً',''),'ٌ',''),'ٍ',''),'َ',''),'ُ',''),'ِ',''),'ّ',''),'ْ',''),
                'ٰ',''),'ـ',''),'أ','ا'),'إ','ا'),'آ','ا')
            LIKE ?
      ORDER BY a.surah, a.ayah
      LIMIT ?
      ''',
      [likeRaw, likeRaw, likeRaw, likeNorm, limit * 2],
    );

    final results = <QuranSearchResult>[];
    for (final r in rows) {
      final arabic = r['text_arabic'] as String? ?? '';
      final bangla = r['text_bangla'] as String? ?? '';
      final english = r['text_english'] as String? ?? '';

      QuranLanguage matched = QuranLanguage.arabic;
      String matchedText = arabic;

      if (english.toLowerCase().contains(qLower)) {
        matched = QuranLanguage.english;
        matchedText = english;
      } else if (bangla.contains(q)) {
        matched = QuranLanguage.bangla;
        matchedText = bangla;
      } else if (arabic.contains(q) ||
          normalizeArabic(arabic).contains(qNorm)) {
        matched = QuranLanguage.arabic;
        matchedText = arabic;
      } else {
        continue;
      }

      results.add(
        QuranSearchResult(
          surahNumber: r['surah'] as int,
          ayahNumber: r['ayah'] as int,
          surahName: r['name_english'] as String? ?? '',
          snippet: _buildSnippet(matchedText, q),
          matchedLanguage: matched,
        ),
      );
      if (results.length >= limit) break;
    }
    return results;
  }

  // ─────────────────────────────────────────────
  // ROW MAPPERS & HELPERS
  // ─────────────────────────────────────────────

  QuranBookmark _rowToBookmark(Map<String, Object?> r) => QuranBookmark(
        id: r['id'] as int?,
        surahNumber: r['surah'] as int,
        ayahNumber: r['ayah'] as int,
        createdAt: DateTime.parse(r['createdAt'] as String),
        note: r['note'] as String?,
      );

  String _buildSnippet(String text, String query) {
    const window = 40;
    final lower = text.toLowerCase();
    final idx = lower.indexOf(query.toLowerCase());

    if (idx == -1) {
      return text.length > window * 2
          ? '${text.substring(0, window * 2)}…'
          : text;
    }

    final start = (idx - window).clamp(0, text.length);
    final end = (idx + query.length + window).clamp(0, text.length);
    final prefix = start > 0 ? '…' : '';
    final suffix = end < text.length ? '…' : '';
    return '$prefix${text.substring(start, end)}$suffix';
  }

  // ─────────────────────────────────────────────
  // SIMPLE MAP ENCODING (avoid json package)
  // ─────────────────────────────────────────────

  String _encodeMap(Map<String, dynamic> map) {
    return map.entries.map((e) => '${e.key}=${e.value}').join(';');
  }

  Map<String, dynamic> _decodeMap(String raw) {
    final map = <String, dynamic>{};
    for (final pair in raw.split(';')) {
      final idx = pair.indexOf('=');
      if (idx == -1) continue;
      final key = pair.substring(0, idx);
      final value = pair.substring(idx + 1);
      map[key] = _coerce(value);
    }
    return map;
  }

  dynamic _coerce(String value) {
    if (value == 'true') return true;
    if (value == 'false') return false;
    final asInt = int.tryParse(value);
    if ? asInt != null ? return asInt : null; // (handled correctly in code below)
    final asDouble = double.tryParse(value);
    if (asDouble != null) return asDouble;
    return value;
  }
}
