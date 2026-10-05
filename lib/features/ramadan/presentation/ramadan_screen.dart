import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amalghor/core/services/app_settings_service.dart';
import 'package:amalghor/core/theme/app_theme.dart';
import 'package:amalghor/core/utils/bangla_date_utils.dart';

class RamadanScreen extends StatelessWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsService>();
    final isBn = settings.isBangla;
    final today = settings.todayPrayer;
    final now = DateTime.now();

    bool isSuhoorTime = false;
    bool isFasting = false;
    bool isIftarTime = false;
    Duration? remaining;

    if (today != null) {
      if (now.isBefore(today.fajr)) {
        isSuhoorTime = true;
        remaining = today.fajr.difference(now);
      } else if (now.isAfter(today.fajr) && now.isBefore(today.maghrib)) {
        isFasting = true;
        remaining = today.maghrib.difference(now);
      } else if (now.isAfter(today.maghrib) &&
          now.isBefore(today.maghrib.add(const Duration(minutes: 30)))) {
        isIftarTime = true;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isBn ? 'রমজান' : 'Ramadan'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7E57C2).withOpacity(0.2),
                  const Color(0xFF5E35B1).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF7E57C2).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  isSuhoorTime
                      ? Icons.nightlight_round
                      : isFasting
                          ? Icons.restaurant_menu_rounded
                          : isIftarTime
                              ? Icons.celebration_rounded
                              : Icons.mosque_rounded,
                  size: 48,
                  color: const Color(0xFFB39DDB),
                ),
                const SizedBox(height: 16),
                Text(
                  isSuhoorTime
                      ? (isBn ? 'সেহরি চলছে' : 'Suhoor Time')
                      : isFasting
                          ? (isBn ? 'আজ রোজা চলছে' : 'Fasting Ongoing')
                          : isIftarTime
                              ? (isBn ? 'ইফতারের সময় হয়েছে' : 'Iftar Time')
                              : (isBn ? 'রমজানের সময়সূচি' : 'Ramadan Schedule'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (remaining != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    isSuhoorTime
                        ? (isBn
                            ? 'সেহরি শেষ হতে বাকি: ${BanglaDateUtils.formatDuration(remaining, isBangla: true)}'
                            : 'Suhoor ends in: ${BanglaDateUtils.formatDuration(remaining, isBangla: false)}')
                        : (isBn
                            ? 'ইফতার হতে বাকি: ${BanglaDateUtils.formatDuration(remaining, isBangla: true)}'
                            : 'Iftar in: ${BanglaDateUtils.formatDuration(remaining, isBangla: false)}'),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFB39DDB),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (today != null) ...[
            _TimeRow(
              title: isBn ? 'সেহরি শেষ' : 'Suhoor Ends',
              time: BanglaDateUtils.formatTime(today.fajr, isBangla: isBn),
              icon: Icons.nightlight_round,
            ),
            _TimeRow(
              title: isBn ? 'ফজর' : 'Fajr',
              time: BanglaDateUtils.formatTime(today.fajr, isBangla: isBn),
              icon: Icons.wb_twilight,
            ),
            _TimeRow(
              title: isBn ? 'ইফতার / মাগরিব' : 'Iftar / Maghrib',
              time: BanglaDateUtils.formatTime(today.maghrib, isBangla: isBn),
              icon: Icons.restaurant_rounded,
            ),
            _TimeRow(
              title: isBn ? 'এশা' : 'Isha',
              time: BanglaDateUtils.formatTime(today.isha, isBangla: isBn),
              icon: Icons.dark_mode,
            ),
          ],

          const SizedBox(height: 24),
          Text(
            isBn
                ? 'রমজানের সম্পূর্ণ ক্যালেন্ডার শীঘ্রই আসছে ইনশাআল্লাহ'
                : 'Full Ramadan Calendar coming soon InshaAllah',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const _TimeRow({
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
