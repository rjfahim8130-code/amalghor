import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
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
  final TransformationController _transformCtrl = TransformationController();
  int _currentPage = 502;
  bool _ready = false;
  Orientation? _lastOrientation;

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
    _transformCtrl.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformCtrl.value = Matrix4.identity();
  }

  void _onPageChanged(int index, MushafConfig cfg) {
    final page = cfg.firstPage + index;
    setState(() => _currentPage = page);
    _resetZoom();
    MushafRepository.instance.saveLastPage(page);
  }

  void _goToPage(int page, MushafConfig cfg) {
    final p = page.clamp(cfg.firstPage, cfg.lastPage);
    final index = p - cfg.firstPage;
    _pageController?.jumpToPage(index);
    setState(() => _currentPage = p);
    _resetZoom();
    MushafRepository.instance.saveLastPage(p);
  }

  void _openSearch(MushafConfig cfg) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
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

  /// Rebuild PageController when orientation changes (H ↔ V).
  void _ensureController(Orientation orientation, MushafConfig cfg) {
    if (_lastOrientation == orientation && _pageController != null) return;
    _lastOrientation = orientation;
    final index = _currentPage - cfg.firstPage;
    _pageController?.dispose();
    _pageController = PageController(initialPage: index);
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
                  style: TextStyle(fontSize: 11, color: colors.textMuted),
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
          body: OrientationBuilder(
            builder: (context, orientation) {
              _ensureController(orientation, cfg);

              final isPortrait = orientation == Orientation.portrait;

              return PageView.builder(
                key: ValueKey('pv_$orientation'),
                controller: _pageController,
                // Portrait: horizontal, RTL (বাম←ডান = পরের পৃষ্ঠা)
                // Landscape: vertical (উপর↔নিচ = আগের/পরের পৃষ্ঠা)
                scrollDirection:
                    isPortrait ? Axis.horizontal : Axis.vertical,
                reverse: isPortrait, // শুধু পোর্ট্রেটে RTL
                physics: const BouncingScrollPhysics(
                  parent: PageScrollPhysics(),
                ),
                itemCount: cfg.lastPage - cfg.firstPage + 1,
                onPageChanged: (i) => _onPageChanged(i, cfg),
                itemBuilder: (context, index) {
                  final page = cfg.firstPage + index;
                  final pageInfo = cfg.pageInfo(page);
                  if (pageInfo == null) {
                    return const Center(
                      child: Text(
                        'পৃষ্ঠা পাওয়া যায়নি',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return _MushafPage(
                    assetPath: pageInfo.assetPath,
                    transformCtrl: _transformCtrl,
                    onDoubleTapZoom: _toggleZoom,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _toggleZoom() {
    final m = _transformCtrl.value;
    final isZoomed = m.getMaxScaleOnAxis() > 1.05;
    if (isZoomed) {
      _resetZoom();
    } else {
      // \~2x zoom from center
      final size = MediaQuery.of(context).size;
      final zoomed = Matrix4.identity()
        ..translate(size.width / 2, size.height / 2)
        ..scale(2.0)
        ..translate(-size.width / 2, -size.height / 2);
      _transformCtrl.value = zoomed;
    }
  }
}

/// One page: equalized size + polished zoom
class _MushafPage extends StatelessWidget {
  final String assetPath;
  final TransformationController transformCtrl;
  final VoidCallback onDoubleTapZoom;

  const _MushafPage({
    required this.assetPath,
    required this.transformCtrl,
    required this.onDoubleTapZoom,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTapZoom,
      child: InteractiveViewer(
        transformationController: transformCtrl,
        minScale: 1.0,
        maxScale: 4.0,
        // প্যান শুধু জুম অবস্থায়
        panEnabled: true,
        scaleEnabled: true,
        clipBehavior: Clip.hardEdge,
        child: ColoredBox(
          color: Colors.black,
          child: Center(
            child: Image.asset(
              assetPath,
              // সব পৃষ্ঠা একইভাবে স্ক্রিনে ফিট — ছোট/বড় সোর্স একই দেখাবে
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              filterQuality: FilterQuality.high,
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
        ),
      ),
    );
  }
}
