import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A ticker that emits the current [DateTime] once per second.
///
/// Only widgets that genuinely need per-second updates (live clock,
/// countdown) should listen to this provider. Every other widget
/// should rely on coarser-grained providers to avoid rebuilding
/// the whole tree once per second.
final clockProvider = StreamProvider<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  Timer? timer;

  void emit() {
    if (!controller.isClosed) controller.add(DateTime.now());
  }

  // Emit immediately, then every second.
  emit();
  timer = Timer.periodic(const Duration(seconds: 1), (_) => emit());

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

/// A derived provider that gives the current date-only (day
/// resolution). Rebuilds at midnight.
final currentDateProvider = Provider<DateTime>((ref) {
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// A derived provider giving the current time-of-day in seconds.
/// Useful to detect phase transitions without depending on the
/// stream directly.
final currentSecondProvider = Provider<int>((ref) {
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  return now.hour * 3600 + now.minute * 60 + now.second;
});
