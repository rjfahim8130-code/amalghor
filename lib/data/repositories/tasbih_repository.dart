import '../database/tasbih_database.dart';
import '../models/tasbih_models.dart';

/// Repository for the Tasbih counter.
class TasbihRepository {
  final TasbihDatabase _db;

  TasbihRepository({TasbihDatabase? db})
      : _db = db ?? TasbihDatabase.instance;

  // ─────────────────────────────────────────────
  // CATALOGUE
  // ─────────────────────────────────────────────

  List<Tasbih> getAllTasbihs() => DefaultTasbihs.all;

  Tasbih? getTasbihById(String id) {
    for (final t in DefaultTasbihs.all) {
      if (t.id == id) return t;
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // SESSIONS
  // ─────────────────────────────────────────────

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<TasbihSession> getTodaySession(String tasbihId) async {
    final key = _dateKey(DateTime.now());
    final existing = await _db.getSession(tasbihId, key);
    if (existing != null) return existing;

    return TasbihSession(
      tasbihId: tasbihId,
      dateIso: key,
      count: 0,
      lastUpdated: DateTime.now(),
    );
  }

  Future<int> getTodayCount(String tasbihId) async {
    final session = await getTodaySession(tasbihId);
    return session.count;
  }

  Future<TasbihSession> increment(String tasbihId) async {
    final current = await getTodaySession(tasbihId);
    final updated = current.copyWith(
      count: current.count + 1,
      lastUpdated: DateTime.now(),
    );
    await _db.upsertSession(updated);
    return updated;
  }

  Future<TasbihSession> decrement(String tasbihId) async {
    final current = await getTodaySession(tasbihId);
    final nextCount = current.count > 0 ? current.count - 1 : 0;
    final updated = current.copyWith(
      count: nextCount,
      lastUpdated: DateTime.now(),
    );
    await _db.upsertSession(updated);
    return updated;
  }

  Future<void> resetToday(String tasbihId) async {
    final key = _dateKey(DateTime.now());
    await _db.resetSession(tasbihId, key);
  }

  Future<void> resetAllToday() async {
    final key = _dateKey(DateTime.now());
    await _db.resetAllForDate(key);
  }

  Future<int> getLifetimeCount(String tasbihId) =>
      _db.getLifetimeCount(tasbihId);
}
