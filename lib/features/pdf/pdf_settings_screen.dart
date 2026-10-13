import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/settings_model.dart';
import '../../providers/pdf_provider.dart';
import 'pdf_cluster.dart';

/// Configuration screen for PDF generation.
class PdfSettingsScreen extends ConsumerWidget {
  const PdfSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opts = ref.watch(pdfOptionsProvider);
    final notifier = ref.read(pdfOptionsProvider.notifier);
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(title: const Text('PDF Calendar')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceLg),
        children: [
          const _SectionHeader('Year'),
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

          const _SectionHeader('Calendar Mode'),
          for (final g in ClusterGranularity.values)
            _RadioTile<ClusterGranularity>(
              title: g.label,
              value: g,
              group: opts.granularity,
              onChanged: notifier.setGranularity,
            ),

          const SizedBox(height: AppConstants.spaceLg),

          const _SectionHeader('Primary Calendar'),
          _RadioTile<CalendarPrimary>(
            title: 'ইংরেজি (English)',
            value: CalendarPrimary.english,
            group: opts.primaryCalendar,
            onChanged: notifier.setPrimaryCalendar,
          ),
          _RadioTile<CalendarPrimary>(
            title: 'বাংলা (Bangla)',
            value: CalendarPrimary.bangla,
            group: opts.primaryCalendar,
            onChanged: notifier.setPrimaryCalendar,
          ),
          _RadioTile<CalendarPrimary>(
            title: 'হিজরি (Hijri)',
            value: CalendarPrimary.hijri,
            group: opts.primaryCalendar,
            onChanged: notifier.setPrimaryCalendar,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          const _SectionHeader('Madhhab'),
          _RadioTile<MadhhabType>(
            title: 'হানাফী (Hanafi — with Isha Mustahab)',
            value: MadhhabType.hanafi,
            group: opts.madhhab,
            onChanged: notifier.setMadhhab,
          ),
          _RadioTile<MadhhabType>(
            title: 'শাফেঈ / মালিকি / হাম্বলি',
            value: MadhhabType.shafii,
            group: opts.madhhab,
            onChanged: notifier.setMadhhab,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          const _SectionHeader('Safety Times'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceSm,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Show safety times\n'
                    '(Sehri −7 min, Iftar +3 min)',
                    style: TextStyle(
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

          const SizedBox(height: AppConstants.spaceXl),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
            ),
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/pdf/preview'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Generate PDF'),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }
}

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
