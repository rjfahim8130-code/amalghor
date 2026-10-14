import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/router.dart';
import '../../data/models/prayer_times.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/prayer_provider.dart';
import 'widgets/current_status_card.dart';
import 'widgets/home_header.dart';
import 'widgets/live_clock_card.dart';
import 'widgets/tri_calendar_row.dart';

/// Main dashboard — shows:
///   - HomeHeader (location)
///   - LiveClockCard
///   - CurrentStatusCard (current + next prayer only)
///   - TriCalendarRow
///   - PDF hero button
///
/// The full prayer timeline lives on the "নামায" (Prayer) tab.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerAsync = ref.watch(currentDayPrayerProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppConstants.emeraldPrimary,
          backgroundColor: AppConstants.surfaceDark,
          onRefresh: () async {
            ref.invalidate(currentDayPrayerProvider);
            await ref.read(currentDayPrayerProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.space2xl,
            ),
            children: [
              const HomeHeader(),
              const SizedBox(height: AppConstants.spaceLg),

              prayerAsync.when(
                loading: () => const _HomeLoading(),
                error: (e, _) => _HomeError(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(currentDayPrayerProvider),
                ),
                data: (prayer) => _HomeBody(prayer: prayer),
              ),

              const SizedBox(height: AppConstants.spaceLg),
              const _PdfHeroButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BODY — clean, no timings list
// ─────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  final PrayerTimes prayer;

  const _HomeBody({required this.prayer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiveClockCard(prayer: prayer),
        const SizedBox(height: AppConstants.spaceLg),
        CurrentStatusCard(prayer: prayer),
        const SizedBox(height: AppConstants.spaceLg),
        const TriCalendarRow(),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// LOADING / ERROR
// ─────────────────────────────────────────────
class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: CircularProgressIndicator(
          color: AppConstants.emeraldPrimary,
        ),
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFEF4444),
            size: 40,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            l10n.error,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontSubtitle,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontCaption,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PDF HERO BUTTON
// ─────────────────────────────────────────────
class _PdfHeroButton extends StatelessWidget {
  const _PdfHeroButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.emeraldPrimary.withValues(alpha: 0.18),
            AppConstants.emeraldPrimary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppConstants.emeraldPrimary.withValues(alpha: 0.35),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceSm),
                decoration: BoxDecoration(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppConstants.emeraldPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Text(
                  l10n.generatePdf,
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: AppConstants.fontBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => context.push(Routes.pdfSettings),
              icon: const Icon(Icons.download_rounded),
              label: Text(l10n.generatePdfShort),
            ),
          ),
        ],
      ),
    );
  }
}
