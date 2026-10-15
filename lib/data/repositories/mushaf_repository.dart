import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mushaf_models.dart';

class MushafRepository {
  MushafRepository._();
  static final MushafRepository instance = MushafRepository._();

  static const _keyLastPage = 'mushaf_last_page';

  MushafConfig? _config;

  Future<MushafConfig> load() async {
    if (_config != null) return _config!;
    final raw = await rootBundle.loadString('assets/data/quran_pages.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _config = MushafConfig.fromJson(json);
    return _config!;
  }

  MushafConfig? get config => _config;

  Future<int> loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_keyLastPage);
    final cfg = _config;
    if (cfg == null) return saved ?? 502;
    if (saved == null) return cfg.firstPage;
    return saved.clamp(cfg.firstPage, cfg.lastPage);
  }

  Future<void> saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastPage, page);
  }
}
