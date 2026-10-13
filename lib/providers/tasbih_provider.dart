import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/tasbih_models.dart';
import '../data/repositories/tasbih_repository.dart';

/// Provider for [TasbihRepository].
final tasbihRepositoryProvider = Provider<TasbihRepository>((ref) {
  return TasbihRepository();
});

/// Exposes the full list of built-in Tasbih definitions.
final tasbihListProvider = Provider<List<Tasbih>>((ref) {
  return ref.watch(tasbihRepositoryProvider).getAllTasbihs();
});

/// Family: a single Tasbih definition by id.
final tasbihByIdProvider = Provider.family<Tasbih?, String>((ref, id) {
  return ref.watch(tasbihRepositoryProvider).getTasbihById(id);
});

/// Notifier that owns the today-session state for one Tasbih.
///
/// Bumped on every increment/decrement so the UI rebuilds.
class TasbihSessionNotifier extends StateNotifier<int> {
  final TasbihRepository _repo;
  final String _tasbihId;

  TasbihSessionNotifier(this._repo, this._tasbihId) : super(0) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.getTodayCount(_tasbihId);
  }

  Future<void> increment() async {
    final session = await _repo.increment(_tasbihId);
    state = session.count;
  }

  Future<void> decrement() async {
    final session = await _repo.decrement(_tasbihId);
    state = session.count;
  }

  Future<void> reset() async {
    await _repo.resetToday(_tasbihId);
    state = 0;
  }
}

/// Family provider for a single Tasbih's today count.
final tasbihSessionProvider =
    StateNotifierProvider.family<TasbihSessionNotifier, int, String>(
  (ref, tasbihId) {
    final repo = ref.watch(tasbihRepositoryProvider);
    return TasbihSessionNotifier(repo, tasbihId);
  },
);

/// Lifetime count for a Tasbih, exposed as an async provider.
final tasbihLifetimeProvider =
    FutureProvider.family<int, String>((ref, tasbihId) async {
  // Reload whenever the today counter changes.
  ref.watch(tasbihSessionProvider(tasbihId));
  final repo = ref.watch(tasbihRepositoryProvider);
  return repo.getLifetimeCount(tasbihId);
});

/// Provider returning all today's sessions (for the summary list).
final tasbihAllTodayProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(tasbihRepositoryProvider);
  final ids = repo.getAllTasbihs().map((t) => t.id).toList();
  final map = <String, int>{};
  for (final id in ids) {
    map[id] = await repo.getTodayCount(id);
  }
  return map;
});
