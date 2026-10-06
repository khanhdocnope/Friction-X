import 'dart:math';
import 'package:flutter/material.dart';

/// Radar scanner xoay vòng 360 độ với tia quét năng lượng
class CyberRadarWidget extends StatefulWidget {
  final double size;
  final Color color;

  const CyberRadarWidget({
    super.key,
    this.size = 120,
    this.color = const Color(0xFFFF2E5B),
  });

  @override
  State<CyberRadarWidget> createState() => _CyberRadarWidgetState();
}

class _CyberRadarWidgetState extends State<CyberRadarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RadarPainter(
            angle: _ctrl.value * 2 * pi,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double angle;
  final Color color;

  _RadarPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Vòng tròn lưới
    final circlePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, circlePaint);
    canvas.drawCircle(center, radius * 0.66, circlePaint);
    canvas.drawCircle(center, radius * 0.33, circlePaint);

    // Trục chữ thập
    final axisPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), axisPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), axisPaint);

    // Tia quét Sweep Gradient
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: pi / 2,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.4),
        ],
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Điểm tâm năng lượng
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(center, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}
