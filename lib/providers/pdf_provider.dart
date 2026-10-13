import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/prayer_times.dart';
import '../data/models/settings_model.dart';
import '../features/pdf/pdf_builder.dart';
import '../features/pdf/pdf_cluster.dart';
import '../features/pdf/pdf_fonts.dart';
import '../services/adhan_service.dart';
import 'location_provider.dart';
import 'settings_provider.dart';

class PdfGenerationOptions {
  final int year;
  final ClusterGranularity granularity;
  final CalendarPrimary primaryCalendar;
  final MadhhabType madhhab;
  final bool showSafetyTimes;
  final Set<PdfColumn> columns;

  const PdfGenerationOptions({
    required this.year
