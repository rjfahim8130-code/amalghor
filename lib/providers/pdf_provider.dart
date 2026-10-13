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

/// The user's selections for one PDF generation run.
class PdfGenerationOptions {
  final int year;
  final ClusterGranularity granularity;
  final CalendarPrimary primaryCalendar;
  final MadhhabType madhhab;
  final bool showSafetyTimes;

  const PdfGenerationOptions({
    required this.year,
    required this.granularity,
    required this.primaryCalendar,
    required this.madhhab,
    required this.showSafetyTimes,
  });

  PdfGenerationOptions copyWith({
    int? year,
    ClusterGranularity? granularity,
    CalendarPrimary? primaryCalendar,
    MadhhabType? madhhab,
    bool? showSafetyTimes,
  }) {
    return PdfGenerationOptions(
      year: year ?? this.year,
      granularity: granularity ?? this.granularity,
      primaryCalendar: primaryCalendar ?? this.primaryCalendar,
      madhhab: madhhab ?? this.madhhab,
      showSafetyTimes: showSafetyTimes ?? this.showSafetyTimes,
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
          other.showSafetyTimes == showSafetyTimes;

  @override
  int get hashCode => Object.hash(
        year,
        granularity,
        primaryCalendar,
        madhhab,
        showSafetyTimes,
      );
}

/// Default options derived from current settings.
class PdfOptionsNotifier extends StateNotifier<PdfGenerationOptions> {
  final Ref _ref;

  PdfOptionsNotifier(this._ref)
      : super(
          PdfGenerationOptions(
            year: DateTime.now().year,
            granularity: ClusterGranularity.thirtySec,
            primaryCalendar:
                _ref.read(settingsProvider).calendarPrimary,
            madhhab: _ref.read(settingsProvider).madhhab,
            showSafetyTimes: true,
          ),
        );

  void setYear(int year) => state = state.copyWith(year: year);
  void setGranularity(ClusterGranularity g) =>
      state = state.copyWith(granularity: g);
  void setPrimaryCalendar(CalendarPrimary c) =>
      state = state.copyWith(primaryCalendar: c);
  void setMadhhab(MadhhabType m) => state = state.copyWith(madhhab: m);
  void setShowSafetyTimes(bool v) =>
      state = state.copyWith(showSafetyTimes: v);
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

/// Notifier that runs the full PDF build pipeline:
///   1. Fetch year of prayer times (cached or calculated)
///   2. Build clusters at the chosen granularity
///   3. Load fonts
///   4. Render the PDF
class PdfGeneratorNotifier extends StateNotifier<PdfProgress> {
  // The ref is retained for future use (e.g., invalidating caches).
  // ignore: unused_field
  final Ref _ref;
  final AdhanService _adhan = const AdhanService();

  PdfGeneratorNotifier(this._ref) : super(const PdfProgress());

  Future<void> generate() async {
    state = const PdfProgress(
      isGenerating: true,
      stage: 'Preparing...',
      progress: 0.0,
    );

    try {
      final options = _ref.read(pdfOptionsProvider);
      final loc = _ref.read(currentLocationProvider);

      // Step 1: Fetch or compute the year of prayer times.
      state = state.copyWith(
        stage: 'Computing prayer times...',
        progress: 0.1,
      );

      final times = _adhan.calculateYear(
        latitude: loc.latitude,
        longitude: loc.longitude,
        year: options.year,
        madhhab: options.madhhab,
        method: _ref.read(settingsProvider).calcMethod,
      );

      // Step 2: Build clusters.
      state = state.copyWith(
        stage: 'Building clusters...',
        progress: 0.4,
      );

      final result = buildClusters(
        year: options.year,
        latitude: loc.latitude,
        longitude: loc.longitude,
        granularity: options.granularity,
        yearTimes: times,
      );

      // Step 3: Load fonts.
      state = state.copyWith(
        stage: 'Loading fonts...',
        progress: 0.55,
      );
      final fonts = await PdfFonts.load();

      // Step 4: Render.
      state = state.copyWith(
        stage: 'Rendering PDF...',
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
        ),
      );

      final bytes = await builder.build(result);

      state = state.copyWith(
        isGenerating: false,
        stage: 'Complete',
        progress: 1.0,
        bytes: bytes,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        stage: 'Failed',
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

/// Provider exposing the current year's daily prayer list for PDF size
/// estimation on the settings screen.
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
