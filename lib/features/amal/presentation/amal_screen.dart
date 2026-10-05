import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amalghor/core/services/app_settings_service.dart';
import 'package:amalghor/core/theme/app_theme.dart';

class AmalScreen extends StatefulWidget {
  const AmalScreen({super.key});

  @override
  State<AmalScreen> createState() => _AmalScreenState();
}

class _AmalScreenState extends State<AmalScreen> {
  final Map<String, bool> _amal = {
    'fajr': false,
    'dhuhr': false,
    'asr': false,
    'maghrib': false,
    'isha': false,
    'roza': false,
    'quran': false,
  };

  @override
  void initState() {
    super.initState();
    _loadAmal();
  }

  Future<void> _loadAmal() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final key = 'amal_${today.year}_${today.month}_${today.day}';
    final data = prefs.getStringList(key) ?? [];
    setState(() {
      for (final k in _amal.keys) {
        _amal[k] = data.contains(k);
      }
    });
  }

  Future<void> _toggle(String key) async {
    setState(() => _amal[key] = !(_amal[key] ?? false));
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final storageKey = 'amal_${today.year}_${today.month}_${today.day}';
    final done = _amal.entries.where((e) => e.value).map((e) => e.key).toList();
    await prefs.setStringList(storageKey, done);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsService>();
    final isBn = settings.isBangla;

    final items = [
      ('fajr', isBn ? 'ফজর' : 'Fajr', Icons.wb_twilight),
      ('dhuhr', isBn ? 'যোহর' : 'Dhuhr', Icons.light_mode),
      ('asr', isBn ? 'আসর' : 'Asr', Icons.wb_cloudy),
      ('maghrib', isBn ? 'মাগরিব' : 'Maghrib', Icons.nights_stay),
      ('isha', isBn ? 'এশা' : 'Isha', Icons.dark_mode),
      ('roza', isBn ? 'রোজা' : 'Fasting', Icons.restaurant_menu),
      ('quran', isBn ? 'কুরআন পড়া' : 'Quran Reading', Icons.menu_book),
    ];

    final completed = _amal.values.where((v) => v).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isBn ? 'আমল ট্র্যাকার' : 'Amal Tracker'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  '$completed / ${items.length}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isBn ? 'আজকের আমল সম্পন্ন' : "Today's Amal Completed",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...items.map((item) {
            final done = _amal[item.$1] ?? false;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: done
                    ? Border.all(color: AppColors.primary.withOpacity(0.5))
                    : null,
              ),
              child: ListTile(
                leading: Icon(
                  item.$3,
                  color: done ? AppColors.primary : AppColors.textMuted,
                ),
                title: Text(
                  item.$2,
                  style: TextStyle(
                    color: done ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: done ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: Checkbox(
                  value: done,
                  onChanged: (_) => _toggle(item.$1),
                  activeColor: AppColors.primary,
                  checkColor: Colors.black,
                ),
                onTap: () => _toggle(item.$1),
              ),
            );
          }),
        ],
      ),
    );
  }
}
