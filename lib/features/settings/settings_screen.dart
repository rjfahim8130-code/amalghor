import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../data/models/settings_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/location_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/settings_provider.dart';

/// Settings screen — auto-adapts to dark or light mode.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final location = ref.watch(currentLocationProvider);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spaceLg,
        ),
        children: [
          // ─── Location ─────────────────────────
          _SectionHeader(title: l10n.settingsLocation),
          _NavigationTile(
            icon: Icons.location_on_outlined,
            title: location.shortLabel,
            subtitle:
                '${location.latitude.toStringAsFixed(4)}°, '
                '${location.longitude.toStringAsFixed(4)}°',
            onTap: () => context.push(Routes.location),
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
          const _NotificationPermissionBanner(),
          _SwitchTile(
            title: l10n.notificationFajr,
            value: settings.notifFajr,
            onChanged: (v) async {
              await notifier.setNotifFajr(v);
              ref.read(notificationProvider.notifier).reschedule();
            },
          ),
          _SwitchTile(
            title: l10n.notificationDhuhr,
            value: settings.notifDhuhr,
            onChanged: (v) async {
              await notifier.setNotifDhuhr(v);
              ref.read(notificationProvider.notifier).reschedule();
            },
          ),
          _SwitchTile(
            title: l10n.notificationAsr,
            value: settings.notifAsr,
            onChanged: (v) async {
              await notifier.setNotifAsr(v);
              ref.read(notificationProvider.notifier).reschedule();
            },
          ),
          _SwitchTile(
            title: l10n.notificationMaghrib,
            value: settings.notifMaghrib,
            onChanged: (v) async {
              await notifier.setNotifMaghrib(v);
              ref.read(notificationProvider.notifier).reschedule();
            },
          ),
          _SwitchTile(
            title: l10n.notificationIsha,
            value: settings.notifIsha,
            onChanged: (v) async {
              await notifier.setNotifIsha(v);
              ref.read(notificationProvider.notifier).reschedule();
            },
          ),
          _SwitchTile(
            title: l10n.notificationSehri,
            value: settings.notifSehri,
            onChanged: (v) async {
              await notifier.setNotifSehri(v);
              ref.read(notificationProvider.notifier).reschedule();
            },
          ),
          _SwitchTile(
            title: l10n.notificationIftar,
            value: settings.notifIftar,
            onChanged: (v) async {
              await notifier.setNotifIftar(v);
              ref.read(notificationProvider.notifier).reschedule();
            },
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
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppConstants.fontBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Offline-first. No servers. No accounts.',
                  style: TextStyle(
                    color: colors.textMuted,
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
// PERMISSION BANNER
// ─────────────────────────────────────────────

class _NotificationPermissionBanner extends ConsumerWidget {
  const _NotificationPermissionBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final status = ref.watch(notificationProvider);

    if (status == NotificationPermissionStatus.granted) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceSm,
        AppConstants.spaceLg,
        AppConstants.spaceMd,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          onTap: () async {
            final granted = await ref
                .read(notificationProvider.notifier)
                .requestPermission();
            if (granted) {
              await ref.read(notificationProvider.notifier).reschedule();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: colors.gold.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: colors.gold,
                  size: 22,
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable Notifications',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: AppConstants.fontBody,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to allow prayer time alerts',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: AppConstants.fontCaption,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colors.gold,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
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
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceSm,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colors.emerald,
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
    final colors = AppColors.of(context);
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
              color: selected ? colors.emerald : colors.textFaint,
              size: 20,
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color:
                      selected ? colors.textPrimary : colors.textMuted,
                  fontSize: AppConstants.fontBody,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
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
    final colors = AppColors.of(context);
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
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: AppConstants.fontBody,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceSm,
      ),
      child: Material(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(color: colors.border, width: 1.0),
            ),
            child: Row(
              children: [
                Icon(icon, color: colors.emerald, size: 22),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: AppConstants.fontBody,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: AppConstants.fontCaption,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
