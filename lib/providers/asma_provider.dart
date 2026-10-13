import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/asma_data.dart';
import '../data/models/asma_models.dart';

/// Exposes the full list of 99 Names.
final asmaListProvider = Provider<List<AsmaName>>((ref) {
  return AsmaData.all;
});

/// Family: a single Name by its number (1..99).
final asmaByNameProvider = Provider.family<AsmaName?, int>((ref, number) {
  for (final n in AsmaData.all) {
    if (n.number == number) return n;
  }
  return null;
});

/// Notifier that owns the search query for the Asma screen.
class AsmaSearchNotifier extends StateNotifier<String> {
  AsmaSearchNotifier() : super('');

  void update(String query) => state = query;
  void clear() => state = '';
}

final asmaSearchProvider =
    StateNotifierProvider<AsmaSearchNotifier, String>((ref) {
  return AsmaSearchNotifier();
});

/// Derived provider: filtered list based on the current search query.
final asmaFilteredProvider = Provider<List<AsmaName>>((ref) {
  final query = ref.watch(asmaSearchProvider).trim().toLowerCase();
  final all = ref.watch(asmaListProvider);
  if (query.isEmpty) return all;

  return all.where((n) {
    return n.transliteration.toLowerCase().contains(query) ||
        n.englishMeaning.toLowerCase().contains(query) ||
        n.banglaMeaning.contains(query) ||
        n.number.toString() == query;
  }).toList();
});
