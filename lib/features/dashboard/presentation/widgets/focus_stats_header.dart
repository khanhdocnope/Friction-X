import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FocusStatsHeader extends StatefulWidget {
  final bool isFocusActive;
  final VoidCallback onToggleFocus;

  const FocusStatsHeader({
    super.key,
    required this.isFocusActive,
    required this.onToggleFocus,
  });

  @override
  State<FocusStatsHeader> createState() => _FocusStatsHeaderState();
}

class _FocusStatsHeaderState extends State<FocusStatsHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isFocusActive ? AppColors.neonGreen : AppColors.neonCrimson;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF131622),
            const Color(0xFF0D0F17),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.1),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeColor,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.8),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isFocusActive ? 'SHIELD ENGAGED' : 'SYSTEM STANDBY',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        widget.isFocusActive
                            ? 'Friction & Degradation active'
                            : 'Protection disabled',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Nút Toggle Siêu Đẹp
              GestureDetector(
                onTap: widget.onToggleFocus,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: activeColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    widget.isFocusActive ? 'TẮT FOCUS' : 'BẬT FOCUS',
                    style: TextStyle(
                      color: activeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),
          // Chỉ số Thống kê sống động
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                title: 'DOPAMINE CỨU ĐƯỢC',
                value: '3.4h',
                color: AppColors.cyberIndigo,
                icon: Icons.bolt_rounded,
              ),
              Container(width: 1, height: 36, color: Colors.white10),
              _buildStatItem(
                title: 'CÁM DỖ ĐÃ CHẶN',
                value: '27 lần',
                color: AppColors.neonCrimson,
                icon: Icons.security_rounded,
              ),
              Container(width: 1, height: 36, color: Colors.white10),
              _buildStatItem(
                title: 'STREAK TẬP TRUNG',
                value: '4 ngày',
                color: AppColors.toxicAmber,
                icon: Icons.local_fire_department_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
