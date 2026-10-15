import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../providers/location_provider.dart';
import '../../providers/qibla_provider.dart';

/// Qibla compass screen.
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
    final colors = AppColors.of(context);
    final loc = ref.watch(currentLocationProvider);
    final qibla = ref.watch(qiblaDirectionProvider);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Text(
          'কিবলা',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppConstants.spaceLg),
              _InfoCard(
                locationName: loc.displayName,
                bearing: qibla.bearing,
                distanceKm: qibla.distanceKm,
              ),
              const Spacer(),
              _CompassView(
                heading: _heading,
                qiblaBearing: qibla.bearing,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceXl),
                child: Text(
                  'ফোনটি সমতল করে ধরুন, চারপাশের ধাতব বস্তু দূরে রাখুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textMuted,
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
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        gradient: colors.prayerCardGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: colors.border, width: 1.2),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            locationName,
            style: TextStyle(
              color: colors.textPrimary,
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
                color: colors.divider,
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
    final colors = AppColors.of(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: colors.emerald,
            fontSize: AppConstants.fontHeading,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: AppConstants.fontCaption,
          ),
        ),
      ],
    );
  }
}

class _CompassView extends StatelessWidget {
  final double? heading;
  final double qiblaBearing;

  const _CompassView({
    required this.heading,
    required this.qiblaBearing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (heading == null) {
      return SizedBox(
        width: 280,
        height: 280,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_off_outlined,
                color: colors.textFaint,
                size: 48,
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Text(
                'কম্পাস সেন্সর নেই',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: AppConstants.fontBody,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dialRotation = -heading! * math.pi / 180.0;
    final kaabaAngleDeg = (qiblaBearing - heading! + 360) % 360;
    final aligned = kaabaAngleDeg < 5 || kaabaAngleDeg > 355;

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: dialRotation,
            child: CustomPaint(
              size: const Size(280, 280),
              painter: _CompassPainter(colors: colors),
            ),
          ),
          Transform.rotate(
            angle: (qiblaBearing - heading!) * math.pi / 180.0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      aligned ? colors.emerald : colors.gold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (aligned ? colors.emerald : colors.gold)
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mosque_rounded,
                  color: colors.textOnEmerald,
                  size: 22,
                ),
              ),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: aligned
                  ? colors.emerald
                  : colors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.textPrimary,
                width: 2,
              ),
            ),
          ),
          if (aligned)
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                  vertical: AppConstants.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: colors.emerald,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  'কিবলামুখী',
                  style: TextStyle(
                    color: colors.textOnEmerald,
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

class _CompassPainter extends CustomPainter {
  final AppColors colors;

  _CompassPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = colors.divider;
    canvas.drawCircle(center, radius + 20, ringPaint);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colors.divider.withValues(alpha: 0.6);
    canvas.drawCircle(center, radius - 20, innerPaint);

    for (int i = 0; i < 72; i++) {
      final angle = i * 5 * math.pi / 180.0;
      final isMajor = i % 18 == 0;
      final isMedium = i % 9 == 0;

      final tickLen = isMajor ? 14.0 : (isMedium ? 10.0 : 5.0);
      final paint = Paint()
        ..strokeWidth = isMajor ? 2.0 : 1.0
        ..color = isMajor ? colors.emerald : colors.textFaint;

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

    _drawText(canvas, 'N', center, radius - 40, 0, colors.emerald);
    _drawText(canvas, 'E', center, radius - 40, 90, colors.gold);
    _drawText(canvas, 'S', center, radius - 40, 180, colors.textMuted);
    _drawText(canvas, 'W', center, radius - 40, 270, colors.gold);
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
