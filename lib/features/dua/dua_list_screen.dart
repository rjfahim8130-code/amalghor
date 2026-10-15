import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
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
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: AppConstants.fontBody,
                ),
                decoration: InputDecoration(
                  hintText: 'দুআ খুঁজুন...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: colors.textFaint),
                ),
                onChanged: (v) =>
                    ref.read(duaSearchProvider.notifier).update(v),
              )
            : Text(
                'দুআ সংকলন',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _searching ? Icons.close : Icons.search,
              color: colors.textPrimary,
            ),
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
      body: _searching ? const _SearchResults() : const _CategoryList(),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList();

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
    final colors = AppColors.of(context);
    final count = ref.watch(duasByCategoryProvider(category.id)).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        onTap: () => context.push('/dua/category/${category.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(color: colors.border, width: 1.0),
            boxShadow: colors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: colors.iconBorder),
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
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppConstants.fontSubtitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count দুআ',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: AppConstants.fontCaption,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final results = ref.watch(duaFilteredProvider);
    final query = ref.watch(duaSearchProvider);

    if (query.trim().isEmpty) {
      return Center(
        child: Text(
          'টাইপ করে দুআ খুঁজুন',
          style: TextStyle(color: colors.textMuted),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              color: colors.textFaint,
              size: 48,
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Text(
              '"$query" এর জন্য কোনো দুআ নেই',
              style: TextStyle(color: colors.textMuted),
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

class _DuaCard extends StatelessWidget {
  final Dua dua;

  const _DuaCard({required this.dua});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        onTap: () => context.push('/dua/detail/${dua.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(color: colors.border, width: 1.0),
            boxShadow: colors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dua.titleBn,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: AppConstants.fontBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  dua.arabic,
                  style: TextStyle(
                    color: colors.gold,
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
