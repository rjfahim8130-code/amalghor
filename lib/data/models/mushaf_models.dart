class MushafPara {
  final int para;
  final int startPage;
  final int endPage;
  final int pagesInPara;

  const MushafPara({
    required this.para,
    required this.startPage,
    required this.endPage,
    required this.pagesInPara,
  });

  factory MushafPara.fromJson(Map<String, dynamic> j) => MushafPara(
        para: j['para'] as int,
        startPage: j['start_page'] as int,
        endPage: j['end_page'] as int,
        pagesInPara: j['pages_in_para'] as int,
      );
}

class MushafPageInfo {
  final int page;
  final int para;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;

  const MushafPageInfo({
    required this.page,
    required this.para,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
  });

  factory MushafPageInfo.fromJson(Map<String, dynamic> j) => MushafPageInfo(
        page: j['page'] as int,
        para: j['para'] as int,
        startSurah: j['start_surah'] as int,
        startAyah: j['start_ayah'] as int,
        endSurah: j['end_surah'] as int,
        endAyah: j['end_ayah'] as int,
      );

  /// Image asset path: assets/quran_mushaf/para_26/502.png
  String get assetPath =>
      'assets/quran_mushaf/para_$para/$page.png';
}

class MushafConfig {
  final int firstPage;
  final int lastPage;
  final List<MushafPara> paras;
  final List<MushafPageInfo> pages;
  final Map<int, MushafPageInfo> _byPage;

  MushafConfig({
    required this.firstPage,
    required this.lastPage,
    required this.paras,
    required this.pages,
  }) : _byPage = {for (final p in pages) p.page: p};

  factory MushafConfig.fromJson(Map<String, dynamic> j) {
    final paras = (j['paras'] as List)
        .map((e) => MushafPara.fromJson(e as Map<String, dynamic>))
        .toList();
    final pages = (j['pages'] as List)
        .map((e) => MushafPageInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    return MushafConfig(
      firstPage: j['first_page'] as int,
      lastPage: j['last_page'] as int,
      paras: paras,
      pages: pages,
    );
  }

  MushafPageInfo? pageInfo(int page) => _byPage[page];

  MushafPara? paraForPage(int page) {
    for (final p in paras) {
      if (page >= p.startPage && page <= p.endPage) return p;
    }
    return null;
  }

  /// Para number → first page of that para (null if not uploaded)
  int? firstPageOfPara(int para) {
    for (final p in paras) {
      if (p.para == para) return p.startPage;
    }
    return null;
  }

  /// Para + page-within-para (1-based) → absolute page
  int? pageFromParaAndOffset(int para, int pageInPara) {
    for (final p in paras) {
      if (p.para == para) {
        if (pageInPara < 1 || pageInPara > p.pagesInPara) return null;
        return p.startPage + pageInPara - 1;
      }
    }
    return null;
  }

  /// Find page that contains surah:ayah
  int? pageForAyah(int surah, int ayah) {
    for (final p in pages) {
      final afterStart = (p.startSurah < surah) ||
          (p.startSurah == surah && p.startAyah <= ayah);
      final beforeEnd = (p.endSurah > surah) ||
          (p.endSurah == surah && p.endAyah >= ayah);
      if (afterStart && beforeEnd) return p.page;
    }
    return null;
  }

  /// First page where this surah appears
  int? firstPageOfSurah(int surah) {
    for (final p in pages) {
      if (p.startSurah == surah || p.endSurah == surah) return p.page;
    }
    return null;
  }
}
