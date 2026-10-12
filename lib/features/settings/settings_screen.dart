import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/router.dart';
import '../../data/models/settings_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/location_provider.dart';
import '../../providers/settings_provider.dart';

/// Settings screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final location = ref.watch(currentLocationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spaceLg,
        ),
        children: [
          // ─── Location ─────────────────────────
          _SectionHeader(title: l10n.settingsLocation),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceSm,
            ),
            child: Material(
              color: AppConstants.surfaceDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: InkWell(
                onTap: () => context.push(Routes.location),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(
                      color: AppConstants.emeraldPrimary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppConstants.emeraldPrimary,
                        size: 22,
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.shortLabel,
                              style: const TextStyle(
                                color: AppConstants.textPrimary,
                                fontSize: AppConstants.fontBody,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${location.latitude.toStringAsFixed(4)}°, '
                              '${location.longitude.toStringAsFixed(4)}°',
                              style: const TextStyle(
                                color: AppConstants.textMuted,
                                fontSize: AppConstants.fontCaption,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppConstants.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Language ─────────────────────────
          _SectionHeader(title: l10n.settingsLanguage),
          _RadioTile<Locale>(
            title: l10n.languageEnglish,
            value: const Locale('en'),
            group: settings.locale,
            onChanged: notifier.setLocale,
          ),
          _RadioTile<Locale>(
            title: l10n.languageBangla,
            value: const Locale('bn'),
            group: settings.locale,
            onChanged: notifier.setLocale,
          ),
          _RadioTile<Locale>(
            title: l10n.languageArabic,
            value: const Locale('ar'),
            group: settings.locale,
            onChanged: notifier.setLocale,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Appearance ───────────────────────
          _SectionHeader(title: l10n.settingsAppearance),
          _RadioTile<ThemeMode>(
            title: l10n.themeDark,
            value: ThemeMode.dark,
            group: settings.themeMode,
            onChanged: notifier.setThemeMode,
          ),
          _RadioTile<ThemeMode>(
            title: l10n.themeLight,
            value: ThemeMode.light,
            group: settings.themeMode,
            onChanged: notifier.setThemeMode,
          ),
          _RadioTile<ThemeMode>(
            title: l10n.themeSystem,
            value: ThemeMode.system,
            group: settings.themeMode,
            onChanged: notifier.setThemeMode,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Madhhab ──────────────────────────
          _SectionHeader(title: l10n.madhhab),
          _RadioTile<MadhhabType>(
            title: l10n.madhhabHanafi,
            value: MadhhabType.hanafi,
            group: settings.madhhab,
            onChanged: notifier.setMadhhab,
          ),
          _RadioTile<MadhhabType>(
            title: l10n.madhhabShafii,
            value: MadhhabType.shafii,
            group: settings.madhhab,
            onChanged: notifier.setMadhhab,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Calculation method ───────────────
          _SectionHeader(title: l10n.calculationMethod),
          _RadioTile<CalcMethodType>(
            title: l10n.methodKarachi,
            value: CalcMethodType.karachi,
            group: settings.calcMethod,
            onChanged: notifier.setCalcMethod,
          ),
          _RadioTile<CalcMethodType>(
            title: l10n.methodMWL,
            value: CalcMethodType.mwl,
            group: settings.calcMethod,
            onChanged: notifier.setCalcMethod,
          ),
          _RadioTile<CalcMethodType>(
            title: l10n.methodUmmAlQura,
            value: CalcMethodType.ummAlQura,
            group: settings.calcMethod,
            onChanged: notifier.setCalcMethod,
          ),
          _RadioTile<CalcMethodType>(
            title: l10n.methodEgyptian,
            value: CalcMethodType.egyptian,
            group: settings.calcMethod,
            onChanged: notifier.setCalcMethod,
          ),
          _RadioTile<CalcMethodType>(
            title: l10n.methodISNA,
            value: CalcMethodType.isna,
            group: settings.calcMethod,
            onChanged: notifier.setCalcMethod,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Primary calendar ─────────────────
          _SectionHeader(title: l10n.settingsCalendar),
          _RadioTile<CalendarPrimary>(
            title: l10n.calendarEnglish,
            value: CalendarPrimary.english,
            group: settings.calendarPrimary,
            onChanged: notifier.setCalendarPrimary,
          ),
          _RadioTile<CalendarPrimary>(
            title: l10n.calendarBangla,
            value: CalendarPrimary.bangla,
            group: settings.calendarPrimary,
            onChanged: notifier.setCalendarPrimary,
          ),
          _RadioTile<CalendarPrimary>(
            title: l10n.calendarHijri,
            value: CalendarPrimary.hijri,
            group: settings.calendarPrimary,
            onChanged: notifier.setCalendarPrimary,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── Notifications ────────────────────
          _SectionHeader(title: l10n.settingsNotifications),
          _SwitchTile(
            title: l10n.notificationFajr,
            value: settings.notifFajr,
            onChanged: notifier.setNotifFajr,
          ),
          _SwitchTile(
            title: l10n.notificationDhuhr,
            value: settings.notifDhuhr,
            onChanged: notifier.setNotifDhuhr,
          ),
          _SwitchTile(
            title: l10n.notificationAsr,
            value: settings.notifAsr,
            onChanged: notifier.setNotifAsr,
          ),
          _SwitchTile(
            title: l10n.notificationMaghrib,
            value: settings.notifMaghrib,
            onChanged: notifier.setNotifMaghrib,
          ),
          _SwitchTile(
            title: l10n.notificationIsha,
            value: settings.notifIsha,
            onChanged: notifier.setNotifIsha,
          ),
          _SwitchTile(
            title: l10n.notificationSehri,
            value: settings.notifSehri,
            onChanged: notifier.setNotifSehri,
          ),
          _SwitchTile(
            title: l10n.notificationIftar,
            value: settings.notifIftar,
            onChanged: notifier.setNotifIftar,
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // ─── About ────────────────────────────
          _SectionHeader(title: l10n.settingsAbout),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppConstants.appName} v${AppConstants.appVersion}',
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: AppConstants.fontBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Offline-first. No servers. No accounts.',
                  style: TextStyle(
                    color: AppConstants.textMuted,
                    fontSize: AppConstants.fontCaption,
                  ),
                ),
              ],
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

  const _SectionHeader({required this.title});

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

class _SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: AppConstants.fontBody,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
