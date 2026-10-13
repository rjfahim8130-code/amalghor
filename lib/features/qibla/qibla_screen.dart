import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../providers/location_provider.dart';
import '../../providers/qibla_provider.dart';

/// Qibla compass screen.
///
/// Shows a compass rose that rotates with the device heading, with a
/// Kaaba marker at the calculated Qibla bearing.
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  StreamSubscription<CompassEvent>? _compassSub;
  double? _heading;

  @override
  void initState() {
    super.initState();
    _startCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  void _startCompass() {
    final events = FlutterCompass.events;
    if (events == null) return;
    _compassSub = events.listen((event) {
      if (!mounted) return;
      setState(() => _heading = event.heading);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(currentLocationProvider);
    final qibla = ref.watch(qiblaDirectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('কিবলা')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppConstants.spaceLg),

              // ─── Location & bearing info ────────
              _InfoCard(
                locationName: loc.displayName,
                bearing: qibla.bearing,
                distanceKm: qibla.distanceKm,
              ),

              const Spacer(),

              // ─── Compass ────────────────────────
              _CompassView(
                heading: _heading,
                qiblaBearing: qibla.bearing,
              ),

              const Spacer(),

              // ─── Hint ──────────────────────────
              const Padding(
                padding: EdgeInsets.only(bottom: AppConstants.spaceXl),
                child: Text(
                  'ফোনটি সমতল করে ধরুন, চারপাশের ধাতব বস্তু দূরে রাখুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppConstants.textMuted,
                    fontSize: AppConstants.fontCaption,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INFO CARD
// ─────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String locationName;
  final double bearing;
  final double distanceKm;

  const _InfoCard({
    required this.locationName,
    required this.bearing,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppConstants.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      child: Column(
        children: [
          Text(
            locationName,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontSubtitle,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Metric(
                label: 'কিবলা কোণ',
                value: '${bearing.toStringAsFixed(1)}°',
              ),
              Container(
                width: 1,
                height: 32,
                color: AppConstants.dividerColor,
              ),
              _Metric(
                label: 'মক্কার দূরত্ব',
                value: '${distanceKm.toStringAsFixed(0)} km',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppConstants.emeraldPrimary,
            fontSize: AppConstants.fontHeading,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppConstants.textMuted,
            fontSize: AppConstants.fontCaption,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// COMPASS
// ─────────────────────────────────────────────

class _CompassView extends StatelessWidget {
  final double? heading;
  final double qiblaBearing;

  const _CompassView({
    required this.heading,
    required this.qiblaBearing,
  });

  @override
  Widget build(BuildContext context) {
    if (heading == null) {
      return SizedBox(
        width: 280,
        height: 280,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.explore_off_outlined,
                color: AppConstants.textFaint,
                size: 48,
              ),
              const SizedBox(height: AppConstants.spaceMd),
              const Text(
                'কম্পাস সেন্সর নেই',
                style: TextStyle(
                  color: AppConstants.textMuted,
                  fontSize: AppConstants.fontBody,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Rotate the compass so North always points to actual North.
    // The dial rotation is -heading (device heading is clockwise).
    final dialRotation = -heading! * math.pi / 180.0;

    // Kaaba marker angle relative to device (in degrees, clockwise).
    final kaabaAngleDeg = (qiblaBearing - heading! + 360) % 360;
    final aligned = kaabaAngleDeg < 5 || kaabaAngleDeg > 355;

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ─── Compass dial ────────────────────
          Transform.rotate(
            angle: dialRotation,
            child: CustomPaint(
              size: const Size(280, 280),
              painter: _CompassPainter(),
            ),
          ),

          // ─── Kaaba marker (does not rotate) ──
          Transform.rotate(
            angle: (qiblaBearing - heading!) * math.pi / 180.0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: aligned
                      ? AppConstants.emeraldPrimary
                      : AppConstants.goldAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (aligned
                              ? AppConstants.emeraldPrimary
                              : AppConstants.goldAccent)
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mosque,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ),

          // ─── Center indicator ────────────────
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: aligned
                  ? AppConstants.emeraldPrimary
                  : AppConstants.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppConstants.textPrimary,
                width: 2,
              ),
            ),
          ),

          // ─── Aligned badge ───────────────────
          if (aligned)
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                  vertical: AppConstants.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.emeraldPrimary,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: const Text(
                  'কিবলামুখী',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: AppConstants.fontCaption,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMPASS PAINTER
// ─────────────────────────────────────────────

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;

    // Outer ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF1F2937);
    canvas.drawCircle(center, radius + 20, ringPaint);

    // Inner faint circle
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF1F2937).withValues(alpha: 0.6);
    canvas.drawCircle(center, radius - 20, innerPaint);

    // Tick marks
    for (int i = 0; i < 72; i++) {
      final angle = i * 5 * math.pi / 180.0;
      final isMajor = i % 18 == 0;
      final isMedium = i % 9 == 0;

      final tickLen = isMajor ? 14.0 : (isMedium ? 10.0 : 5.0);
      final paint = Paint()
        ..strokeWidth = isMajor ? 2.0 : 1.0
        ..color = isMajor
            ? const Color(0xFF10B981)
            : const Color(0xFF6B7280);

      final outer = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );
      final inner = Offset(
        center.dx + (radius - tickLen) * math.sin(angle),
        center.dy - (radius - tickLen) * math.cos(angle),
      );
      canvas.drawLine(inner, outer, paint);
    }

    // Cardinal labels
    _drawText(canvas, 'N', center, radius - 40, 0, const Color(0xFF10B981));
    _drawText(canvas, 'E', center, radius - 40, 90, const Color(0xFFD4A24A));
    _drawText(canvas, 'S', center, radius - 40, 180, const Color(0xFF9CA3AF));
    _drawText(canvas, 'W', center, radius - 40, 270, const Color(0xFFD4A24A));
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double distance,
    double angleDeg,
    Color color,
  ) {
    final angle = angleDeg * math.pi / 180.0;
    final pos = Offset(
      center.dx + distance * math.sin(angle),
      center.dy - distance * math.cos(angle),
    );

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_CompassPainter oldDelegate) => false;
}
