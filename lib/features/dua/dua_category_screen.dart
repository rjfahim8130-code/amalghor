import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/dua_provider.dart';

/// Shows all duas in a single category.
class DuaCategoryScreen extends ConsumerWidget {
  final String categoryId;

  const DuaCategoryScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final category = ref.watch(duaCategoryByIdProvider(categoryId));
    final duas = ref.watch(duasByCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(category?.titleBn ?? l10n.dua),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceLg,
        ),
        itemCount: duas.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppConstants.spaceMd),
        itemBuilder: (_, i) {
          final d = duas[i];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              onTap: () => context.push('/dua/detail/${d.id}'),
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
                      d.titleBn,
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
                        d.arabic,
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
        },
      ),
    );
  }
}
