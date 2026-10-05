import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amalghor/core/services/app_settings_service.dart';
import 'package:amalghor/core/theme/app_theme.dart';
import 'package:amalghor/core/utils/bangla_date_utils.dart';
import 'package:amalghor/core/models/prayer_times_model.dart';
import 'package:amalghor/features/settings/presentation/settings_screen.dart';
import 'package:amalghor/features/pdf/presentation/pdf_generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
        context.read<AppSettingsService>().tick();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsService>();
    final isBn = settings.isBangla;
    final status = settings.currentStatus;
    final today = settings.todayPrayer;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  settings.locationName,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            settings.t('আমলঘর', 'Amalghor'),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        );
                      },
                      icon: const Icon(Icons.settings_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),

            // Live Clock + Dates
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1F1F1F)),
                  ),
                  child: Column(
                    children: [
                      // Live Time
                      Text(
                        isBn
                            ? BanglaDateUtils.toBanglaNumberStr(
                                '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}')
                            : '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Three Dates
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _DateChip(
                            label: isBn ? 'বাংলা' : 'Bangla',
                            value: BanglaDateUtils.formatBanglaDate(_now, full: false),
                            isPrimary: settings.primaryCalendar == PrimaryCalendar.bangla,
                          ),
                          _DateChip(
                            label: isBn ? 'ইংরেজি' : 'English',
                            value: BanglaDateUtils.formatEnglishDate(_now).split(' ').take(2).join(' '),
                            isPrimary: settings.primaryCalendar == PrimaryCalendar.english,
                          ),
                          _DateChip(
                            label: isBn ? 'হিজরি' : 'Hijri',
                            value: BanglaDateUtils.formatHijriShort(_now),
                            isPrimary: settings.primaryCalendar == PrimaryCalendar.hijri,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Live Status Card
            if (status != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.accent.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                status.isPrayerTime
                                    ? Icons.mosque_rounded
                                    : Icons.wb_sunny_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBn ? status.statusBn : status.statusEn,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (status.isPrayerTime && status.currentEndTime != null)
                                    Text(
                                      isBn
                                          ? 'শেষ হতে বাকি: ${BanglaDateUtils.formatDuration(status.remaining, isBangla: true)}'
                                          : 'Ends in: ${BanglaDateUtils.formatDuration(status.remaining, isBangla: false)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                isBn ? 'পরবর্তী: ' : 'Next: ',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                isBn
                                    ? status.nextPrayer.bn
                                    : status.nextPrayer.en,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                BanglaDateUtils.formatTime(
                                    status.nextStartTime,
                                    isBangla: isBn),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Today's Prayer List
            if (today != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'আজকের সময়সূচি' : "Today's Schedule",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PrayerListCard(today: today, isBn: isBn, now: _now),
                    ],
                  ),
                ),
              ),

            // PDF Generator Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PdfGeneratorScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded,
                            color: Colors.black, size: 26),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            isBn
                                ? 'এক ক্লিকে পুরো বছরের PDF ক্যালেন্ডার'
                                : 'One-Click Full Year PDF Calendar',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick Shortcuts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'দ্রুত অ্যাক্সেস' : 'Quick Access',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                      children: [
                        _ShortcutItem(
                          icon: Icons.menu_book_rounded,
                          label: isBn ? 'কুরআন' : 'Quran',
                          color: const Color(0xFF26A69A),
                        ),
                        _ShortcutItem(
                          icon: Icons.check_circle_outline_rounded,
                          label: isBn ? 'আমল' : 'Amal',
                          color: const Color(0xFF66BB6A),
                        ),
                        _ShortcutItem(
                          icon: Icons.nightlight_round,
                          label: isBn ? 'রমজান' : 'Ramadan',
                          color: const Color(0xFF7E57C2),
                        ),
                        _ShortcutItem(
                          icon: Icons.calendar_month_rounded,
                          label: isBn ? 'ক্যালেন্ডার' : 'Calendar',
                          color: const Color(0xFF42A5F5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widgets

class _DateChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _DateChip({
    required this.label,
    required this.value,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isPrimary ? AppColors.primary : AppColors.textMuted,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isPrimary ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _PrayerListCard extends StatelessWidget {
  final PrayerTimesModel today;
  final bool isBn;
  final DateTime now;

  const _PrayerListCard({
    required this.today,
    required this.isBn,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (PrayerName.fajr, today.fajr),
      (PrayerName.sunrise, today.sunrise),
      (PrayerName.dhuhr, today.dhuhr),
      (PrayerName.asr, today.asr),
      (PrayerName.maghrib, today.maghrib),
      (PrayerName.isha, today.isha),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final name = entry.value.$1;
          final time = entry.value.$2;
          final isPast = now.isAfter(time);
          final isNext = !isPast &&
              (i == 0 || now.isAfter(items[i - 1].$2));

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: i < items.length - 1
                  ? const Border(
                      bottom: BorderSide(color: Color(0xFF1F1F1F)),
                    )
                  : null,
              color: isNext ? AppColors.primary.withOpacity(0.08) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPast
                        ? AppColors.textMuted
                        : isNext
                            ? AppColors.primary
                            : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isBn ? name.bn : name.en,
                    style: TextStyle(
                      fontSize: 15,
                      color: isPast
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                      fontWeight: isNext ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  BanglaDateUtils.formatTime(time, isBangla: isBn),
                  style: TextStyle(
                    fontSize: 15,
                    color: isPast
                        ? AppColors.textMuted
                        : isNext
                            ? AppColors.primary
                            : AppColors.textPrimary,
                    fontWeight: isNext ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ShortcutItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}



