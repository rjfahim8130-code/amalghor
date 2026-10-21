import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../data/models/mushaf_models.dart';
import '../../data/models/quran_models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/mushaf_provider.dart';
import '../../providers/quran_provider.dart';

/// Shows Arabic + Bangla + English for every ayah on one Hafezi page.
class MushafPageTranslationScreen extends ConsumerStatefulWidget {
  final int page;

  const MushafPageTranslationScreen({super.key, required this.page});

  @override
  ConsumerState<MushafPageTranslationScreen> createState() =>
      _MushafPageTranslationScreenState();
}

class _MushafPageTranslationScreenState
    extends ConsumerState<MushafPageTranslationScreen> {
  bool _showArabic = true;
  bool _showBangla = true;
  bool _showEnglish = true;

  List<Ayah>? _ayahs;
  String? _error;
  bool _loading = true;
  MushafPageInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(quranLoadProvider.notifier).load();
      final cfg = await ref.read(mushafConfigProvider.future);
      final info = cfg.pageInfo(widget.page);
      if (info == null) {
        setState(() {
          _loading = false;
          _error = 'page';
        });
        return;
      }

      final repo = ref.read(quranRepositoryProvider);
      final list = <Ayah>[];
      var surah = info.startSurah;
      var ayah = info.startAyah;

      while (true) {
        final a = await repo.getAyah(surah, ayah);
        if (a != null) list.add(a);

        if (surah == info.endSurah && ayah == info.endAyah) break;

        final meta = await repo.getSurah(surah);
        final maxA = meta?.totalAyahs ?? ayah;
        if (ayah >= maxA) {
          surah++;
          ayah = 1;
        } else {
          ayah++;
        }
        if (list.length > 40) break;
      }

      if (!mounted) return;
      setState(() {
        _info = info;
        _ayahs = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final para = _info?.para;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quranPageTranslation,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              para == null
                  ? '${l10n.quranPage} ${widget.page}'
                  : '${l10n.quranPara} $para · ${l10n.quranPage} ${widget.page}',
              style: TextStyle(color: colors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Language chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                _chip(l10n.quranShowArabic, _showArabic, (v) {
                  setState(() => _showArabic = v);
                }, colors),
                const SizedBox(width: 8),
                _chip(l10n.quranShowBangla, _showBangla, (v) {
                  setState(() => _showBangla = v);
                }, colors),
                const SizedBox(width: 8),
                _chip(l10n.quranShowEnglish, _showEnglish, (v) {
                  setState(() => _showEnglish = v);
                }, colors),
              ],
            ),
          ),
          Expanded(child: _body(colors, l10n)),
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    bool active,
    ValueChanged<bool> onChanged,
    AppColors colors,
  ) {
    return FilterChip(
      label: Text(label),
      selected: active,
      onSelected: onChanged,
      selectedColor: colors.emerald.withValues(alpha: 0.25),
      checkmarkColor: colors.emerald,
      labelStyle: TextStyle(
        color: active ? colors.emerald : colors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: active ? colors.emerald : colors.border,
      ),
      backgroundColor: colors.cardBackground,
    );
  }

  Widget _body(AppColors colors, AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error == 'page' ? l10n.pageNotFound : '${l10n.error}: $_error',
          style: TextStyle(color: colors.textMuted),
        ),
      );
    }
    final ayahs = _ayahs ?? [];
    if (ayahs.isEmpty) {
      return Center(
        child: Text(l10n.pageNotFound, style: TextStyle(color: colors.textMuted)),
      );
    }

    int? lastSurah;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: ayahs.length,
      itemBuilder: (context, i) {
        final a = ayahs[i];
        final showSurahHeader = lastSurah != a.surahNumber;
        lastSurah = a.surahNumber;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showSurahHeader)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Text(
                  '${l10n.quranSurah} ${a.surahNumber}',
                  style: TextStyle(
                    color: colors.emerald,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${a.ayahNumber}',
                        style: TextStyle(
                          color: colors.emerald,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  if (_showArabic) ...[
                    const SizedBox(height: 10),
                    Text(
                      a.textArabic,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 22,
                        height: 1.85,
                      ),
                    ),
                  ],
                  if (_showBangla && (a.textBangla?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 10),
                    Text(
                      a.textBangla!,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontFamily: 'NotoSansBengali',
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                  if (_showEnglish && (a.textEnglish?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 8),
                    Text(
                      a.textEnglish!,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
