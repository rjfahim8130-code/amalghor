import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../core/constants.dart';
import '../../providers/mushaf_provider.dart';
import 'widgets/mushaf_search_sheet.dart';

class MushafReaderScreen extends ConsumerStatefulWidget {
  final int initialPage;

  const MushafReaderScreen({
    super.key,
    this.initialPage = 2,
  });

  @override
  ConsumerState<MushafReaderScreen> createState() => _MushafReaderScreenState();
}

class _MushafReaderScreenState extends ConsumerState<MushafReaderScreen> {
  PdfViewerController? _controller;
  int _currentPage = 2;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(2, 611);
  }

  void _goToPage(int page) {
    final cfg = ref.read(mushafConfigProvider).valueOrNull;
    if (cfg == null) return;
    final p = page.clamp(cfg.firstContentPage, cfg.lastContentPage);
    _controller?.goToPage(pageNumber: p);
    setState(() => _currentPage = p);
  }

  void _openSearch() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => MushafSearchSheet(
        onGoToPage: (page) {
          Navigator.pop(context);
          _goToPage(page);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(mushafConfigProvider);

    return configAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('তেলাওয়াত')),
        body: Center(child: Text('লোড ব্যর্থ: $e')),
      ),
      data: (config) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;
            final para = config.paraForPage(_currentPage);
            final paraLabel = para == null
                ? 'পৃষ্ঠা $_currentPage'
                : 'পারা ${para.para} · পৃষ্ঠা $_currentPage';

            return Scaffold(
              appBar: isLandscape
                  ? null
                  : AppBar(
                      toolbarHeight: 48,
                      titleSpacing: 0,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'তেলাওয়াত',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            paraLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppConstants.textMuted,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          tooltip: 'সার্চ',
                          icon: const Icon(Icons.search, size: 22),
                          onPressed: _openSearch,
                        ),
                        IconButton(
                          tooltip: 'তরজমা',
                          icon: const Icon(Icons.translate, size: 22),
                          onPressed: () => context.push('/quran'),
                        ),
                      ],
                    ),
              body: Stack(
                children: [
                  PdfViewer.asset(
                    config.pdfAsset,
                    controller: _controller ??= PdfViewerController(),
                    params: PdfViewerParams(
                      initialPageNumber: _currentPage,
                      onPageChanged: (page) {
                        if (page == null) return;
                        final p = page.clamp(
                          config.firstContentPage,
                          config.lastContentPage,
                        );
                        if (p != page) {
                          _controller?.goToPage(pageNumber: p);
                        }
                        setState(() => _currentPage = p);
                      },
                    ),
                  ),
                  // ল্যান্ডস্কেপে ছোট ফ্লোটিং কন্ট্রোল
                  if (isLandscape)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 4,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: [
                          Material(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                              onPressed: () => context.pop(),
                            ),
                          ),
                          const Spacer(),
                          Material(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Text(
                                paraLabel,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Material(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            child: IconButton(
                              icon: const Icon(Icons.search, color: Colors.white, size: 20),
                              onPressed: _openSearch,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Material(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            child: IconButton(
                              icon: const Icon(Icons.translate, color: Colors.white, size: 20),
                              onPressed: () => context.push('/quran'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
