import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/quran_models.dart';
import '../../providers/quran_provider.dart';
import 'widgets/loading_overlay.dart';

/// The Quran module's main screen.
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
    final loadState = ref.watch(quranLoadProvider);

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
                  hintText: 'Search the Quran...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppConstants.textFaint),
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('Al-Quran'),
        actions: [
          IconButton(
            tooltip: 'তেলাওয়াত (মুসহাফ)',
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () => context.push('/quran/mushaf?page=2'),
          ),
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_searching) {
                  _searchController.clear();
                }
                _searching = !_searching;
              });
            },
          ),
          IconButton(
            tooltip: 'Bookmarks',
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => context.push('/quran/bookmarks'),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!loadState.isLoaded)
            const _LoadingPlaceholder()
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

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _SurahListView extends ConsumerWidget {
  const _SurahListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);
    final lastRead = ref.watch(lastReadProvider);

    final hasLastRead = lastRead != null;
    final extraCount = hasLastRead ? 2 : 1;

    return surahsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppConstants.emeraldPrimary,
        ),
      ),
      error: (e, _) => Center(
        child: Text(
          'Failed to load: $e',
          style: const TextStyle(color: AppConstants.textMuted),
        ),
      ),
      data: (surahs) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spaceMd,
          ),
          itemCount: surahs.length + extraCount,
          itemBuilder: (context, i) {
            if (hasLastRead && i == 0) {
              return _ContinueReadingCard(lastRead: lastRead);
            }

            if ((hasLastRead && i == 1) || (!hasLastRead && i == 0)) {
              return const _MushafBannerCard();
            }

            final index = i - extraCount;
            final surah = surahs[index];
            return _SurahTile(surah: surah);
          },
        );
      },
    );
  }
}

class _MushafBannerCard extends StatelessWidget {
  const _MushafBannerCard();

  @override
  Widget build(BuildContext context) {
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
          onTap: () => context.push('/quran/mushaf?page=2'),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.emeraldPrimary.withValues(alpha: 0.15),
                  AppConstants.emeraldPrimary.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppConstants.emeraldPrimary.withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: AppConstants.emeraldPrimary,
                  size: 26,
                ),
                SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'তেলাওয়াত (হাফেজী মুসহাফ)',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: AppConstants.fontSubtitle,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'পৃষ্ঠাভিত্তিক সরাসরি কুরআন মজিদ পড়ুন',
                        style: TextStyle(
                          color: AppConstants.textMuted,
                          fontSize: AppConstants.fontCaption,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppConstants.emeraldPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _ContinueReadingCard extends ConsumerWidget {
  final LastReadPosition lastRead;

  const _ContinueReadingCard({required this.lastRead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              gradient: LinearGradient(
                colors: [
                  AppConstants.emeraldPrimary.withValues(alpha: 0.18),
                  AppConstants.emeraldPrimary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppConstants.emeraldPrimary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppConstants.emeraldPrimary.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppConstants.emeraldPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Continue Reading',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: AppConstants.fontSubtitle,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${surah?.nameEnglish ?? 'Surah ${lastRead.surahNumber}'}'
                        ' — Ayah ${lastRead.ayahNumber}',
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
                  color: AppConstants.emeraldPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final SurahMeta surah;

  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context) {
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
                  color: AppConstants.surfaceDark,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(
                    color: AppConstants.emeraldPrimary.withValues(alpha: 0.35),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      color: AppConstants.emeraldPrimary,
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
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontSubtitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          surah.nameTransliteration,
                          style: const TextStyle(
                            color: AppConstants.textMuted,
                            fontSize: AppConstants.fontCaption,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceSm),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppConstants.textFaint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceSm),
                        Text(
                          surah.isMakki ? 'Makki' : 'Madani',
                          style: const TextStyle(
                            color: AppConstants.textFaint,
                            fontSize: AppConstants.fontMicro,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceSm),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppConstants.textFaint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceSm),
                        Text(
                          '${surah.totalAyahs} ayahs',
                          style: const TextStyle(
                            color: AppConstants.textFaint,
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
                style: const TextStyle(
                  color: AppConstants.goldAccent,
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
}

class _SearchResults extends ConsumerWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(quranSearchProvider(query));

    return resultsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppConstants.emeraldPrimary,
        ),
      ),
      error: (e, _) => Center(
        child: Text(
          'Search failed: $e',
          style: const TextStyle(color: AppConstants.textMuted),
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
                  const Icon(
                    Icons.search_off,
                    color: AppConstants.textFaint,
                    size: 48,
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Text(
                    'No results for "$query"',
                    style: const TextStyle(
                      color: AppConstants.textMuted,
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
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: AppConstants.spaceLg),
          itemBuilder: (context, i) => _SearchResultTile(result: results[i]),
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
                      color: AppConstants.emeraldPrimary
                          .withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Text(
                      '${result.surahNumber}:${result.ayahNumber}',
                      style: const TextStyle(
                        color: AppConstants.emeraldPrimary,
                        fontSize: AppConstants.fontMicro,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Expanded(
                    child: Text(
                      result.surahName,
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
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
                style: const TextStyle(
                  color: AppConstants.textMuted,
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
