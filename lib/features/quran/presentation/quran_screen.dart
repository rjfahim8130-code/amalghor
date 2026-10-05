import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amalghor/core/services/app_settings_service.dart';
import 'package:amalghor/core/theme/app_theme.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  // Basic Surah list (will be replaced with full data later)
  static const List<Map<String, dynamic>> surahs = [
    {'number': 1, 'nameAr': 'الفاتحة', 'nameBn': 'আল-ফাতিহা', 'nameEn': 'Al-Fatiha', 'ayahs': 7},
    {'number': 2, 'nameAr': 'البقرة', 'nameBn': 'আল-বাকারা', 'nameEn': 'Al-Baqarah', 'ayahs': 286},
    {'number': 3, 'nameAr': 'آل عمران', 'nameBn': 'আলে ইমরান', 'nameEn': 'Ali Imran', 'ayahs': 200},
    {'number': 4, 'nameAr': 'النساء', 'nameBn': 'আন-নিসা', 'nameEn': 'An-Nisa', 'ayahs': 176},
    {'number': 5, 'nameAr': 'المائدة', 'nameBn': 'আল-মায়েদা', 'nameEn': 'Al-Maidah', 'ayahs': 120},
    {'number': 6, 'nameAr': 'الأنعام', 'nameBn': 'আল-আনআম', 'nameEn': 'Al-Anam', 'ayahs': 165},
    {'number': 7, 'nameAr': 'الأعراف', 'nameBn': 'আল-আরাফ', 'nameEn': 'Al-Araf', 'ayahs': 206},
    {'number': 8, 'nameAr': 'الأنفال', 'nameBn': 'আল-আনফাল', 'nameEn': 'Al-Anfal', 'ayahs': 75},
    {'number': 9, 'nameAr': 'التوبة', 'nameBn': 'আত-তাওবা', 'nameEn': 'At-Tawbah', 'ayahs': 129},
    {'number': 10, 'nameAr': 'يونس', 'nameBn': 'ইউনুস', 'nameEn': 'Yunus', 'ayahs': 109},
    // ... more will be added from full JSON later
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsService>();
    final isBn = settings.isBangla;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isBn ? 'কুরআন মাজীদ' : 'Holy Quran'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final s = surahs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    isBn
                        ? BanglaNumber(s['number'])
                        : '${s['number']}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              title: Text(
                isBn ? s['nameBn'] : s['nameEn'],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                s['nameAr'],
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Amiri',
                  fontSize: 16,
                ),
                textDirection: TextDirection.rtl,
              ),
              trailing: Text(
                isBn
                    ? '${BanglaNumber(s['ayahs'])} আয়াত'
                    : '${s['ayahs']} Ayahs',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                // TODO: Open Surah detail
              },
            ),
          );
        },
      ),
    );
  }
}

String BanglaNumber(int n) {
  const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return n.toString().split('').map((d) => digits[int.parse(d)]).join();
}
