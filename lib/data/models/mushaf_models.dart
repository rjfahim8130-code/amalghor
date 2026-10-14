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
}
