import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/mushaf_models.dart';
import '../../../data/models/quran_models.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/quran_provider.dart';

/// Structured search: Para | Page + Surah | Ayah + Ayah text
class MushafSearchSheet extends ConsumerStatefulWidget {
  final MushafConfig config;
  final void Function(int page) onGoToPage;

  const MushafSearchSheet({
    super.key,
    required this.config,
    required this.onGoToPage,
  });

  @override
  ConsumerState<MushafSearchSheet> createState() => _MushafSearchSheetState();
}

class _MushafSearchSheetState extends ConsumerState<MushafSearchSheet> {
  final _paraCtrl = TextEditingController();
  final _pageCtrl = TextEditingController();
  final _surahCtrl = TextEditingController();
  final _ayahCtrl = TextEditingController();
  final _textCtrl = TextEditingController();

  String? _error;
  bool _searchingText = false;
  List<MapEntry<String, int>> _suggestions = [];
  List<_TextHit> _textHits = [];

  /// Search alias map (hardcoded — intentionally NOT localized).
  static const _surahNames = <String, int>{
    'আহকাফ': 46, 'ahqaf': 46, 'al-ahqaf': 46,
    'মুহাম্মদ': 47, 'muhammad': 47,
    'ফাতহ': 48, 'fath': 48, 'al-fath': 48, 'ফতহ': 48,
    'হুজুরাত': 49, 'hujurat': 49, 'al-hujurat': 49, 'হুজরাত': 49,
    'কাফ': 50, 'qaf': 50,
    'ধারিয়াত': 51, 'dhariyat': 51, 'জারিয়াত': 51,
    'তূর': 52, 'tur': 52, 'at-tur': 52,
    'নাজম': 53, 'najm': 53, 'an-najm': 53,
    'ক্বামার': 54, 'qamar': 54, 'al-qamar': 54, 'কামার': 54,
    'রাহমান': 55, 'rahman': 55, 'ar-rahman': 55,
    'ওয়াকিয়া': 56, 'waqiah': 56, 'al-waqiah': 56, 'ওয়াকিআহ': 56,
    'হাদীদ': 57, 'hadid': 57, 'al-hadid': 57, 'হাদিদ': 57,
    'মুজাদালা': 58, 'mujadila': 58, 'al-mujadila': 58, 'মুজাদিলা': 58,
    'হাশর': 59, 'hashr': 59, 'al-hashr': 59,
    'মুমতাহিনা': 60, 'mumtahanah': 60, 'al-mumtahanah': 60,
    'সফ': 61, 'saff': 61, 'as-saff': 61,
    'জুমুআ': 62, 'jumuah': 62, 'al-jumuah': 62, 'জুমআ': 62,
    'মুনাফিকুন': 63, 'munafiqun': 63,
    'তাগাবুন': 64, 'taghabun': 64, 'at-taghabun': 64,
    'তালাক': 65, 'talaq': 65, 'at-talaq': 65,
    'তাহরীম': 66, 'tahrim': 66, 'at-tahrim': 66, 'তাহরিম': 66,
    'মুলক': 67, 'mulk': 67, 'al-mulk': 67,
    'কলম': 68, 'qalam': 68, 'al-qalam': 68,
    'হাক্কাহ': 69, 'haqqah': 69, 'al-haqqah': 69,
    'মাআরিজ': 70, 'maarij': 70, 'al-maarij': 70,
    'নূহ': 71, 'nuh': 71,
    'জিন': 72, 'jinn': 72, 'al-jinn': 72,
    'মুজাম্মিল': 73, 'muzzammil': 73, 'al-muzzammil': 73,
    'মুদ্দাস্সির': 74, 'muddaththir': 74, 'al-muddaththir': 74,
    'কিয়ামাহ': 75, 'qiyamah': 75, 'al-qiyamah': 75,
    'ইনসান': 76, 'insan': 76, 'al-insan': 76, 'দাহর': 76,
    'মুরসালাত': 77, 'mursalat': 77, 'al-mursalat': 77,
    'নাবা': 78, 'naba': 78, 'an-naba': 78,
    'নাযিআত': 79, 'naziat': 79, 'an-naziat': 79,
    'আবাসা': 80, 'abasa': 80,
    'তাকভীর': 81, 'takwir': 81, 'at-takwir': 81,
    'ইনফিতার': 82, 'infitar': 82, 'al-infitar': 82,
    'মুতাফফিফীন': 83, 'mutaffifin': 83,
    'ইনশিকাক': 84, 'inshiqaq': 84, 'al-inshiqaq': 84,
    'বুরূজ': 85, 'buruj': 85, 'al-buruj': 85,
    'তারিক': 86, 'tariq': 86, 'at-tariq': 86,
    'আলা': 87, 'ala': 87, 'al-ala': 87,
    'গাশিয়াহ': 88, 'ghashiyah': 88, 'al-ghashiyah': 88,
    'ফজর': 89, 'fajr': 89, 'al-fajr': 89,
    'বালাদ': 90, 'balad': 90, 'al-balad': 90,
    'শামস': 91, 'shams': 91, 'ash-shams': 91,
    'লাইল': 92, 'layl': 92, 'al-layl': 92,
    'দুহা': 93, 'duha': 93, 'ad-duha': 93,
    'ইনশিরাহ': 94, 'inshirah': 94, 'ash-sharh': 94, 'শারহ': 94,
    'তীন': 95, 'tin': 95, 'at-tin': 95,
    'আলাক': 96, 'alaq': 96, 'al-alaq': 96,
    'কদর': 97, 'qadr': 97, 'al-qadr': 97,
    'বাইয়িনাহ': 98, 'bayyinah': 98, 'al-bayyinah': 98,
    'যিলযাল': 99, 'zilzal': 99, 'az-zalzalah': 99,
    'আদিয়াত': 100, 'adiyat': 100, 'al-adiyat': 100,
    'ক্বারিআহ': 101, 'qariah': 101, 'al-qariah': 101,
    'তাকাসুর': 102, 'takathur': 102, 'at-takathur': 102,
    'আসর': 103, 'asr': 103, 'al-asr': 103,
    'হুমাযাহ': 104, 'humazah': 104, 'al-humazah': 104,
    'ফীল': 105, 'fil': 105, 'al-fil': 105,
    'কুরাইশ': 106, 'quraysh': 106,
    'মাউন': 107, 'maun': 107, 'al-maun': 107,
    'কাওসার': 108, 'kawthar': 108, 'al-kawthar': 108,
    'কাফিরুন': 109, 'kafirun': 109, 'al-kafirun': 109,
    'নাসর': 110, 'nasr': 110, 'an-nasr': 110,
    'লাহাব': 111, 'lahab': 111, 'al-masad': 111, 'মাসাদ': 111,
    'ইখলাস': 112, 'ikhlas': 112, 'al-ikhlas': 112,
    'ফালাক': 113, 'falaq': 113, 'al-falaq': 113,
    'নাস': 114, 'nas': 114, 'an-nas': 114,
  };

  static const _displayNames = <int, String>{
    46: 'আহকাফ', 47: 'মুহাম্মদ', 48: 'ফাতহ', 49: 'হুজুরাত',
    50: 'কাফ', 51: 'ধারিয়াত', 52: 'তূর', 53: 'নাজম',
    54: 'ক্বামার', 55: 'রাহমান', 56: 'ওয়াকিয়া', 57: 'হাদীদ',
    58: 'মুজাদালা', 59: 'হাশর', 60: 'মুমতাহিনা', 61: 'সফ',
    62: 'জুমুআ', 63: 'মুনাফিকুন', 64: 'তাগাবুন', 65: 'তালাক',
    66: 'তাহরীম', 67: 'মুলক', 68: 'কলম', 69: 'হাক্কাহ',
    70: 'মাআরিজ', 71: 'নূহ', 72: 'জিন', 73: 'মুজাম্মিল',
    74: 'মুদ্দাস্সির', 75: 'কিয়ামাহ', 76: 'ইনসান', 77: 'মুরসালাত',
    78: 'নাবা', 79: 'নাযিআত', 80: 'আবাসা', 81: 'তাকভীর',
    82: 'ইনফিতার', 83: 'মুতাফফিফীন', 84: 'ইনশিকাক', 85: 'বুরূজ',
    86: 'তারিক', 87: 'আলা', 88: 'গাশিয়াহ', 89: 'ফজর',
    90: 'বালাদ', 91: 'শামস', 92: 'লাইল', 93: 'দুহা',
    94: 'ইনশিরাহ', 95: 'তীন', 96: 'আলাক', 97: 'কদর',
    98: 'বাইয়িনাহ', 99: 'যিলযাল', 100: 'আদিয়াত', 101: 'ক্বারিআহ',
    102: 'তাকাসুর', 103: 'আসর', 104: 'হুমাযাহ', 105: 'ফীল',
    106: 'কুরাইশ', 107: 'মাউন', 108: 'কাওসার', 109: 'কাফিরুন',
    110: 'নাসর', 111: 'লাহাব', 112: 'ইখলাস', 113: 'ফালাক',
    114: 'নাস',
  };

  @override
  void dispose() {
    _paraCtrl.dispose();
    _pageCtrl.dispose();
    _surahCtrl.dispose();
    _ayahCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _onSurahChanged(String text) {
    final q = text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final seen = <int>{};
    final list = <MapEntry<String, int>>[];
    for (final e in _surahNames.entries) {
      if (e.key.toLowerCase().startsWith(q) && !seen.contains(e.value)) {
        seen.add(e.value);
        list.add(MapEntry(_displayNames[e.value] ?? e.key, e.value));
      }
    }
    for (final e in _displayNames.entries) {
      if (e.value.toLowerCase().startsWith(q) && !seen.contains(e.key)) {
        seen.add(e.key);
        list.add(MapEntry(e.value, e.key));
      }
    }
    setState(() => _suggestions = list.take(8).toList());
  }

  int? _resolveSurah(String name) {
    final key = name.trim().toLowerCase();
    if (_surahNames.containsKey(key)) return _surahNames[key];
    for (final e in _displayNames.entries) {
      if (e.value.toLowerCase() == key) return e.key;
    }
    for (final e in _surahNames.entries) {
      if (e.key.toLowerCase() == key) return e.value;
    }
    return null;
  }

  Future<void> _searchByText() async {
    final l10n = AppLocalizations.of(context);
    final q = _textCtrl.text.trim();
    if (q.length < 2) {
      setState(() {
        _error = l10n.quranAyahInvalid;
        _textHits = [];
      });
      return;
    }

    setState(() {
      _searchingText = true;
      _error = null;
      _textHits = [];
    });

    try {
      final repo = ref.read(quranRepositoryProvider);
      await ref.read(quranLoadProvider.notifier).load();
      final results = await repo.search(q, limit: 80);
      final cfg = widget.config;
      final hits = <_TextHit>[];

      for (final r in results) {
        final page = cfg.pageForAyah(r.surahNumber, r.ayahNumber);
        if (page == null) continue; // only paras 26–30
        hits.add(_TextHit(
          surah: r.surahNumber,
          ayah: r.ayahNumber,
          page: page,
          surahName: r.surahName,
          snippet: r.snippet,
          language: r.matchedLanguage,
        ));
        if (hits.length >= 25) break;
      }

      if (!mounted) return;
      setState(() {
        _searchingText = false;
        _textHits = hits;
        if (hits.isEmpty) {
          _error = l10n.quranAyahNotInParas;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchingText = false;
        _error = '${l10n.error}: $e';
      });
    }
  }

  void _search() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _error = null;
      _textHits = [];
    });
    final cfg = widget.config;

    final paraText = _paraCtrl.text.trim();
    final pageText = _pageCtrl.text.trim();
    final surahText = _surahCtrl.text.trim();
    final ayahText = _ayahCtrl.text.trim();
    final textQ = _textCtrl.text.trim();

    final hasPara = paraText.isNotEmpty;
    final hasPage = pageText.isNotEmpty;
    final hasSurah = surahText.isNotEmpty;
    final hasAyah = ayahText.isNotEmpty;
    final hasText = textQ.isNotEmpty;

    // Ayah text search (priority when only text is provided)
    if (hasText && !hasSurah && !hasPara && !hasPage) {
      _searchByText();
      return;
    }

    if (hasAyah && !hasSurah) {
      setState(() => _error = l10n.quranSurahNameRequired);
      return;
    }

    if (hasSurah) {
      final surah = _resolveSurah(surahText);
      if (surah == null) {
        setState(() => _error = l10n.quranSurahNotFound);
        return;
      }
      if (hasAyah) {
        final ayah = int.tryParse(ayahText);
        if (ayah == null || ayah < 1) {
          setState(() => _error = l10n.quranAyahInvalid);
          return;
        }
        final page = cfg.pageForAyah(surah, ayah);
        if (page == null) {
          setState(() => _error = l10n.quranAyahNotInParas);
          return;
        }
        widget.onGoToPage(page);
        return;
      }
      final page = cfg.firstPageOfSurah(surah);
      if (page == null) {
        setState(() => _error = l10n.quranSurahNotInParas);
        return;
      }
      widget.onGoToPage(page);
      return;
    }

    if (hasPara && hasPage) {
      final para = int.tryParse(paraText);
      final pageInPara = int.tryParse(pageText);
      if (para == null || pageInPara == null) {
        setState(() => _error = l10n.quranPagePrintedHint);
        return;
      }
      final page = cfg.pageFromParaAndOffset(para, pageInPara);
      if (page == null) {
        setState(() => _error =
            '${l10n.quranPara} $para · ${l10n.quranPage} $pageInPara — ${l10n.pageNotFound}');
        return;
      }
      widget.onGoToPage(page);
      return;
    }

    if (hasPage && !hasPara) {
      final printed = int.tryParse(pageText);
      if (printed == null) {
        setState(() => _error = l10n.quranPagePrintedHint);
        return;
      }
      final filePage = printed - 1;
      if (filePage < cfg.firstPage || filePage > cfg.lastPage) {
        setState(() => _error = l10n.quranParasOnly);
        return;
      }
      widget.onGoToPage(filePage);
      return;
    }

    if (hasPara && !hasPage) {
      final para = int.tryParse(paraText);
      if (para == null) {
        setState(() => _error = l10n.quranParasOnly);
        return;
      }
      final page = cfg.firstPageOfPara(para);
      if (page == null) {
        setState(() => _error = l10n.quranParasOnly);
        return;
      }
      widget.onGoToPage(page);
      return;
    }

    if (hasText) {
      _searchByText();
      return;
    }

    setState(() => _error = l10n.quranSearchAction);
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboard,
    String? hint,
    void Function(String)? onChanged,
    bool expand = true,
  }) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          onChanged: onChanged,
          inputFormatters: keyboard == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            filled: true,
            fillColor: Colors.white10,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
    return expand ? Expanded(child: field) : field;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF34D399), size: 22),
                const SizedBox(width: 8),
                Text(
                  l10n.quranSearch,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.quranParasOnly,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Para | Page
            Row(
              children: [
                _field(
                  label: l10n.quranPara,
                  controller: _paraCtrl,
                  keyboard: TextInputType.number,
                  hint: '২৬',
                ),
                const SizedBox(width: 12),
                _field(
                  label: l10n.quranPage,
                  controller: _pageCtrl,
                  keyboard: TextInputType.number,
                  hint: '৫০৩',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.quranPagePrintedHint,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 16),

            // Surah | Ayah
            Row(
              children: [
                _field(
                  label: l10n.quranSurah,
                  controller: _surahCtrl,
                  keyboard: TextInputType.text,
                  hint: 'নাবা',
                  onChanged: _onSurahChanged,
                ),
                const SizedBox(width: 12),
                _field(
                  label: l10n.quranAyahNumber,
                  controller: _ayahCtrl,
                  keyboard: TextInputType.number,
                  hint: '১',
                ),
              ],
            ),

            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._suggestions.map(
                (s) => ListTile(
                  dense: true,
                  title: Text(
                    '${s.value}. ${s.key}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  onTap: () {
                    _surahCtrl.text = s.key;
                    setState(() => _suggestions = []);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Ayah text search
            _field(
              label: l10n.quranAyahText,
              controller: _textCtrl,
              keyboard: TextInputType.text,
              hint: l10n.quranAyahTextHint,
              expand: false,
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFF87171), fontSize: 13),
              ),
            ],

            if (_searchingText) ...[
              const SizedBox(height: 12),
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],

            if (_textHits.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${_textHits.length} — ${l10n.quranParasOnly}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _textHits.length,
                  itemBuilder: (_, i) {
                    final h = _textHits[i];
                    return ListTile(
                      dense: true,
                      title: Text(
                        '${h.surahName} \\( {h.surah}: \\){h.ayah}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        h.snippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Text(
                        '${l10n.quranPage}. ${h.page}',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => widget.onGoToPage(h.page),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _searchingText ? null : _search,
                icon: const Icon(Icons.search, size: 20),
                label: Text(
                  l10n.quranSearchAction,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ]
        ),
      ),
    );
  }
}

class _TextHit {
  final int surah;
  final int ayah;
  final int page;
  final String surahName;
  final String snippet;
  final QuranLanguage language;

  _TextHit({
    required this.surah,
    required this.ayah,
    required this.page,
    required this.surahName,
    required this.snippet,
    required this.language,
  });
}
