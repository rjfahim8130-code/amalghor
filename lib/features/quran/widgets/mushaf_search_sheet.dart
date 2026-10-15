import 'package:flutter/material.dart';

import '../../../data/models/mushaf_models.dart';

/// Search: para | para+page | surah name | surah+ayah
class MushafSearchSheet extends StatefulWidget {
  final MushafConfig config;
  final void Function(int page) onGoToPage;

  const MushafSearchSheet({
    super.key,
    required this.config,
    required this.onGoToPage,
  });

  @override
  State<MushafSearchSheet> createState() => _MushafSearchSheetState();
}

class _MushafSearchSheetState extends State<MushafSearchSheet> {
  final _controller = TextEditingController();
  String? _error;
  String? _hint;

  // Surahs present in paras 26–30 (name variants → number)
  static const _surahNames = <String, int>{
    'আহকাফ': 46, 'ahqaf': 46, 'al-ahqaf': 46,
    'মুহাম্মদ': 47, 'muhammad': 47,
    'ফাতহ': 48, 'fath': 48, 'al-fath': 48, 'ফতহ': 48,
    'হুজুরাত': 49, 'hujurat': 49, 'al-hujurat': 49, 'হুজরাত': 49,
    'কাফ': 50, 'qaf': 50,
    'ধারিয়াত': 51, 'dhariyat': 51, 'adariyat': 51, 'জারিয়াত': 51,
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
    'নূহ': 71, 'nuh': 71, 'নূহঃ': 71,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final q = _controller.text.trim();
    if (q.isEmpty) {
      setState(() {
        _error = 'কিছু লিখুন';
        _hint = null;
      });
      return;
    }

    final cfg = widget.config;
    int? page;

    // 1) "পারা 30" / "para 26" / "30"
    final paraOnly = RegExp(
      r'^(?:পারা|para|juz)?\s*(\d{1,2})$',
      caseSensitive: false,
    ).firstMatch(q);
    if (paraOnly != null) {
      final n = int.parse(paraOnly.group(1)!);
      page = cfg.firstPageOfPara(n);
      if (page == null) {
        setState(() {
          _error = 'পারা $n এখনো আপলোড নেই (শুধু ২৬–৩০)';
          _hint = null;
        });
        return;
      }
      widget.onGoToPage(page);
      return;
    }

    // 2) "পারা 30 পৃষ্ঠা 5" / "30 5" / "para 26 page 1"
    final paraPage = RegExp(
      r'^(?:পারা|para|juz)?\s*(\d{1,2})\s*(?:পৃষ্ঠা|page|p)?\s*(\d{1,2})$',
      caseSensitive: false,
    ).firstMatch(q);
    if (paraPage != null) {
      final para = int.parse(paraPage.group(1)!);
      final offset = int.parse(paraPage.group(2)!);
      page = cfg.pageFromParaAndOffset(para, offset);
      if (page == null) {
        setState(() {
          _error = 'পারা $para-এর পৃষ্ঠা $offset নেই';
          _hint = null;
        });
        return;
      }
      widget.onGoToPage(page);
      return;
    }

    // 3) "বাকারা 33" style → surah + ayah  OR  surah name only
    // Try "name number"
    final nameAyah = RegExp(
      r'^(.+?)\s+(\d{1,3})$',
    ).firstMatch(q);
    if (nameAyah != null) {
      final name = nameAyah.group(1)!.trim().toLowerCase();
      final ayah = int.parse(nameAyah.group(2)!);
      final surah = _resolveSurah(name);
      if (surah != null) {
        page = cfg.pageForAyah(surah, ayah);
        if (page == null) {
          setState(() {
            _error = 'সূরা $surah আয়াত $ayah এই পারাগুলোতে নেই';
            _hint = null;
          });
          return;
        }
        widget.onGoToPage(page);
        return;
      }
    }

    // 4) Surah name only
    final surah = _resolveSurah(q.toLowerCase());
    if (surah != null) {
      page = cfg.firstPageOfSurah(surah);
      if (page == null) {
        setState(() {
          _error = 'সূরাটি পারা ২৬–৩০-এ নেই';
          _hint = null;
        });
        return;
      }
      widget.onGoToPage(page);
      return;
    }

    // 5) Absolute page number only (502–610)
    final absPage = int.tryParse(q);
    if (absPage != null &&
        absPage >= cfg.firstPage &&
        absPage <= cfg.lastPage) {
      widget.onGoToPage(absPage);
      return;
    }

    setState(() {
      _error = 'কিছু পাওয়া যায়নি';
      _hint =
          'উদাহরণ:\n• পারা ৩০\n• পারা ২৬ পৃষ্ঠা ৫\n• নাবা\n• বালাদ ২০\n• ৬০০';
    });
  }

  int? _resolveSurah(String name) {
    final key = name.trim().toLowerCase();
    if (_surahNames.containsKey(key)) return _surahNames[key];
    // try without al-/আল-
    for (final e in _surahNames.entries) {
      if (e.key.toLowerCase() == key) return e.value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
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
          const SizedBox(height: 16),
          const Text(
            'সার্চ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'পারা · পারা+পৃষ্ঠা · সূরা · সূরা+আয়াত',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'যেমন: পারা ৩০  বা  নাবা ১০',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Colors.white70),
                onPressed: _search,
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFFF87171))),
          ],
          if (_hint != null) ...[
            const SizedBox(height: 8),
            Text(_hint!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          // Quick para chips (only uploaded)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.config.paras.map((p) {
              return ActionChip(
                label: Text('পারা ${p.para}'),
                onPressed: () => widget.onGoToPage(p.startPage),
                backgroundColor: Colors.white12,
                labelStyle: const TextStyle(color: Colors.white),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
