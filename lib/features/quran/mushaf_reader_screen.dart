import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../data/models/mushaf_models.dart';
import '../../data/repositories/mushaf_repository.dart';
import '../../providers/mushaf_provider.dart';
import 'widgets/mushaf_search_sheet.dart';

class MushafReaderScreen extends ConsumerStatefulWidget {
  final int? initialPage;

  const MushafReaderScreen({super.key, this.initialPage});

  @override
  ConsumerState<MushafReaderScreen> createState() =>
      _MushafReaderScreenState();
}

class _MushafReaderScreenState extends ConsumerState<MushafReaderScreen> {
  PageController? _pageController;
  int _currentPage = 502;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    final cfg = await MushafRepository.instance.load();
    int page;
    if (widget.initialPage != null) {
      page = widget.initialPage!.clamp(cfg.firstPage, cfg.lastPage);
    } else {
      page = await MushafRepository.instance.loadLastPage();
    }
    _currentPage = page;
    final index = page - cfg.firstPage;
    _pageController = PageController(initialPage: index);
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, MushafConfig cfg) {
    final page = cfg.firstPage + index;
    setState(() => _currentPage = page);
    MushafRepository.instance.saveLastPage(page);
  }

  void _goToPage(int page, MushafConfig cfg) {
    final p = page.clamp(cfg.firstPage, cfg.lastPage);
    final index = p - cfg.firstPage;
    _pageController?.jumpToPage(index);
    setState(() => _currentPage = p);
    MushafRepository.instance.saveLastPage(p);
  }

  void _openSearch(MushafConfig cfg) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => MushafSearchSheet(
        config: cfg,
        onGoToPage: (page) {
          Navigator.pop(context);
          _goToPage(page, cfg);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final configAsync = ref.watch(mushafConfigProvider);

    return configAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('হাফিজী কুরআন')),
        body: Center(child: Text('লোড ব্যর্থ: $e')),
      ),
      data: (cfg) {
        if (!_ready || _pageController == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final para = cfg.paraForPage(_currentPage);
        final subtitle = para == null
            ? 'পৃষ্ঠা $_currentPage'
            : 'পারা ${para.para} · পৃষ্ঠা $_currentPage';

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: colors.pageBackground,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.textPrimary),
              onPressed: () => context.pop(),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'হাফিজী কুরআন',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'সার্চ',
                icon: Icon(Icons.search, size: 22, color: colors.textPrimary),
                onPressed: () => _openSearch(cfg),
              ),
            ],
          ),
          body: PageView.builder(
            controller: _pageController,
            // RTL: swipe right → next page (like real mushaf)
            reverse: true,
            itemCount: cfg.lastPage - cfg.firstPage + 1,
            onPageChanged: (i) => _onPageChanged(i, cfg),
            itemBuilder: (context, index) {
              final page = cfg.firstPage + index;
              final pageInfo = cfg.pageInfo(page);
              if (pageInfo == null) {
                return const Center(
                  child: Text('পৃষ্ঠা পাওয়া যায়নি',
                      style: TextStyle(color: Colors.white70)),
                );
              }
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image.asset(
                    pageInfo.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'ছবি লোড হয়নি\nফাইল আছে কিনা চেক করুন',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
