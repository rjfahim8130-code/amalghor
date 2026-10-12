import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/clock_provider.dart';

/// A 3-column strip showing the current date in all three calendars
/// side-by-side. Useful as a top-level glance indicator.
class TriCalendarRow extends ConsumerWidget {
  const TriCalendarRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final asyncNow = ref.watch(clockProvider);
    final now = asyncNow.value ?? DateTime.now();
    final tri = AppDateUtils.buildTriCalendar(now, localeCode);

    return Row(
      children: [
        Expanded(
          child: _CalendarChip(
            label: l10n.dateGregorian,
            value: tri.gregorianFormatted,
            icon: Icons.calendar_month_outlined,
            accent: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: _CalendarChip(
            label: l10n.dateBangla,
            value: tri.banglaFormatted,
            icon: Icons.wb_sunny_outlined,
            accent: AppConstants.goldAccent,
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: _CalendarChip(
            label: l10n.dateHijri,
            value: tri.hijriFormatted,
            icon: Icons.nightlight_round,
            accent: AppConstants.emeraldPrimary,
          ),
        ),
      ],
    );
  }
}

class _CalendarChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _CalendarChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 14),
              const SizedBox(width: AppConstants.spaceXs),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppConstants.textMuted,
                    fontSize: AppConstants.fontMicro,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            value,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontCaption,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
