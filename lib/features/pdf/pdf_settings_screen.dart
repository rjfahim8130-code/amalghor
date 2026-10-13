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
    final isHanafi = opts.madhhab == MadhhabType.hanafi;

    return Scaffold(
      appBar: AppBar(title: const Text('PDF ক্যালেন্ডার')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceLg),
        children: [
          // ─── Year ─────────────────────────────
          const _SectionHeader('বছর'),
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
          const _SectionHeader('ক্যালেন্ডার মোড'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceSm,
            ),
            child: const Text(
              'প্রতিদিন আলাদা — সবচেয়ে সঠিক\n'
              'গ্যাপ মোড — একই সময়ের দিনগুলো একসাথে দেখাবে (ছোট PDF)',
              style: TextStyle(
                color: AppConstants.textMuted,
                fontSize: AppConstants.fontCaption,
                height: 1.5,
              ),
            ),
          ),
          for (final g in ClusterGranularity.values)
            _RadioTile<ClusterGranularity>(
              title: g.label,
              value: g,
              group: opts.granularity,
              onChanged: notifier.setGranularity,
            ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Primary calendar ────────────────
          const _SectionHeader('প্রধান ক্যালেন্ডার (বড় হবে)'),
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

          // ─── Madhhab ─────────────────────────
          const _SectionHeader('মাযহাব'),
          _RadioTile<MadhhabType>(
            title: 'হানাফী',
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

          // ─── Safety times ────────────────────
          const _SectionHeader('সতর্কতা সময়'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceSm,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'সেহরি ৭ মিনিট আগে, ইফতার ৩ মিনিট পরে',
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

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Column selection ────────────────
          const _SectionHeader('কলাম নির্বাচন'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${opts.columns.length}টি কলাম নির্বাচিত',
                    style: const TextStyle(
                      color: AppConstants.textMuted,
                      fontSize: AppConstants.fontCaption,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      notifier.selectAllColumns(isHanafi: isHanafi),
                  child: const Text('সব'),
                ),
                TextButton(
                  onPressed: notifier.clearColumns,
                  child: const Text('বন্ধ'),
                ),
              ],
            ),
          ),
          for (final c in PdfColumn.values)
            if (!c.requiresHanafi || isHanafi)
              _CheckTile(
                title: c.label,
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('অন্তত একটি কলাম নির্বাচন করুন'),
                      ),
                    );
                    return;
                  }
                  context.push('/pdf/preview');
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('PDF তৈরি করুন'),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
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
