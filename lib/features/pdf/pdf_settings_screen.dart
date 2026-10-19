import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/settings_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/pdf_provider.dart';
import 'pdf_cluster.dart';

/// Configuration screen for PDF generation.
class PdfSettingsScreen extends ConsumerWidget {
  const PdfSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final opts = ref.watch(pdfOptionsProvider);
    final notifier = ref.read(pdfOptionsProvider.notifier);
    final currentYear = DateTime.now().year;
    final isHanafi = opts.madhhab == MadhhabType.hanafi;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pdfCalendar)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceLg),
        children: [
          // ─── Year ─────────────────────────────
          _SectionHeader(l10n.pdfYear),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceSm,
            ),
            child: Wrap(
              spacing: AppConstants.spaceSm,
              runSpacing: AppConstants.spaceSm,
              children: [
                for (final y in [
                  currentYear - 1,
                  currentYear,
                  currentYear + 1,
                ])
                  _Chip(
                    label: '$y',
                    selected: opts.year == y,
                    onTap: () => notifier.setYear(y),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Cluster granularity ──────────────
          _SectionHeader(l10n.pdfMode),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceSm,
            ),
            child: Text(
              '${l10n.pdfModeFull}\n${l10n.pdfModeShort1Min}',
              style: const TextStyle(
                color: AppConstants.textMuted,
                fontSize: AppConstants.fontCaption,
                height: 1.5,
              ),
            ),
          ),
          for (final g in ClusterGranularity.values)
            _RadioTile<ClusterGranularity>(
              title: _granularityLabel(g, l10n),
              value: g,
              group: opts.granularity,
              onChanged: notifier.setGranularity,
            ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Primary calendar ────────────────
          _SectionHeader(l10n.pdfCalendarPrimary),
          _RadioTile<CalendarPrimary>(
            title: l10n.pdfPrimaryEnglish,
            value: CalendarPrimary.english,
            group: opts.primaryCalendar,
            onChanged: notifier.setPrimaryCalendar,
          ),
          _RadioTile<CalendarPrimary>(
            title: l10n.pdfPrimaryBangla,
            value: CalendarPrimary.bangla,
            group: opts.primaryCalendar,
            onChanged: notifier.setPrimaryCalendar,
          ),
          _RadioTile<CalendarPrimary>(
            title: l10n.pdfPrimaryHijri,
            value: CalendarPrimary.hijri,
            group: opts.primaryCalendar,
            onChanged: notifier.setPrimaryCalendar,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Madhhab ─────────────────────────
          _SectionHeader(l10n.madhhab),
          _RadioTile<MadhhabType>(
            title: l10n.madhhabHanafi,
            value: MadhhabType.hanafi,
            group: opts.madhhab,
            onChanged: notifier.setMadhhab,
          ),
          _RadioTile<MadhhabType>(
            title: l10n.madhhabShafii,
            value: MadhhabType.shafii,
            group: opts.madhhab,
            onChanged: notifier.setMadhhab,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Safety times ────────────────────
          _SectionHeader(l10n.pdfTagline),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.sehriEnds,
                    style: const TextStyle(
                      color: AppConstants.textPrimary,
                      fontSize: AppConstants.fontBody,
                    ),
                  ),
                ),
                Switch(
                  value: opts.showSafetyTimes,
                  onChanged: notifier.setShowSafetyTimes,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Column selection ────────────────
          _SectionHeader(l10n.pdfCalendarPrimary),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${opts.columns.length}',
                    style: const TextStyle(
                      color: AppConstants.textMuted,
                      fontSize: AppConstants.fontCaption,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      notifier.selectAllColumns(isHanafi: isHanafi),
                  child: Text(l10n.done),
                ),
                TextButton(
                  onPressed: notifier.clearColumns,
                  child: Text(l10n.close),
                ),
              ],
            ),
          ),
          for (final c in PdfColumn.values)
            if (!c.requiresHanafi || isHanafi)
              _CheckTile(
                title: _columnLabel(c, l10n),
                checked: opts.columns.contains(c),
                onChanged: (_) => notifier.toggleColumn(c),
                disabled: c == PdfColumn.date,
              ),

          const SizedBox(height: AppConstants.spaceXl),

          // ─── Generate button ─────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
            ),
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (opts.columns.isEmpty) {
                    notifier.selectAllColumns(isHanafi: isHanafi);
                  }
                  context.push('/pdf/preview');
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(l10n.generatePdfShort),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  /// Maps the ACTUAL enum values from `pdf_cluster.dart` to labels.
  String _granularityLabel(
    ClusterGranularity g,
    AppLocalizations l10n,
  ) {
    switch (g) {
      case ClusterGranularity.dayWise:
        return l10n.pdfModeFull;
      case ClusterGranularity.tenSec:
        return '10 sec';
      case ClusterGranularity.fifteenSec:
        return '15 sec';
      case ClusterGranularity.twentySec:
        return '20 sec';
      case ClusterGranularity.thirtySec:
        return l10n.pdfModeShort30Sec;
      case ClusterGranularity.fortySec:
        return '40 sec';
      case ClusterGranularity.oneMin:
        return l10n.pdfModeShort1Min;
      case ClusterGranularity.twoMin:
        return '2 min';
      case ClusterGranularity.fiveMin:
        return '5 min';
    }
  }

  /// Maps the ACTUAL enum values from `pdf_cluster.dart` to labels.
  String _columnLabel(PdfColumn c, AppLocalizations l10n) {
    switch (c) {
      case PdfColumn.date:
        return l10n.dateGregorian;
      case PdfColumn.tahajjud:
        return l10n.tahajjudLabel;
      case PdfColumn.sehri:
        return l10n.sehri;
      case PdfColumn.fajr:
        return l10n.fajr;
      case PdfColumn.sunrise:
        return l10n.sunrise;
      case PdfColumn.ishraq:
        return l10n.ishraq;
      case PdfColumn.dhuhr:
        return l10n.dhuhr;
      case PdfColumn.asr:
        return l10n.asr;
      case PdfColumn.sunset:
        return l10n.sunset;
      case PdfColumn.iftar:
        return l10n.iftar;
      case PdfColumn.maghrib:
        return l10n.maghrib;
      case PdfColumn.isha:
        return l10n.isha;
      case PdfColumn.ishaMustahab:
        return l10n.mustahabbIsha;
    }
  }
}

// ─────────────────────────────────────────────
// SECTION WIDGETS
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceSm,
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppConstants.emeraldPrimary,
          fontSize: AppConstants.fontMicro,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _RadioTile<T> extends StatelessWidget {
  final String title;
  final T value;
  final T group;
  final ValueChanged<T> onChanged;

  const _RadioTile({
    required this.title,
    required this.value,
    required this.group,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceMd,
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? AppConstants.emeraldPrimary
                  : AppConstants.textFaint,
              size: 20,
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected
                      ? AppConstants.textPrimary
                      : AppConstants.textMuted,
                  fontSize: AppConstants.fontBody,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  final String title;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final bool disabled;

  const _CheckTile({
    required this.title,
    required this.checked,
    required this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : () => onChanged(!checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceSm,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked
                    ? AppConstants.emeraldPrimary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: checked
                      ? AppConstants.emeraldPrimary
                      : (disabled
                          ? AppConstants.textFaint
                          : AppConstants.textMuted),
                  width: 1.4,
                ),
              ),
              child: checked
                  ? const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: disabled
                      ? AppConstants.textFaint
                      : AppConstants.textPrimary,
                  fontSize: AppConstants.fontBody,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceSm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppConstants.emeraldPrimary.withValues(alpha: 0.20)
                : AppConstants.surfaceDarker,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            border: Border.all(
              color: selected
                  ? AppConstants.emeraldPrimary
                  : AppConstants.dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AppConstants.emeraldPrimary
                  : AppConstants.textPrimary,
              fontSize: AppConstants.fontBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
