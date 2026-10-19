import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/models/dua_models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/dua_provider.dart';

/// Full-screen dua detail view.
class DuaDetailScreen extends ConsumerWidget {
  final String duaId;

  const DuaDetailScreen({super.key, required this.duaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dua = ref.watch(duaByIdProvider(duaId));
    if (dua == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.quranSurahNotFound)),
      );
    }

    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(dua.titleFor(localeCode)),
        actions: [
          IconButton(
            tooltip: l10n.copy,
            icon: const Icon(Icons.copy),
            onPressed: () => _copy(context, dua, localeCode, l10n),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        children: [
          // ─── Arabic ──────────────────────────
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            decoration: BoxDecoration(
              color: AppConstants.surfaceDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppConstants.goldAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                dua.arabic,
                style: const TextStyle(
                  color: AppConstants.goldAccent,
                  fontSize: 24,
                  fontFamily: 'NotoNaskhArabic',
                  height: 1.8,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Transliteration ─────────────────
          _Section(
            title: l10n.quranAyahText,
            body: dua.transliteration,
            italic: true,
          ),

          // ─── Meaning ─────────────────────────
          _Section(
            title: l10n.quranAyahText,
            body: dua.meaningFor(localeCode),
          ),

          // ─── Reference ───────────────────────
          if (dua.reference != null)
            _Section(
              title: l10n.quranSurah,
              body: dua.reference!,
              muted: true,
            ),

          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Future<void> _copy(
    BuildContext context,
    Dua dua,
    String localeCode,
    AppLocalizations l10n,
  ) async {
    final text =
        '${dua.titleFor(localeCode)}\n\n${dua.arabic}\n\n'
        '${dua.transliteration}\n\n${dua.meaningFor(localeCode)}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.ayahCopied),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  final bool italic;
  final bool muted;

  const _Section({
    required this.title,
    required this.body,
    this.italic = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppConstants.emeraldPrimary,
              fontSize: AppConstants.fontMicro,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            body,
            style: TextStyle(
              color: muted
                  ? AppConstants.textFaint
                  : AppConstants.textPrimary,
              fontSize: AppConstants.fontBody,
              height: 1.6,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
