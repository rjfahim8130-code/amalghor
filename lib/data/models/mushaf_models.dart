class MushafParaInfo {
  final int para;
  final int startPage;
  final int endPage;
  final int pages;

  const MushafParaInfo({
    required this.para,
    required this.startPage,
    required this.endPage,
    required this.pages,
  });

  factory MushafParaInfo.fromJson(Map<String, dynamic> j) => MushafParaInfo(
        para: j['para'] as int,
        startPage: j['start_page'] as int,
        endPage: j['end_page'] as int,
        pages: j['pages'] as int,
      );
}

class MushafConfig {
  final String pdfAsset;
  final int firstContentPage;
  final int lastContentPage;
  final int totalPdfPages;
  final int fatihaPage;
  final List<MushafParaInfo> paras;

  const MushafConfig({
    required this.pdfAsset,
    required this.firstContentPage,
    required this.lastContentPage,
    required this.totalPdfPages,
    required this.fatihaPage,
    required this.paras,
  });

  factory MushafConfig.fromJson(Map<String, dynamic> j) => MushafConfig(
        pdfAsset: j['pdf_asset'] as String,
        firstContentPage: j['first_content_page'] as int,
        lastContentPage: j['last_content_page'] as int,
        totalPdfPages: j['total_pdf_pages'] as int,
        fatihaPage: j['fatiha_page'] as int,
        paras: (j['paras'] as List)
            .map((e) => MushafParaInfo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// পারা নম্বর → তথ্য
  MushafParaInfo? paraOf(int para) {
    try {
      return paras.firstWhere((p) => p.para == para);
    } catch (_) {
      return null;
    }
  }

  /// PDF পৃষ্ঠা → কোন পারা
  MushafParaInfo? paraForPage(int page) {
    if (page == fatihaPage) return paraOf(1);
    try {
      return paras.firstWhere(
        (p) => page >= p.startPage && page <= p.endPage,
      );
    } catch (_) {
      return null;
    }
  }

  /// পারা + পারার ভিতরের পৃষ্ঠা (১-ভিত্তিক) → PDF পৃষ্ঠা
  int? pageForParaPage(int para, int paraPage) {
    final info = paraOf(para);
    if (info == null) return null;
    if (paraPage < 1 || paraPage > info.pages) return null;
    return info.startPage + paraPage - 1;
  }

  bool isValidContentPage(int page) =>
      page >= firstContentPage && page <= lastContentPage;

  /// সূরা নম্বর দিয়ে আনুমানিক শুরুর পৃষ্ঠা (হাফেজী আনুমানিক)।
  /// পরে quran_pages.json-এ সঠিক ম্যাপ দিয়ে প্রতিস্থাপন করা যাবে।
  int approximatePageForSurah(int surah) {
    // ফাতিহা
    if (surah <= 1) return fatihaPage;
    // বাকারা ≈ পারা ১–৩
    if (surah == 2) return 3;
    // মোটামুটি পারা ধরে (১১৪ সূরার জন্য স্থায়ী ম্যাপ পরে)
    if (surah <= 4) return paraOf(4)?.startPage ?? 63;
    if (surah <= 6) return paraOf(7)?.startPage ?? 123;
    if (surah <= 9) return paraOf(10)?.startPage ?? 183;
    if (surah <= 12) return paraOf(12)?.startPage ?? 223;
    if (surah <= 16) return paraOf(14)?.startPage ?? 263;
    if (surah <= 20) return paraOf(16)?.startPage ?? 303;
    if (surah <= 24) return paraOf(18)?.startPage ?? 343;
    if (surah <= 33) return paraOf(21)?.startPage ?? 403;
    if (surah <= 36) return paraOf(22)?.startPage ?? 423;
    if (surah <= 48) return paraOf(26)?.startPage ?? 503;
    if (surah <= 57) return paraOf(27)?.startPage ?? 523;
    if (surah <= 66) return paraOf(28)?.startPage ?? 543;
    if (surah <= 77) return paraOf(29)?.startPage ?? 563;
    return paraOf(30)?.startPage ?? 587;
  }
}
