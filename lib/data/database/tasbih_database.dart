import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/tasbih_models.dart';

/// Dedicated SQLite database for the Tasbih counter module.
class TasbihDatabase {
  TasbihDatabase._();
  static final TasbihDatabase instance = TasbihDatabase._();

  static const String _dbName = 'tasbih.db';
  static const int _dbVersion = 1;
  static const String _tableSessions = 'tasbih_sessions';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

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
    await db.execute('''
      CREATE TABLE $_tableSessions (
        tasbihId TEXT NOT NULL,
        dateIso TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 0,
        lastUpdated TEXT NOT NULL,
        PRIMARY KEY (tasbihId, dateIso)
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_tasbih_date
      ON $_tableSessions (dateIso)
    ''');
  }

  // ─────────────────────────────────────────────
  // CRUD
  // ─────────────────────────────────────────────

  Future<TasbihSession?> getSession(String tasbihId, String dateIso) async {
    final db = await database;
    final rows = await db.query(
      _tableSessions,
      where: 'tasbihId = ? AND dateIso = ?',
      whereArgs: [tasbihId, dateIso],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TasbihSession.fromMap(rows.first);
  }

  Future<List<TasbihSession>> getSessionsForDate(String dateIso) async {
    final db = await database;
    final rows = await db.query(
      _tableSessions,
      where: 'dateIso = ?',
      whereArgs: [dateIso],
    );
    return rows.map(TasbihSession.fromMap).toList();
  }

  Future<void> upsertSession(TasbihSession session) async {
    final db = await database;
    await db.insert(
      _tableSessions,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> resetSession(String tasbihId, String dateIso) async {
    final db = await database;
    await db.delete(
      _tableSessions,
      where: 'tasbihId = ? AND dateIso = ?',
      whereArgs: [tasbihId, dateIso],
    );
  }

  Future<void> resetAllForDate(String dateIso) async {
    final db = await database;
    await db.delete(
      _tableSessions,
      where: 'dateIso = ?',
      whereArgs: [dateIso],
    );
  }

  /// Total lifetime count for a tasbih.
  Future<int> getLifetimeCount(String tasbihId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT SUM(count) AS total FROM $_tableSessions WHERE tasbihId = ?',
      [tasbihId],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
