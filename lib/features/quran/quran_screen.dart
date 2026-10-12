import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/models/quran_models.dart';
import '../../l10n/generated/app_localizations.dart';

/// Quran module — phase 1 shows the Surah list from a static catalogue.
/// Tapping a Surah navigates to a reader screen (to be added later).
class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quranTitle),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceLg,
        ),
        itemCount: SurahCatalogue.surahs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final s = SurahCatalogue.surahs[i];
          return _SurahTile(surah: s, localeCode: localeCode);
        },
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final Surah surah;
  final String localeCode;

  const _SurahTile({required this.surah, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () {
        // TODO: navigate to reader
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spaceMd,
        ),
        child: Row(
          children: [
            // Number diamond
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppConstants.surfaceDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.35),
                ),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: const TextStyle(
                    color: AppConstants.emeraldPrimary,
                    fontSize: AppConstants.fontBody,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spaceMd),

            // Name column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameFor(localeCode),
                    style: const TextStyle(
                      color: AppConstants.textPrimary,
                      fontSize: AppConstants.fontSubtitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        surah.nameTransliteration,
                        style: const TextStyle(
                          color: AppConstants.textMuted,
                          fontSize: AppConstants.fontCaption,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppConstants.textFaint,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      Text(
                        surah.isMakki ? l10n.quranMakki : l10n.quranMadani,
                        style: const TextStyle(
                          color: AppConstants.textFaint,
                          fontSize: AppConstants.fontMicro,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arabic name
            Text(
              surah.nameArabic,
              style: const TextStyle(
                color: AppConstants.goldAccent,
                fontSize: AppConstants.fontSubtitle,
                fontFamily: 'NotoNaskhArabic',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static catalogue of the 114 Surahs. Populated at build time so
/// that the list screen works fully offline.
class SurahCatalogue {
  SurahCatalogue._();

  static const List<Surah> surahs = [
    Surah(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'The Opening',
      nameBangla: 'সূচনা',
      nameTransliteration: 'Al-Fatihah',
      totalAyahs: 7,
      revelationPlace: 'makkah',
    ),
    Surah(
      number: 2,
      nameArabic: 'البقرة',
      nameEnglish: 'The Cow',
      nameBangla: 'গাভী',
      nameTransliteration: 'Al-Baqarah',
      totalAyahs: 286,
      revelationPlace: 'madinah',
    ),
    Surah(
      number: 3,
      nameArabic: 'آل عمران',
      nameEnglish: 'Family of Imran',
      nameBangla: 'ইমরানের পরিবার',
      nameTransliteration: 'Ali Imran',
      totalAyahs: 200,
      revelationPlace: 'madinah',
    ),
    Surah(
      number: 4,
      nameArabic: 'النساء',
      nameEnglish: 'The Women',
      nameBangla: 'নারী',
      nameTransliteration: 'An-Nisa',
      totalAyahs: 176,
      revelationPlace: 'madinah',
    ),
    Surah(
      number: 5,
      nameArabic: 'المائدة',
      nameEnglish: 'The Table',
      nameBangla: 'খাদ্য পরিবেশিত টেবিল',
      nameTransliteration: 'Al-Maidah',
      totalAyahs: 120,
      revelationPlace: 'madinah',
    ),
    Surah(
      number: 6,
      nameArabic: 'الأنعام',
      nameEnglish: 'The Cattle',
      nameBangla: 'গবাদি পশু',
      nameTransliteration: 'Al-Anam',
      totalAyahs: 165,
      revelationPlace: 'makkah',
    ),
    Surah(
      number: 7,
      nameArabic: 'الأعراف',
      nameEnglish: 'The Heights',
      nameBangla: 'উঁচু স্থান',
      nameTransliteration: 'Al-Araf',
      totalAyahs: 206,
      revelationPlace: 'makkah',
    ),
    Surah(
      number: 8,
      nameArabic: 'الأنفال',
      nameEnglish: 'The Spoils of War',
      nameBangla: 'যুদ্ধলব্ধ সম্পদ',
      nameTransliteration: 'Al-Anfal',
      totalAyahs: 75,
      revelationPlace: 'madinah',
    ),
    Surah(
      number: 9,
      nameArabic: 'التوبة',
      nameEnglish: 'The Repentance',
      nameBangla: 'অনুশোচনা',
      nameTransliteration: 'At-Tawbah',
      totalAyahs: 129,
      revelationPlace: 'madinah',
    ),
    Surah(
      number: 10,
      nameArabic: 'يونس',
      nameEnglish: 'Jonah',
      nameBangla: 'ইউনুস',
      nameTransliteration: 'Yunus',
      totalAyahs: 109,
      revelationPlace: 'makkah',
    ),
    Surah(
      number: 36,
      nameArabic: 'يس',
      nameEnglish: 'Ya Sin',
      nameBangla: 'ইয়া সিন',
      nameTransliteration: 'Ya-Sin',
      totalAyahs: 83,
      revelationPlace: 'makkah',
    ),
    Surah(
      number: 55,
      nameArabic: 'الرحمن',
      nameEnglish: 'The Beneficent',
      nameBangla: 'পরম দয়াময়',
      nameTransliteration: 'Ar-Rahman',
      totalAyahs: 78,
      revelationPlace: 'madinah',
    ),
    Surah(
      number: 67,
      nameArabic: 'الملك',
      nameEnglish: 'The Sovereignty',
      nameBangla: 'সার্বভৌমত্ব',
      nameTransliteration: 'Al-Mulk',
      totalAyahs: 30,
      revelationPlace: 'makkah',
    ),
    Surah(
      number: 112,
      nameArabic: 'الإخلاص',
      nameEnglish: 'The Purity',
      nameBangla: 'একনিষ্ঠতা',
      nameTransliteration: 'Al-Ikhlas',
      totalAyahs: 4,
      revelationPlace: 'makkah',
    ),
    Surah(
      number: 113,
      nameArabic: 'الفلق',
      nameEnglish: 'The Dawn',
      nameBangla: 'প্রভাত',
      nameTransliteration: 'Al-Falaq',
      totalAyahs: 5,
      revelationPlace: 'makkah',
    ),
    Surah(
      number: 114,
      nameArabic: 'الناس',
      nameEnglish: 'Mankind',
      nameBangla: 'মানবজাতি',
      nameTransliteration: 'An-Nas',
      totalAyahs: 6,
      revelationPlace: 'makkah',
    ),
  ];
}
