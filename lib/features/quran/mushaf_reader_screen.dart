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
        final para = config.paraForPage(_currentPage);
        final paraLabel = para == null
            ? ''
            : 'পারা ${para.para} · পৃষ্ঠা ${_currentPage}';

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'তেলাওয়াত',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (paraLabel.isNotEmpty)
                  Text(
                    paraLabel,
                    style: const TextStyle(
                      fontSize: 11,
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
                onPressed: () {
                  // পরে সূরা/আয়াত ম্যাপ যোগ করলে এখানে লিংক হবে
                  // আপাতত সূরা লিস্টে নিয়ে যাই
                  context.push('/quran');
                },
              ),
            ],
          ),
          body: PdfViewer.asset(
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
        );
      },
    );
  }
}
