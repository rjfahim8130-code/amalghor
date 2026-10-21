import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
import '../../data/models/mushaf_models.dart';
import '../../data/repositories/mushaf_repository.dart';
import '../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final configAsync = ref.watch(mushafConfigProvider);

    return configAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.quranHafeziTitle)),
        body: Center(
          child: Text('${l10n.error}: $e'),
        ),
      ),
      data: (cfg) {
        if (!_ready || _pageController == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final para = cfg.paraForPage(_currentPage);
        final subtitle = para == null
            ? '${l10n.quranPage} $_currentPage'
            : '${l10n.quranPara} ${para.para} · ${l10n.quranPage} $_currentPage';

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
                  l10n.quranHafeziTitle,
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
              // নতুন অনুবাদ পেজে যাওয়ার বাটন
              IconButton(
                tooltip: l10n.quranPageTranslation,
                icon: Icon(
                  Icons.translate_rounded,
                  size: 22,
                  color: colors.textPrimary,
                ),
                onPressed: () {
                  context.push(
                    '/quran/mushaf/translation?page=$_currentPage',
                  );
                },
              ),
              IconButton(
                tooltip: l10n.quranSearch,
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
                // Portrait: horizontal, RTL (left←right = next page)
                // Landscape: vertical (up↔down = prev/next page)
                scrollDirection:
                    isPortrait ? Axis.horizontal : Axis.vertical,
                reverse: isPortrait, // RTL only in portrait
                physics: const BouncingScrollPhysics(
                  parent: PageScrollPhysics(),
                ),
                itemCount: cfg.lastPage - cfg.firstPage + 1,
                onPageChanged: (i) => _onPageChanged(i, cfg),
                itemBuilder: (context, index) {
                  final page = cfg.firstPage + index;
                  final pageInfo = cfg.pageInfo(page);
                  if (pageInfo == null) {
                    return Center(
                      child: Text(
                        l10n.pageNotFound,
                        style: const TextStyle(color: Colors.white70),
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
      // ~2x zoom from center
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
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onDoubleTap: onDoubleTapZoom,
      child: InteractiveViewer(
        transformationController: transformCtrl,
        minScale: 1.0,
        maxScale: 4.0,
        panEnabled: true,
        scaleEnabled: true,
        clipBehavior: Clip.hardEdge,
        child: ColoredBox(
          color: Colors.black,
          child: Center(
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
