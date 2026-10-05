import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amalghor/core/constants/app_constants.dart';
import 'package:amalghor/core/services/app_settings_service.dart';
import 'package:amalghor/core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsService>();
    final isBn = settings.isBangla;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isBn ? 'সেটিংস' : 'Settings'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(isBn ? 'ভাষা' : 'Language'),
          _SettingTile(
            title: isBn ? 'বাংলা' : 'Bangla',
            trailing: Radio<AppLanguage>(
              value: AppLanguage.bangla,
              groupValue: settings.language,
              onChanged: (v) => settings.setLanguage(v!),
              activeColor: AppColors.primary,
            ),
            onTap: () => settings.setLanguage(AppLanguage.bangla),
          ),
          _SettingTile(
            title: 'English',
            trailing: Radio<AppLanguage>(
              value: AppLanguage.english,
              groupValue: settings.language,
              onChanged: (v) => settings.setLanguage(v!),
              activeColor: AppColors.primary,
            ),
            onTap: () => settings.setLanguage(AppLanguage.english),
          ),

          const SizedBox(height: 20),
          _SectionTitle(isBn ? 'মাজহাব' : 'Madhhab'),
          ...Madhhab.values.map((m) {
            final names = {
              Madhhab.hanafi: isBn ? 'হানাফী' : 'Hanafi',
              Madhhab.shafi: isBn ? 'শাফেয়ী' : "Shafi'i",
              Madhhab.maliki: isBn ? 'মালিকী' : 'Maliki',
              Madhhab.hanbali: isBn ? 'হাম্বলী' : 'Hanbali',
            };
            return _SettingTile(
              title: names[m]!,
              trailing: Radio<Madhhab>(
                value: m,
                groupValue: settings.madhhab,
                onChanged: (v) => settings.setMadhhab(v!),
                activeColor: AppColors.primary,
              ),
              onTap: () => settings.setMadhhab(m),
            );
          }),

          const SizedBox(height: 20),
          _SectionTitle(isBn ? 'প্রাইমারি ক্যালেন্ডার' : 'Primary Calendar'),
          ...PrimaryCalendar.values.map((c) {
            final names = {
              PrimaryCalendar.bangla: isBn ? 'বাংলা' : 'Bangla',
              PrimaryCalendar.english: isBn ? 'ইংরেজি' : 'English',
              PrimaryCalendar.hijri: isBn ? 'হিজরি' : 'Hijri',
            };
            return _SettingTile(
              title: names[c]!,
              trailing: Radio<PrimaryCalendar>(
                value: c,
                groupValue: settings.primaryCalendar,
                onChanged: (v) => settings.setPrimaryCalendar(v!),
                activeColor: AppColors.primary,
              ),
              onTap: () => settings.setPrimaryCalendar(c),
            );
          }),

          const SizedBox(height: 20),
          _SectionTitle(isBn ? 'লোকেশন' : 'Location'),
          _SettingTile(
            title: settings.locationName,
            subtitle: '${settings.latitude.toStringAsFixed(4)}, ${settings.longitude.toStringAsFixed(4)}',
            trailing: const Icon(Icons.my_location, color: AppColors.primary),
            onTap: () async {
              await settings.refreshLocationFromGps();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBn ? 'লোকেশন আপডেট হয়েছে' : 'Location updated'),
                    backgroundColor: AppColors.cardElevated,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 20),
          _SectionTitle(isBn ? 'থিম' : 'Theme'),
          _SettingTile(
            title: isBn ? 'ডার্ক AMOLED' : 'Dark AMOLED',
            trailing: Radio<ThemeModeOption>(
              value: ThemeModeOption.dark,
              groupValue: settings.themeMode,
              onChanged: (v) => settings.setThemeMode(v!),
              activeColor: AppColors.primary,
            ),
            onTap: () => settings.setThemeMode(ThemeModeOption.dark),
          ),
          _SettingTile(
            title: isBn ? 'লাইট' : 'Light',
            trailing: Radio<ThemeModeOption>(
              value: ThemeModeOption.light,
              groupValue: settings.themeMode,
              onChanged: (v) => settings.setThemeMode(v!),
              activeColor: AppColors.primary,
            ),
            onTap: () => settings.setThemeMode(ThemeModeOption.light),
          ),

          const SizedBox(height: 30),
          Center(
            child: Text(
              'আমলঘর v1.0.0',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
