import 'dart:math';
import 'package:flutter/material.dart';

/// Hiệu ứng ngọn lửa / sóng hạt năng lượng chuyển động tuần hoàn (Thay thế emoji lửa)
class EnergyFlameWidget extends StatefulWidget {
  final double size;
  final Color color;

  const EnergyFlameWidget({
    super.key,
    this.size = 20,
    this.color = const Color(0xFFF59E0B),
  });

  @override
  State<EnergyFlameWidget> createState() => _EnergyFlameWidgetState();
}

class _EnergyFlameWidgetState extends State<EnergyFlameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
        final scale = 0.85 + (_ctrl.value * 0.3);
        final opacity = 0.7 + (_ctrl.value * 0.3);

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Icon(
              Icons.local_fire_department_rounded,
              color: widget.color,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}
