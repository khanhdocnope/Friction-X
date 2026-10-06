import 'package:flutter/material.dart';
import '../domain/interception_rule.dart';

/// Màn hình chặn cứng (Hard Block Screen)
/// Được kích hoạt khi người dùng cố mở ứng dụng trong danh sách cấm tuyệt đối
class HardBlockScreen extends StatefulWidget {
  final TargetAppRule appRule;
  final VoidCallback onDismiss;

  const HardBlockScreen({
    super.key,
    required this.appRule,
    required this.onDismiss,
  });

  @override
  State<HardBlockScreen> createState() => _HardBlockScreenState();
}

class _HardBlockScreenState extends State<HardBlockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'HARD BLOCK ACTIVE',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Center Visual & Message
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withValues(alpha: 0.08),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.35),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.redAccent,
                          size: 52,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    widget.appRule.appName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Truy cập bị chặn hoàn toàn.',
                    style: TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Ứng dụng này đang được áp dụng quy tắc Chặn Cứng trong phiên làm việc. Hãy dừng lại và quay về nhiệm vụ chính.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Return Action Button
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E24),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Quay Lại Bàn Làm Việc',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
