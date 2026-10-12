import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/quran_database.dart';
import '../data/models/quran_models.dart';
import '../data/repositories/quran_repository.dart';
import 'settings_provider.dart';

// ─────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────

/// Provider for [QuranRepository].
///
/// Depends on [sharedPreferencesProvider] (from settings_provider)
/// so that display mode, last-read position, etc. can be persisted.
final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return QuranRepository(
    db: QuranDatabase.instance,
    prefs: prefs,
  );
});

// ─────────────────────────────────────────────
// INIT / LOADING
// ─────────────────────────────────────────────

/// Progress state for the one-time asset → SQLite load.
class QuranLoadingState {
  final bool isLoaded;
  final String stage;
  final double progress;

  const QuranLoadingState({
    required this.isLoaded,
    required this.stage,
    required this.progress,
  });

  const QuranLoadingState.initial()
      : isLoaded = false,
        stage = 'Preparing...',
        progress = 0.0;

  QuranLoadingState copyWith({
    bool? isLoaded,
    String? stage,
    double? progress,
  }) {
    return QuranLoadingState(
      isLoaded: isLoaded ?? this.isLoaded,
      stage: stage ?? this.stage,
      progress: progress ?? this.progress,
    );
  }
}

/// Notifier that drives the Quran data load.
///
/// Call [load] once at app start (or the first time the Quran screen
/// opens). It is safe to call multiple times — subsequent calls
/// return quickly if data is already loaded.
class QuranLoadNotifier extends StateNotifier<QuranLoadingState> {
  final QuranRepository _repo;

  QuranLoadNotifier(this._repo) : super(const QuranLoadingState.initial());

  Future<void> load() async {
    // Fast path — already loaded.
    if (await _repo.isLoaded()) {
      state = state.copyWith(
        isLoaded: true,
        stage: 'Ready',
        progress: 1.0,
      );
      return;
    }

    try {
      await _repo.ensureLoaded(
        onProgress: (stage, progress) {
          if (!mounted) return;
          state = state.copyWith(
            stage: stage,
            progress: progress,
            isLoaded: progress >= 1.0,
          );
        },
      );
      state = state.copyWith(isLoaded: true, progress: 1.0);
    } catch (e) {
      state = state.copyWith(
        stage: 'Failed: $e',
        progress: 0.0,
      );
      rethrow;
    }
  }
}

/// Public provider for loading progress.
final quranLoadProvider =
    StateNotifierProvider<QuranLoadNotifier, QuranLoadingState>((ref) {
  final repo = ref.watch(quranRepositoryProvider);
  return QuranLoadNotifier(repo);
});

// ─────────────────────────────────────────────
// SURAH LIST
// ─────────────────────────────────────────────

/// FutureProvider returning the full list of 114 Surahs.
final surahListProvider = FutureProvider<List<SurahMeta>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  await ref.watch(quranLoadProvider.notifier).load();
  return repo.getAllSurahs();
});

// ─────────────────────────────────────────────
// SINGLE SURAH — METADATA
// ─────────────────────────────────────────────

/// Family provider: one Surah's metadata by number.
final surahMetaProvider =
    FutureProvider.family<SurahMeta?, int>((ref, number) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getSurah(number);
});

// ─────────────────────────────────────────────
// AYAHS OF A SURAH
// ─────────────────────────────────────────────

/// Family provider: all ayahs of a given Surah.
final ayahsProvider =
    FutureProvider.family<List<Ayah>, int>((ref, surahNumber) async {
  final repo = ref.watch(quranRepositoryProvider);
  await ref.watch(quranLoadProvider.notifier).load();
  return repo.getAyahsOfSurah(surahNumber);
});

// ─────────────────────────────────────────────
// DISPLAY MODE
// ─────────────────────────────────────────────

/// Notifier that owns the current [QuranDisplayMode] state.
class QuranDisplayNotifier extends StateNotifier<QuranDisplayMode> {
  final QuranRepository _repo;

  QuranDisplayNotifier(this._repo) : super(_repo.loadDisplayMode());

  Future<void> setArabic(bool v) async {
    state = state.copyWith(showArabic: v);
    await _repo.saveDisplayMode(state);
  }

  Future<void> setBangla(bool v) async {
    state = state.copyWith(showBangla: v);
    await _repo.saveDisplayMode(state);
  }

  Future<void> setEnglish(bool v) async {
    state = state.copyWith(showEnglish: v);
    await _repo.saveDisplayMode(state);
  }

  Future<void> applyPreset(QuranDisplayMode preset) async {
    state = preset.copyWith(
      fontScale: state.fontScale,
      lineHeight: state.lineHeight,
    );
    await _repo.saveDisplayMode(state);
  }

  Future<void> setFontScale(double scale) async {
    state = state.copyWith(fontScale: scale.clamp(0.7, 2.0));
    await _repo.saveDisplayMode(state);
  }

  Future<void> setLineHeight(double h) async {
    state = state.copyWith(lineHeight: h.clamp(1.2, 2.5));
    await _repo.saveDisplayMode(state);
  }

  Future<void> reset() async {
    state = QuranDisplayMode.arabicBangla;
    await _repo.saveDisplayMode(state);
  }
}

/// Public provider for the display mode.
final quranDisplayProvider =
    StateNotifierProvider<QuranDisplayNotifier, QuranDisplayMode>((ref) {
  final repo = ref.watch(quranRepositoryProvider);
  return QuranDisplayNotifier(repo);
});

// ─────────────────────────────────────────────
// BOOKMARKS
// ─────────────────────────────────────────────

/// Notifier that exposes bookmark operations and a reload trigger.
class QuranBookmarkNotifier extends StateNotifier<int> {
  final QuranRepository _repo;

  /// The state is just a counter — incremented whenever a bookmark
  /// changes, so downstream FutureProviders are invalidated.
  QuranBookmarkNotifier(this._repo) : super(0);

  Future<bool> toggle({
    required int surah,
    required int ayah,
    String? note,
  }) async {
    final added = await _repo.toggleBookmark(
      surah: surah,
      ayah: ayah,
      note: note,
    );
    state = state + 1;
    return added;
  }

  Future<void> remove(int id) async {
    await _repo.deleteBookmark(id);
    state = state + 1;
  }

  Future<void> clearAll() async {
    await _repo.clearAllBookmarks();
    state = state + 1;
  }
}

final quranBookmarkNotifierProvider =
    StateNotifierProvider<QuranBookmarkNotifier, int>((ref) {
  final repo = ref.watch(quranRepositoryProvider);
  return QuranBookmarkNotifier(repo);
});

/// List of all bookmarks (auto-refreshes when the notifier bumps).
final allBookmarksProvider =
    FutureProvider<List<QuranBookmark>>((ref) async {
  ref.watch(quranBookmarkNotifierProvider); // reload trigger
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getAllBookmarks();
});

/// Bookmarks for one Surah.
final bookmarksForSurahProvider =
    FutureProvider.family<List<QuranBookmark>, int>((ref, surah) async {
  ref.watch(quranBookmarkNotifierProvider); // reload trigger
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getBookmarksForSurah(surah);
});

/// Whether a specific (surah, ayah) is bookmarked.
final isBookmarkedProvider =
    FutureProvider.family<bool, ({int surah, int ayah})>((ref, args) async {
  ref.watch(quranBookmarkNotifierProvider); // reload trigger
  final repo = ref.watch(quranRepositoryProvider);
  return repo.isBookmarked(args.surah, args.ayah);
});

// ─────────────────────────────────────────────
// SEARCH
// ─────────────────────────────────────────────

/// Family provider for full-text search.
///
/// An empty query returns an empty list immediately.
final quranSearchProvider =
    FutureProvider.family<List<QuranSearchResult>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];
  final repo = ref.watch(quranRepositoryProvider);
  return repo.search(query);
});

// ─────────────────────────────────────────────
// LAST READ
// ─────────────────────────────────────────────

/// Notifier that owns the last-read position.
class LastReadNotifier extends StateNotifier<LastReadPosition?> {
  final QuranRepository _repo;

  LastReadNotifier(this._repo) : super(_repo.loadLastRead());

  Future<void> update(int surah, int ayah) async {
    await _repo.saveLastRead(surah, ayah);
    state = LastReadPosition(
      surahNumber: surah,
      ayahNumber: ayah,
      readAt: DateTime.now(),
    );
  }

  Future<void> clear() async {
    await _repo.clearLastRead();
    state = null;
  }
}

final lastReadProvider =
    StateNotifierProvider<LastReadNotifier, LastReadPosition?>((ref) {
  final repo = ref.watch(quranRepositoryProvider);
  return LastReadNotifier(repo);
});
