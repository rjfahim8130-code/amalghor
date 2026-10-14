import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/quran_models.dart';
import '../../providers/mushaf_provider.dart';
import '../../providers/quran_provider.dart';
import 'widgets/ayah_card.dart';
import 'widgets/language_toggle.dart';

/// The Ayah reader screen for a single Surah.
///
/// Features:
///   - Sticky header with Surah name + actions
///   - Language toggle bar
///   - Ayah list (lazy, with auto-scroll to a target ayah)
///   - Progress saving (last read)
///   - Bookmarks shortcut
///   - Settings for font size / line height
class SurahReaderScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final int? initialAyah;

  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    this.initialAyah,
  });

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_saveProgressOnScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_saveProgressOnScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Save the last-read position roughly every scroll stop.
  void _saveProgressOnScroll() {
    if (!_scrollController.hasClients) return;
    // Throttle by using a simple heuristic: only save every N pixels.
    // Actual progress saving happens in `_onScrollStop`.
  }

  /// Called by the list's `NotificationListener` when scrolling stops.
  void _onScrollStop() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final viewport = _scrollController.position.viewportDimension;

    // Find the closest ayah key to the current scroll offset.
    int? closestAyah;
    double closestDistance = double.infinity;

    _ayahKeys.forEach((ayahNum, key) {
      final ctx = key.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) return;
      final pos = box.localToGlobal(Offset.zero);
      final distance = (pos.dy - 100).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestAyah = ayahNum;
      }
    });

    if (closestAyah != null) {
      ref
          .read(lastReadProvider.notifier)
          .update(widget.surahNumber, closestAyah!);
    }
    // Silence unused-variable lint.
    offset.hashCode;
    viewport.hashCode;
  }

  /// Scroll to the initial ayah once the list is built.
  void _scrollToInitialAyahOnce() {
    if (_initialScrollDone) return;
    final target = widget.initialAyah;
    if (target == null) return;
    final key = _ayahKeys[target];
    if (key == null) return;
    final ctx = key.currentContext;
    if (ctx == null) return;

    _initialScrollDone = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final surahAsync = ref.watch(surahMetaProvider(widget.surahNumber));

    return Scaffold(
      appBar: AppBar(
        title: surahAsync.when(
          loading: () => const Text('Loading...'),
          error: (_, __) => Text('Surah ${widget.surahNumber}'),
          data: (surah) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                surah?.nameEnglish ?? 'Surah ${widget.surahNumber}',
                style: const TextStyle(
                  fontSize: AppConstants.fontSubtitle,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (surah != null)
                Text(
                  '${surah.nameArabic} •${surah.totalAyahs} ayahs',
                  style: const TextStyle(
                    fontSize: AppConstants.fontMicro,
                    color: AppConstants.textMuted,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          // তেলাওয়াত পৃষ্ঠা (মুসহাফ) রিডাইরেক্ট বাটন
          IconButton(
            tooltip: 'তেলাওয়াত পৃষ্ঠা',
            icon: const Icon(Icons.menu_book_rounded, size: 22),
            onPressed: () async {
              final config = await ref.read(mushafConfigProvider.future);
              final page = config.approximatePageForSurah(widget.surahNumber);
              if (context.mounted) {
                context.push('/quran/mushaf?page=$page');
              }
            },
          ),
          IconButton(
            tooltip: 'Font size',
            icon: const Icon(Icons.format_size),
            onPressed: () => _showFontSettings(context),
          ),
          IconButton(
            tooltip: 'Bookmarks',
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => context.push('/quran/bookmarks'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sticky language toggle bar.
          const LanguageToggle(),

          // Ayah list.
          Expanded(
            child: surahAsync.when(
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
              data: (surah) {
                if (surah == null) {
                  return const Center(
                    child: Text(
                      'Surah not found',
                      style: TextStyle(color: AppConstants.textMuted),
                    ),
                  );
                }
                return _AyahList(
                  surah: surah,
                  scrollController: _scrollController,
                  ayahKeys: _ayahKeys,
                  initialAyah: widget.initialAyah,
                  onInitialScroll: _scrollToInitialAyahOnce,
                  onScrollStop: _onScrollStop,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FONT SETTINGS SHEET
  // ─────────────────────────────────────────────

  void _showFontSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppConstants.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      builder: (_) => const _FontSettingsSheet(),
    );
  }
}

// ─────────────────────────────────────────────
// AYAH LIST
// ─────────────────────────────────────────────
class _AyahList extends ConsumerStatefulWidget {
  final SurahMeta surah;
  final ScrollController scrollController;
  final Map<int, GlobalKey> ayahKeys;
  final int? initialAyah;
  final VoidCallback onInitialScroll;
  final VoidCallback onScrollStop;

  const _AyahList({
    required this.surah,
    required this.scrollController,
    required this.ayahKeys,
    required this.initialAyah,
    required this.onInitialScroll,
    required this.onScrollStop,
  });

  @override
  ConsumerState<_AyahList> createState() => _AyahListState();
}

class _AyahListState extends ConsumerState<_AyahList> {
  bool _hasHandledInitialScroll = false;

  @override
  Widget build(BuildContext context) {
    final ayahsAsync = ref.watch(ayahsProvider(widget.surah.number));

    return ayahsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppConstants.emeraldPrimary,
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceXl),
          child: Text(
            'Failed to load ayahs: $e',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppConstants.textMuted),
          ),
        ),
      ),
      data: (ayahs) {
        if (ayahs.isEmpty) {
          return const Center(
            child: Text(
              'No ayahs found for this Surah',
              style: TextStyle(color: AppConstants.textMuted),
            ),
          );
        }

        // Register a GlobalKey for every ayah once.
        for (final a in ayahs) {
          widget.ayahKeys.putIfAbsent(a.ayahNumber, () => GlobalKey());
        }

        // Trigger the initial scroll after the first build.
        if (!_hasHandledInitialScroll &&
            widget.initialAyah != null &&
            widget.initialAyah! > 0 &&
            widget.initialAyah! <= ayahs.length) {
          _hasHandledInitialScroll = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onInitialScroll();
          });
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              widget.onScrollStop();
            }
            return false;
          },
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spaceMd,
            ),
            itemCount: ayahs.length + 1, // +1 for Bismillah header
            itemBuilder: (context, i) {
              // First row: Bismillah header (except Surah 1 & 9).
              if (i == 0) {
                return _BismillahHeader(
                  surahNumber: widget.surah.number,
                  surahNameArabic: widget.surah.nameArabic,
                  surahNameEnglish: widget.surah.nameEnglish,
                  revelationPlace: widget.surah.revelationPlace,
                  totalAyahs: widget.surah.totalAyahs,
                );
              }

              final ayah = ayahs[i - 1];
              final key = widget.ayahKeys[ayah.ayahNumber] ??
                  GlobalKey();
              final isHighlighted = widget.initialAyah == ayah.ayahNumber;

              return Padding(
                key: key,
                padding: EdgeInsets.zero,
                child: AyahCard(
                  ayah: ayah,
                  surah: widget.surah,
                  isHighlighted: isHighlighted,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// BISMILLAH HEADER
// ─────────────────────────────────────────────
class _BismillahHeader extends StatelessWidget {
  final int surahNumber;
  final String surahNameArabic;
  final String surahNameEnglish;
  final String revelationPlace;
  final int totalAyahs;

  const _BismillahHeader({
    required this.surahNumber,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.revelationPlace,
    required this.totalAyahs,
  });

  @override
  Widget build(BuildContext context) {
    // Bismillah is not part of Surah 1 (it IS the first ayah) and is
    // not recited at the start of Surah 9.
    final showBismillah = surahNumber != 1 && surahNumber != 9;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.spaceMd,
        AppConstants.spaceSm,
        AppConstants.spaceMd,
        AppConstants.spaceLg,
      ),
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.surfaceDark,
            AppConstants.surfaceDarker,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppConstants.emeraldPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          // Surah name (Arabic)
          Text(
            surahNameArabic,
            style: const TextStyle(
              color: AppConstants.goldAccent,
              fontSize: 32,
              fontFamily: 'NotoNaskhArabic',
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceSm),

          // Surah name (English) + meta
          Text(
            surahNameEnglish,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontSubtitle,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${revelationPlace == 'makkah' ? 'Makki' : 'Madani'} • '
            '$totalAyahs ayahs',
            style: const TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontCaption,
            ),
            textAlign: TextAlign.center,
          ),

          // Bismillah
          if (showBismillah) ...[
            const SizedBox(height: AppConstants.spaceXl),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceLg,
                vertical: AppConstants.spaceMd,
              ),
              decoration: BoxDecoration(
                color: AppConstants.emeraldPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.20),
                ),
              ),
              child: const Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: 22,
                    fontFamily: 'NotoNaskhArabic',
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FONT SETTINGS SHEET
// ─────────────────────────────────────────────
class _FontSettingsSheet extends ConsumerWidget {
  const _FontSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(quranDisplayProvider);
    final notifier = ref.read(quranDisplayProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppConstants.textFaint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),

            // Title
            const Text(
              'Reading Settings',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: AppConstants.fontHeading,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),

            // Font size
            _SettingRow(
              label: 'Font Size',
              value: '${(display.fontScale * 100).toInt()}%',
              child: Slider(
                value: display.fontScale,
                min: 0.7,
                max: 2.0,
                divisions: 13,
                activeColor: AppConstants.emeraldPrimary,
                inactiveColor: AppConstants.surfaceDarker,
                onChanged: (v) => notifier.setFontScale(v),
              ),
            ),

            // Line height
            _SettingRow(
              label: 'Line Spacing',
              value: display.lineHeight.toStringAsFixed(1),
              child: Slider(
                value: display.lineHeight,
                min: 1.2,
                max: 2.5,
                divisions: 13,
                activeColor: AppConstants.emeraldPrimary,
                inactiveColor: AppConstants.surfaceDarker,
                onChanged: (v) => notifier.setLineHeight(v),
              ),
            ),

            const SizedBox(height: AppConstants.spaceLg),

            // Reset
            TextButton.icon(
              onPressed: () {
                notifier.setFontScale(1.0);
                notifier.setLineHeight(1.6);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset to default'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget child;

  const _SettingRow({
    required this.label,
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: AppConstants.fontBody,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppConstants.emeraldPrimary,
                fontSize: AppConstants.fontBody,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}
