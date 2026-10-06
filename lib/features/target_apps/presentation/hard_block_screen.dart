import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../target_apps/domain/interception_rule.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  color: AppColors.neonCrimson.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.neonCrimson.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCrimson.withValues(alpha: 0.2),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_rounded, color: AppColors.neonCrimson, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'FIREWALL HARD-BLOCK ACTIVE',
                      style: const TextStyle(
                        color: AppColors.neonCrimson,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Center Visual & Cyber Shield Radar
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating Radar Aura
                      RotationTransition(
                        turns: _rotateController,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.neonCrimson.withValues(alpha: 0.25),
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                      ),
                      // Pulsing Core
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.neonCrimson.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.neonCrimson,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCrimson.withValues(alpha: 0.4),
                                blurRadius: 32,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white,
                              size: 46,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
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
                      color: Color(0xFFF1F5F9),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Ứng dụng này đang được bảo vệ bởi bức tường lửa Focus. Hãy hít một hơi sâu và quay về nhiệm vụ chính.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Return Button
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF161926),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
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
