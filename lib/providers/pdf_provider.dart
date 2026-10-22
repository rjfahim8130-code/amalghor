import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
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

class PdfGeneratorNotifier extends StateNotifier<PdfProgress> {
  // ignore: unused_field
  final Ref _ref;
  final AdhanService _adhan = const AdhanService();

  PdfGeneratorNotifier(this._ref) : super(const PdfProgress());

  /// Stage messages are localized at build time inside the UI using the
  /// `stage` key (e.g. `pdfPreparing`, `pdfCalculating`) so the provider
  /// does not need BuildContext.
  ///
  /// We store stable stage *keys* here; the UI maps them via l10n keys.
  Future<void> generate() async {
    state = const PdfProgress(
      isGenerating: true,
      stage: 'pdfPreparing',
      progress: 0.0,
    );

    try {
      final options = _ref.read(pdfOptionsProvider);
      final loc = _ref.read(currentLocationProvider);
      final settings = _ref.read(settingsProvider);

      state = state.copyWith(
        stage: 'pdfCalculating',
        progress: 0.1,
      );

      final times = _adhan.calculateYear(
        latitude: loc.latitude,
        longitude: loc.longitude,
        year: options.year,
        madhhab: options.madhhab,
        method: settings.calcMethod,
      );

      state = state.copyWith(
        stage: 'pdfGrouping',
        progress: 0.4,
      );

      final result = buildClusters(
        year: options.year,
        latitude: loc.latitude,
        longitude: loc.longitude,
        granularity: options.granularity,
        yearTimes: times,
        columns: options.columns,
      );

      state = state.copyWith(
        stage: 'pdfLoadingFonts',
        progress: 0.55,
      );
      final fonts = await PdfFonts.load();

      state = state.copyWith(
        stage: 'pdfBuilding',
        progress: 0.7,
      );

      // PDF content is always English (Bangla glyphs break in many PDF viewers).
      // Settings UI stays localized via AppLocalizations.
      const appName = 'AmalGhor';
      const tagline = 'Prayer timetable';

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
          appName: appName,
          appTagline: tagline,
          locale: 'en', // force English inside PDF
        ),
      );

      final bytes = await builder.build(result);

      state = state.copyWith(
        isGenerating: false,
        stage: 'pdfComplete',
        progress: 1.0,
        bytes: bytes,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        stage: 'pdfFailedStage',
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
