import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/quran_models.dart';
import '../../providers/quran_provider.dart';

/// A full-screen view of all saved bookmarks.
///
/// Features:
///   - Groups bookmarks by Surah
///   - Tap a bookmark to open the reader at that Ayah
///   - Swipe to delete
///   - Empty state with a friendly message
class BookmarkScreen extends ConsumerWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(allBookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          bookmarksAsync.maybeWhen(
            data: (list) => list.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear all',
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () => _confirmClearAll(context, ref, list.length),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppConstants.emeraldPrimary,
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppConstants.textMuted),
          ),
        ),
        data: (bookmarks) {
          if (bookmarks.isEmpty) return const _EmptyState();
          return _BookmarkList(bookmarks: bookmarks);
        },
      ),
    );
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    WidgetRef ref,
    int count,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceDark,
        title: const Text(
          'Clear all bookmarks?',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: Text(
          'This will remove $count bookmark${count == 1 ? '' : 's'}. '
          'This action cannot be undone.',
          style: const TextStyle(color: AppConstants.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(quranBookmarkNotifierProvider.notifier).clearAll();
    }
  }
}

// ─────────────────────────────────────────────
// LIST
// ─────────────────────────────────────────────
class _BookmarkList extends ConsumerWidget {
  final List<QuranBookmark> bookmarks;

  const _BookmarkList({required this.bookmarks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group by surah for a cleaner UI.
    final grouped = <int, List<QuranBookmark>>{};
    for (final b in bookmarks) {
      grouped.putIfAbsent(b.surahNumber, () => []).add(b);
    }
    final surahNumbers = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spaceMd,
      ),
      itemCount: surahNumbers.length,
      itemBuilder: (context, i) {
        final surahNum = surahNumbers[i];
        final surahBookmarks = grouped[surahNum]!;
        surahBookmarks.sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));

        return _SurahGroup(
          surahNumber: surahNum,
          bookmarks: surahBookmarks,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// SURAH GROUP
// ─────────────────────────────────────────────
class _SurahGroup extends ConsumerWidget {
  final int surahNumber;
  final List<QuranBookmark> bookmarks;

  const _SurahGroup({
    required this.surahNumber,
    required this.bookmarks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahMetaProvider(surahNumber));
    final surah = surahAsync.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Surah header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceLg,
            AppConstants.spaceLg,
            AppConstants.spaceLg,
            AppConstants.spaceSm,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Center(
                  child: Text(
                    '$surahNumber',
                    style: const TextStyle(
                      color: AppConstants.emeraldPrimary,
                      fontSize: AppConstants.fontCaption,
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
                      surah?.nameEnglish ?? 'Surah $surahNumber',
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontSubtitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (surah != null)
                      Text(
                        surah.nameArabic,
                        style: const TextStyle(
                          color: AppConstants.goldAccent,
                          fontSize: AppConstants.fontSubtitle,
                          fontFamily: 'NotoNaskhArabic',
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${bookmarks.length}',
                style: const TextStyle(
                  color: AppConstants.textFaint,
                  fontSize: AppConstants.fontCaption,
                ),
              ),
            ],
          ),
        ),

        // Bookmark tiles
        ...bookmarks.map(
          (b) => _BookmarkTile(bookmark: b, surah: surah),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// BOOKMARK TILE
// ─────────────────────────────────────────────
class _BookmarkTile extends ConsumerWidget {
  final QuranBookmark bookmark;
  final SurahMeta? surah;

  const _BookmarkTile({
    required this.bookmark,
    required this.surah,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('bookmark-${bookmark.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spaceXl),
        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
        child: const Icon(
          Icons.delete_outline,
          color: Color(0xFFEF4444),
        ),
      ),
      onDismissed: (_) {
        if (bookmark.id != null) {
          ref
              .read(quranBookmarkNotifierProvider.notifier)
              .remove(bookmark.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bookmark removed'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openAyah(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceXl,
              vertical: AppConstants.spaceMd,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bookmark,
                  color: AppConstants.goldAccent,
                  size: 18,
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayah ${bookmark.ayahNumber}',
                        style: const TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: AppConstants.fontBody,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(bookmark.createdAt),
                        style: const TextStyle(
                          color: AppConstants.textFaint,
                          fontSize: AppConstants.fontMicro,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppConstants.textFaint,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAyah(BuildContext context) {
    // Route to the reader at this Ayah.
    context.push(
      '/quran/${bookmark.surahNumber}?ayah=${bookmark.ayahNumber}',
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppConstants.emeraldPrimary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border,
                color: AppConstants.emeraldPrimary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            const Text(
              'No bookmarks yet',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: AppConstants.fontSubtitle,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            const Text(
              'Tap the bookmark icon on any Ayah to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppConstants.textMuted,
                fontSize: AppConstants.fontBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
