import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amalghor/core/services/app_settings_service.dart';
import 'package:amalghor/core/theme/app_theme.dart';
import 'package:amalghor/core/utils/bangla_date_utils.dart';
import 'package:amalghor/core/models/prayer_times_model.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsService>();
    final isBn = settings.isBangla;
    final today = settings.todayPrayer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isBn ? 'নামাজের সময়সূচি' : 'Prayer Times'),
        backgroundColor: AppColors.background,
      ),
      body: today == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(settings, isBn),
                const SizedBox(height: 20),
                _buildPrayerCard(today, isBn),
                const SizedBox(height: 20),
                if (today.solarNoon != null)
                  _buildInfoTile(
                    isBn ? 'মধ্য আকাশ (Solar Noon)' : 'Solar Noon',
                    BanglaDateUtils.formatTime(today.solarNoon!, isBangla: isBn),
                    Icons.wb_sunny_outlined,
                  ),
                if (today.suhoorEnd != null)
                  _buildInfoTile(
                    isBn ? 'সেহরি শেষ' : 'Suhoor Ends',
                    BanglaDateUtils.formatTime(today.suhoorEnd!, isBangla: isBn),
                    Icons.nightlight_round,
                  ),
                if (today.iftar != null)
                  _buildInfoTile(
                    isBn ? 'ইফতার' : 'Iftar',
                    BanglaDateUtils.formatTime(today.iftar!, isBangla: isBn),
                    Icons.restaurant_rounded,
                  ),
              ],
            ),
    );
  }

  Widget _buildHeader(AppSettingsService settings, bool isBn) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              settings.locationName,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            ),
          ),
          Text(
            isBn
                ? settings.madhhab.name == 'hanafi'
                    ? 'হানাফী'
                    : 'শাফেয়ী'
                : settings.madhhab.name.toUpperCase(),
            style: const TextStyle(color: AppColors.primary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(PrayerTimesModel today, bool isBn) {
    final items = [
      (PrayerName.fajr, today.fajr, Icons.wb_twilight),
      (PrayerName.sunrise, today.sunrise, Icons.wb_sunny),
      (PrayerName.dhuhr, today.dhuhr, Icons.light_mode),
      (PrayerName.asr, today.asr, Icons.wb_cloudy),
      (PrayerName.maghrib, today.maghrib, Icons.nights_stay),
      (PrayerName.isha, today.isha, Icons.dark_mode),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.map((item) {
          return ListTile(
            leading: Icon(item.$3, color: AppColors.primary),
            title: Text(
              isBn ? item.$1.bn : item.$1.en,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            trailing: Text(
              BanglaDateUtils.formatTime(item.$2, isBangla: isBn),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoTile(String title, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
