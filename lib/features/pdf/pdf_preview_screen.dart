import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/constants.dart';
import '../../providers/pdf_provider.dart';

/// Runs PDF generation and shows the result with a print/share UI.
class PdfPreviewScreen extends ConsumerStatefulWidget {
  const PdfPreviewScreen({super.key});

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pdfGeneratorProvider.notifier).generate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(pdfGeneratorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          if (progress.bytes != null)
            IconButton(
              tooltip: 'Regenerate',
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(pdfGeneratorProvider.notifier).generate(),
            ),
        ],
      ),
      body: _body(progress),
    );
  }

  Widget _body(PdfProgress progress) {
    if (progress.isGenerating) {
      return _ProgressView(
        stage: progress.stage,
        progress: progress.progress,
      );
    }

    if (progress.error != null) {
      return _ErrorView(
        message: progress.error!,
        onRetry: () =>
            ref.read(pdfGeneratorProvider.notifier).generate(),
      );
    }

    if (progress.bytes == null) {
      return const Center(
        child: Text(
          'Nothing to preview',
          style: TextStyle(color: AppConstants.textMuted),
        ),
      );
    }

    return PdfPreview(
      build: (_) async => progress.bytes!,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      allowPrinting: true,
      allowSharing: true,
      dynamicLayout: false,
    );
  }
}

// ─────────────────────────────────────────────
// PROGRESS VIEW
// ─────────────────────────────────────────────

class _ProgressView extends StatelessWidget {
  final String stage;
  final double progress;

  const _ProgressView({
    required this.stage,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppConstants.emeraldPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.picture_as_pdf_outlined,
                color: AppConstants.emeraldPrimary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            const Text(
              'Generating PDF',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: AppConstants.fontHeading,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              stage,
              style: const TextStyle(
                color: AppConstants.textMuted,
                fontSize: AppConstants.fontBody,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceXl),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppConstants.surfaceDark,
                valueColor: const AlwaysStoppedAnimation(
                  AppConstants.emeraldPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: AppConstants.emeraldPrimary,
                fontSize: AppConstants.fontSubtitle,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFEF4444),
              size: 48,
            ),
            const SizedBox(height: AppConstants.spaceMd),
            const Text(
              'PDF generation failed',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: AppConstants.fontSubtitle,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppConstants.textMuted,
                fontSize: AppConstants.fontBody,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
