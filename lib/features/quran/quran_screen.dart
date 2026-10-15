import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../data/models/quran_models.dart';
import '../../providers/quran_provider.dart';
import 'widgets/loading_overlay.dart';

/// The Quran module's main screen.
///
/// Shows:
///   - Loading overlay during first-time DB build
///   - Continue Reading card (if a last-read position exists)
///   - Search bar
///   - The complete list of 114 Surahs
class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranLoadProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final loadState = ref.watch(quranLoadProvider);

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
                  hintText: 'Search the Quran...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: colors.textFaint),
                ),
                onChanged: (_) => setState(() {}),
              )
            : Text(
                'আল-কুরআন',
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
                if (_searching) _searchController.clear();
                _searching = !_searching;
              });
            },
          ),
          IconButton(
            tooltip: 'Bookmarks',
            icon: Icon(Icons.bookmark_border, color: colors.textPrimary),
            onPressed: () => context.push('/quran/bookmarks'),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!loadState.isLoaded)
            const SizedBox.shrink()
          else if (_searching && _searchController.text.trim().isNotEmpty)
            _SearchResults(query: _searchController.text.trim())
          else
            const _SurahListView(),

          if (!loadState.isLoaded)
            LoadingOverlay(
              stage: loadState.stage,
              progress: loadState.progress,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN LIST
// ─────────────────────────────────────────────

class _SurahListView extends ConsumerWidget {
  const _SurahListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final surahsAsync = ref.watch(surahListProvider);
    final lastRead = ref.watch(lastReadProvider);

    return surahsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: colors.emerald),
      ),
      error: (e, _) => Center(
        child: Text(
          'Failed to load: $e',
          style: TextStyle(color: colors.textMuted),
        ),
      ),
      data: (surahs) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spaceMd,
          ),
          itemCount: surahs.length + (lastRead != null ? 1 : 0),
          itemBuilder: (context, i) {
            if (lastRead != null && i == 0) {
              return _ContinueReadingCard(lastRead: lastRead);
            }
            final index = lastRead != null ? i - 1 : i;
            return _SurahTile(surah: surahs[index]);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// CONTINUE READING CARD
// ─────────────────────────────────────────────

class _ContinueReadingCard extends ConsumerWidget {
  final LastReadPosition lastRead;

  const _ContinueReadingCard({required this.lastRead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final surahAsync = ref.watch(surahMetaProvider(lastRead.surahNumber));
    final surah = surahAsync.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceSm,
        AppConstants.spaceLg,
        AppConstants.spaceMd,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          onTap: () => context.push(
            '/quran/${lastRead.surahNumber}?ayah=${lastRead.ayahNumber}',
          ),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            decoration: BoxDecoration(
              gradient: colors.prayerCardGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(color: colors.border, width: 1.2),
              boxShadow: colors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.iconBackground,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: colors.iconBorder),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: colors.emerald,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue Reading',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: AppConstants.fontSubtitle,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${surah?.nameEnglish ?? 'Surah ${lastRead.surahNumber}'}'
                        ' — Ayah ${lastRead.ayahNumber}',
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
                  color: colors.emerald,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SURAH TILE
// ─────────────────────────────────────────────

class _SurahTile extends StatelessWidget {
  final SurahMeta surah;

  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/quran/${surah.number}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceMd,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: colors.iconBorder),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: TextStyle(
                      color: colors.emerald,
                      fontSize: AppConstants.fontBody,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.nameEnglish,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppConstants.fontSubtitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          surah.nameTransliteration,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: AppConstants.fontCaption,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceSm),
                        _dot(colors),
                        const SizedBox(width: AppConstants.spaceSm),
                        Text(
                          surah.isMakki ? 'Makki' : 'Madani',
                          style: TextStyle(
                            color: colors.textFaint,
                            fontSize: AppConstants.fontMicro,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceSm),
                        _dot(colors),
                        const SizedBox(width: AppConstants.spaceSm),
                        Text(
                          '${surah.totalAyahs} ayahs',
                          style: TextStyle(
                            color: colors.textFaint,
                            fontSize: AppConstants.fontMicro,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                surah.nameArabic,
                style: TextStyle(
                  color: colors.gold,
                  fontSize: 20,
                  fontFamily: 'NotoNaskhArabic',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(AppColors colors) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: colors.textFaint,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SEARCH RESULTS
// ─────────────────────────────────────────────

class _SearchResults extends ConsumerWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final resultsAsync = ref.watch(quranSearchProvider(query));

    return resultsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: colors.emerald),
      ),
      error: (e, _) => Center(
        child: Text(
          'Search failed: $e',
          style: TextStyle(color: colors.textMuted),
        ),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceXl),
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
                    'No results for "$query"',
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: AppConstants.fontBody,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spaceMd,
          ),
          itemCount: results.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: AppConstants.spaceLg,
            color: colors.divider,
          ),
          itemBuilder: (context, i) =>
              _SearchResultTile(result: results[i]),
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final QuranSearchResult result;

  const _SearchResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          '/quran/${result.surahNumber}?ayah=${result.ayahNumber}',
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceSm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.iconBackground,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                      border: Border.all(color: colors.iconBorder),
                    ),
                    child: Text(
                      '${result.surahNumber}:${result.ayahNumber}',
                      style: TextStyle(
                        color: colors.emerald,
                        fontSize: AppConstants.fontMicro,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Expanded(
                    child: Text(
                      result.surahName,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                result.snippet,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: AppConstants.fontBody,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
