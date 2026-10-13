import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/dua_models.dart';
import '../../providers/dua_provider.dart';

/// Screen listing all duas, organized by category.
class DuaListScreen extends ConsumerStatefulWidget {
  const DuaListScreen({super.key});

  @override
  ConsumerState<DuaListScreen> createState() => _DuaListScreenState();
}

class _DuaListScreenState extends ConsumerState<DuaListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: AppConstants.fontBody,
                ),
                decoration: const InputDecoration(
                  hintText: 'দুআ খুঁজুন...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppConstants.textFaint),
                ),
                onChanged: (v) =>
                    ref.read(duaSearchProvider.notifier).update(v),
              )
            : const Text('দুআ সংকলন'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_searching) {
                  _searchController.clear();
                  ref.read(duaSearchProvider.notifier).clear();
                }
                _searching = !_searching;
              });
            },
          ),
        ],
      ),
      body: _searching
          ? _SearchResults()
          : _CategoryList(),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY LIST
// ─────────────────────────────────────────────

class _CategoryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(duaCategoriesProvider);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceLg,
      ),
      itemCount: categories.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppConstants.spaceMd),
      itemBuilder: (_, i) => _CategoryTile(category: categories[i]),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  final DuaCategory category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(duasByCategoryProvider(category.id)).length;
    final color = Color(category.colorValue);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        onTap: () => context.push('/dua/category/${category.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: AppConstants.surfaceDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(color: AppConstants.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Center(
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.titleBn,
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontSubtitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count দুআ',
                      style: const TextStyle(
                        color: AppConstants.textMuted,
                        fontSize: AppConstants.fontCaption,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppConstants.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SEARCH RESULTS
// ─────────────────────────────────────────────

class _SearchResults extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(duaFilteredProvider);
    final query = ref.watch(duaSearchProvider);

    if (query.trim().isEmpty) {
      return const Center(
        child: Text(
          'টাইপ করে দুআ খুঁজুন',
          style: TextStyle(color: AppConstants.textMuted),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              color: AppConstants.textFaint,
              size: 48,
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Text(
              '"$query" এর জন্য কোনো দুআ নেই',
              style: const TextStyle(color: AppConstants.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceLg,
      ),
      itemCount: results.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppConstants.spaceMd),
      itemBuilder: (_, i) => _DuaCard(dua: results[i]),
    );
  }
}

// ─────────────────────────────────────────────
// DUA CARD
// ─────────────────────────────────────────────

class _DuaCard extends StatelessWidget {
  final Dua dua;

  const _DuaCard({required this.dua});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        onTap: () => context.push('/dua/detail/${dua.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: AppConstants.surfaceDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: AppConstants.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dua.titleBn,
                style: const TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: AppConstants.fontBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  dua.arabic,
                  style: const TextStyle(
                    color: AppConstants.goldAccent,
                    fontSize: 20,
                    fontFamily: 'NotoNaskhArabic',
                    height: 1.6,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
