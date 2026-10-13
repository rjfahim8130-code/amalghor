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

/// User-selected options for one PDF generation run.
class PdfGenerationOptions {
  final int year;
  final ClusterGranularity granularity;
  final CalendarPrimary primaryCalendar;
  final MadhhabType madhhab;
  final bool showSafetyTimes;
  final Set<PdfColumn> columns;

  const PdfGenerationOptions({
    required this.year,
    required this.granularity,
    required this.primaryCalendar,
    required this.madhhab,
    required this.showSafetyTimes,
    required this.columns,
  });

  PdfGenerationOptions copyWith({
    int? year,
    ClusterGranularity? granularity,
    CalendarPrimary? primaryCalendar,
    MadhhabType? madhhab,
    bool? showSafetyTimes,
    Set<PdfColumn>? columns,
  }) {
    return PdfGenerationOptions(
      year: year ?? this.year,
      granularity: granularity ?? this.granularity,
      primaryCalendar: primaryCalendar ?? this.primaryCalendar,
      madhhab: madhhab ?? this.madhhab,
      showSafetyTimes: showSafetyTimes ?? this.showSafetyTimes,
      columns: columns ?? this.columns,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfGenerationOptions &&
          other.year == year &&
          other.granularity == granularity &&
          other.primaryCalendar == primaryCalendar &&
          other.madhhab == madhhab &&
          other.showSafetyTimes == showSafetyTimes &&
          _setEquals(other.columns, columns);

  @override
  int get hashCode => Object.hash(
        year,
        granularity,
        primaryCalendar,
        madhhab,
        showSafetyTimes,
        Object.hashAllUnordered(columns),
      );

  static bool _setEquals(Set<PdfColumn> a, Set<PdfColumn> b) {
    if (a.length != b.length) return false;
    for (final e in a) {
      if (!b.contains(e)) return false;
    }
    return true;
  }
}

/// Default options derived from current settings.
class PdfOptionsNotifier extends StateNotifier<PdfGenerationOptions> {
  final Ref _ref;

  PdfOptionsNotifier(this._ref)
      : super(
          PdfGenerationOptions(
            year: DateTime.now().year,
            granularity: ClusterGranularity.thirtySec,
            primaryCalendar: _ref.read(settingsProvider).calendarPrimary,
            madhhab: _ref.read(settingsProvider).madhhab,
            showSafetyTimes: true,
            columns: PdfColumnSelection.defaultSelection(
              isHanafi:
                  _ref.read(settingsProvider).madhhab == MadhhabType.hanafi,
            ).columns,
          ),
        );

  void setYear(int year) => state = state.copyWith(year: year);
  void setGranularity(ClusterGranularity g) =>
      state = state.copyWith(granularity: g);
  void setPrimaryCalendar(CalendarPrimary c) =>
      state = state.copyWith(primaryCalendar: c);
  void setShowSafetyTimes(bool v) =>
      state = state.copyWith(showSafetyTimes: v);

  void setMadhhab(MadhhabType m) {
    // Update the madhhab and, if switching to Shafi'i, drop the
    // Hanafi-only Isha Mustahab column.
    final newCols = Set<PdfColumn>.from(state.columns);
    if (m == MadhhabType.shafii) {
      newCols.remove(PdfColumn.ishaMustahab);
    } else {
      newCols.add(PdfColumn.ishaMustahab);
    }
    state = state.copyWith(madhhab: m, columns: newCols);
  }

  void toggleColumn(PdfColumn c) {
    final newCols = Set<PdfColumn>.from(state.columns);
    if (newCols.contains(c)) {
      newCols.remove(c);
    } else {
      newCols.add(c);
    }
    state = state.copyWith(columns: newCols);
  }

  void selectAllColumns({required bool isHanafi}) {
    state = state.copyWith(
      columns: PdfColumnSelection.defaultSelection(isHanafi: isHanafi).columns,
    );
  }

  void clearColumns() {
    state = state.copyWith(columns: {PdfColumn.date});
  }
}

final pdfOptionsProvider =
    StateNotifierProvider<PdfOptionsNotifier, PdfGenerationOptions>((ref) {
  return PdfOptionsNotifier(ref);
});

/// Progress state for PDF generation.
class PdfProgress {
  final bool isGenerating;
  final String stage;
  final double progress;
  final Uint8List? bytes;
  final String? error;

  const PdfProgress({
    this.isGenerating = false,
    this.stage = '',
    this.progress = 0.0,
    this.bytes,
    this.error,
  });

  PdfProgress copyWith({
    bool? isGenerating,
    String? stage,
    double? progress,
    Uint8List? bytes,
    String? error,
    bool clearBytes = false,
    bool clearError = false,
  }) {
    return PdfProgress(
      isGenerating: isGenerating ?? this.isGenerating,
      stage: stage ?? this.stage,
      progress: progress ?? this.progress,
      bytes: clearBytes ? null : (bytes ?? this.bytes),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier that runs the full PDF build pipeline.
class PdfGeneratorNotifier extends StateNotifier<PdfProgress> {
  // ignore: unused_field
  final Ref _ref;
  final AdhanService _adhan = const AdhanService();

  PdfGeneratorNotifier(this._ref) : super(const PdfProgress());

  Future<void> generate() async {
    state = const PdfProgress(
      isGenerating: true,
      stage: 'প্রস্তুতি নিচ্ছি...',
      progress: 0.0,
    );

    try {
      final options = _ref.read(pdfOptionsProvider);
      final loc = _ref.read(currentLocationProvider);

      state = state.copyWith(
        stage: 'নামাযের সময় হিসাব করছি...',
        progress: 0.1,
      );

      final times = _adhan.calculateYear(
        latitude: loc.latitude,
        longitude: loc.longitude,
        year: options.year,
        madhhab: options.madhhab,
        method: _ref.read(settingsProvider).calcMethod,
      );

      state = state.copyWith(
        stage: 'গ্রুপ তৈরি করছি...',
        progress: 0.4,
      );

      final result = buildClusters(
        year: options.year,
        latitude: loc.latitude,
        longitude: loc.longitude,
        granularity: options.granularity,
        yearTimes: times,
      );

      state = state.copyWith(
        stage: 'ফন্ট লোড করছি...',
        progress: 0.55,
      );
      final fonts = await PdfFonts.load();

      state = state.copyWith(
        stage: 'PDF তৈরি করছি...',
        progress: 0.7,
      );

      final builder = PdfBuilder(
        fonts: fonts,
        options: PdfOptions(
          primaryCalendar: options.primaryCalendar,
          madhhab: options.madhhab,
          showSafetyTimes: options.showSafetyTimes,
          locationName: loc.displayName,
          latitude: loc.latitude,
          longitude: loc.longitude,
          columns: options.columns,
          appName: 'আমলঘর',
          appTagline: 'নামাযের সময়সূচি',
        ),
      );

      final bytes = await builder.build(result);

      state = state.copyWith(
        isGenerating: false,
        stage: 'সম্পূর্ণ',
        progress: 1.0,
        bytes: bytes,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        stage: 'ব্যর্থ',
        progress: 0.0,
        error: e.toString(),
      );
    }
  }

  void reset() => state = const PdfProgress();
}

final pdfGeneratorProvider =
    StateNotifierProvider<PdfGeneratorNotifier, PdfProgress>((ref) {
  return PdfGeneratorNotifier(ref);
});

final pdfYearPreviewProvider =
    FutureProvider.family<List<PrayerTimes>, int>((ref, year) async {
  final loc = ref.watch(currentLocationProvider);
  final settings = ref.watch(settingsProvider);
  return const AdhanService().calculateYear(
    latitude: loc.latitude,
    longitude: loc.longitude,
    year: year,
    madhhab: settings.madhhab,
    method: settings.calcMethod,
  );
});
