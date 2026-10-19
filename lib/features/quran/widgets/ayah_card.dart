import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../data/models/quran_models.dart';
import '../../../providers/mushaf_provider.dart';
import '../../../providers/quran_provider.dart';

/// A single Ayah card in the reader.
///
/// Shows:
///   - Ayah number badge
///   - Arabic text (right-aligned, RTL)
///   - Bangla text (below Arabic if enabled)
///   - English text (below Bangla if enabled)
///   - Mushaf page navigate button
///   - Bookmark toggle
///   - Copy action
///
/// The card adapts to the current [QuranDisplayMode] — only the
/// enabled language layers are rendered.
class AyahCard extends ConsumerStatefulWidget {
  final Ayah ayah;
  final SurahMeta surah;
  final bool isHighlighted;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.surah,
    this.isHighlighted = false,
  });

  @override
  ConsumerState<AyahCard> createState() => _AyahCardState();
}

class _AyahCardState extends ConsumerState<AyahCard> {
  @override
  Widget build(BuildContext context) {
    final display = ref.watch(quranDisplayProvider);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: widget.isHighlighted
            ? AppConstants.emeraldPrimary.withValues(alpha: 0.08)
            : AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: widget.isHighlighted
              ? AppConstants.emeraldPrimary.withValues(alpha: 0.4)
              : AppConstants.dividerColor,
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header: Ayah number + Mushaf btn + bookmark ────
          _Header(
            surahNumber: widget.ayah.surahNumber,
            ayahNumber: widget.ayah.ayahNumber,
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // ─── Arabic text (RTL) ────────────────
          if (display.showArabic && widget.ayah.textArabic.isNotEmpty)
            _ArabicText(
              text: widget.ayah.textArabic,
              fontScale: display.fontScale,
              lineHeight: display.lineHeight,
            ),

          // ─── Bangla text ──────────────────────
          if (display.showBangla &&
              (widget.ayah.textBangla?.isNotEmpty ?? false))
            Padding(
              padding: EdgeInsets.only(
                top: display.showArabic ? AppConstants.spaceLg : 0,
              ),
              child: _TranslatedText(
                text: widget.ayah.textBangla!,
                fontFamily: 'Kalpurush',
                textAlign: TextAlign.left,
                color: AppConstants.textPrimary,
                fontScale: display.fontScale,
                lineHeight: display.lineHeight,
              ),
            ),

          // ─── English text ─────────────────────
          if (display.showEnglish &&
              (widget.ayah.textEnglish?.isNotEmpty ?? false))
            Padding(
              padding: EdgeInsets.only(
                top: (display.showArabic || display.showBangla)
                    ? AppConstants.spaceMd
                    : 0,
              ),
              child: _TranslatedText(
                text: widget.ayah.textEnglish!,
                fontFamily: 'Inter',
                textAlign: TextAlign.left,
                color: AppConstants.textMuted,
                fontScale: display.fontScale * 0.95,
                lineHeight: display.lineHeight,
                italic: true,
              ),
            ),

          const SizedBox(height: AppConstants.spaceSm),

          // ─── Footer: Copy ─────────────────────
          _Footer(ayah: widget.ayah, surah: widget.surah),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER — Ayah number + Mushaf btn + Bookmark
// ─────────────────────────────────────────────
class _Header extends ConsumerWidget {
  final int surahNumber;
  final int ayahNumber;

  const _Header({
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedAsync = ref.watch(
      isBookmarkedProvider((surah: surahNumber, ayah: ayahNumber)),
    );
    final isBookmarked = bookmarkedAsync.value ?? false;

    return Row(
      children: [
        // Ayah number badge
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppConstants.emeraldPrimary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppConstants.emeraldPrimary.withValues(alpha: 0.4),
            ),
          ),
          child: Center(
            child: Text(
              '$ayahNumber',
              style: const TextStyle(
                color: AppConstants.emeraldPrimary,
                fontSize: AppConstants.fontCaption,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Text(
          '$surahNumber:$ayahNumber',
          style: const TextStyle(
            color: AppConstants.textFaint,
            fontSize: AppConstants.fontMicro,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),

        // হাফিজী পৃষ্ঠায় যাও
        IconButton(
          tooltip: 'তেলাওয়াত পৃষ্ঠা',
          onPressed: () async {
            try {
              final config = await ref.read(mushafConfigProvider.future);
              final page = config.pageForAyah(surahNumber, ayahNumber);
              if (!context.mounted) return;
              if (page == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'এই আয়াত এখনো হাফিজী পারায় নেই (শুধু পারা ২৬–৩০)',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              context.push('/quran/mushaf?page=$page');
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('খোলা যায়নি: $e')),
              );
            }
          },
          icon: const Icon(
            Icons.menu_book_rounded,
            color: AppConstants.emeraldPrimary,
            size: 22,
          ),
        ),

        // Bookmark toggle
        IconButton(
          onPressed: () async {
            final added = await ref
                .read(quranBookmarkNotifierProvider.notifier)
                .toggle(surah: surahNumber, ayah: ayahNumber);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  added ? 'Bookmarked' : 'Bookmark removed',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked
                ? AppConstants.goldAccent
                : AppConstants.textMuted,
            size: 22,
          ),
          tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ARABIC TEXT (RTL)
// ─────────────────────────────────────────────
class _ArabicText extends StatelessWidget {
  final String text;
  final double fontScale;
  final double lineHeight;

  const _ArabicText({
    required this.text,
    required this.fontScale,
    required this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          color: AppConstants.textPrimary,
          fontSize: 24 * fontScale,
          height: lineHeight,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TRANSLATED TEXT
// ─────────────────────────────────────────────
class _TranslatedText extends StatelessWidget {
  final String text;
  final String fontFamily;
  final TextAlign textAlign;
  final Color color;
  final double fontScale;
  final double lineHeight;
  final bool italic;

  const _TranslatedText({
    required this.text,
    required this.fontFamily,
    required this.textAlign,
    required this.color,
    required this.fontScale,
    required this.lineHeight,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: fontFamily,
        color: color,
        fontSize: 16 * fontScale,
        height: lineHeight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      ),
      textAlign: textAlign,
    );
  }
}

// ─────────────────────────────────────────────
// FOOTER — Copy
// ─────────────────────────────────────────────
class _Footer extends ConsumerWidget {
  final Ayah ayah;
  final SurahMeta surah;

  const _Footer({
    required this.ayah,
    required this.surah,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => _copyToClipboard(context),
          icon: const Icon(Icons.copy, size: 14),
          label: const Text(
            'Copy',
            style: TextStyle(fontSize: AppConstants.fontMicro),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppConstants.textFaint,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceSm,
              vertical: 4,
            ),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final buffer = StringBuffer();
    buffer.writeln('${surah.nameEnglish} — ${surah.nameArabic}');
    buffer.writeln('Ayah ${ayah.ayahNumber}');
    buffer.writeln();
    buffer.writeln(ayah.textArabic);
    if (ayah.textBangla != null && ayah.textBangla!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(ayah.textBangla);
    }
    if (ayah.textEnglish != null && ayah.textEnglish!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(ayah.textEnglish);
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ayah copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
