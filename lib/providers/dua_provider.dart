import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/dua_data.dart';
import '../data/models/dua_models.dart';

/// All dua categories.
final duaCategoriesProvider = Provider<List<DuaCategory>>((ref) {
  return DuaData.categories;
});

/// All duas in the catalogue.
final duaAllProvider = Provider<List<Dua>>((ref) {
  return DuaData.all;
});

/// Family: category by id.
final duaCategoryByIdProvider =
    Provider.family<DuaCategory?, String>((ref, id) {
  for (final c in DuaData.categories) {
    if (c.id == id) return c;
  }
  return null;
});

/// Family: duas belonging to a given category.
final duasByCategoryProvider =
    Provider.family<List<Dua>, String>((ref, categoryId) {
  return DuaData.all.where((d) => d.categoryId == categoryId).toList();
});

/// Family: a single dua by id.
final duaByIdProvider = Provider.family<Dua?, String>((ref, id) {
  for (final d in DuaData.all) {
    if (d.id == id) return d;
  }
  return null;
});

/// Notifier that owns the search query for duas.
class DuaSearchNotifier extends StateNotifier<String> {
  DuaSearchNotifier() : super('');

  void update(String q) => state = q;
  void clear() => state = '';
}

final duaSearchProvider =
    StateNotifierProvider<DuaSearchNotifier, String>((ref) {
  return DuaSearchNotifier();
});

/// Filtered list based on the search query.
final duaFilteredProvider = Provider<List<Dua>>((ref) {
  final q = ref.watch(duaSearchProvider).trim().toLowerCase();
  if (q.isEmpty) return DuaData.all;

  return DuaData.all.where((d) {
    return d.titleEn.toLowerCase().contains(q) ||
        d.titleBn.contains(q) ||
        d.transliteration.toLowerCase().contains(q) ||
        d.meaningEn.toLowerCase().contains(q) ||
        d.meaningBn.contains(q);
  }).toList();
});
