import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/mushaf_models.dart';

class MushafRepository {
  MushafRepository._();
  static final MushafRepository instance = MushafRepository._();

  MushafConfig? _config;

  Future<MushafConfig> load() async {
    if (_config != null) return _config!;
    final raw = await rootBundle.loadString('assets/data/quran_pages.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _config = MushafConfig.fromJson(json);
    return _config!;
  }

  MushafConfig? get config => _config;
}
