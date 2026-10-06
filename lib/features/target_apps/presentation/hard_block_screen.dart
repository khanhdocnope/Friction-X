import 'package:flutter/material.dart';
import 'package:friction_x/core/theme/app_colors.dart';
import 'package:friction_x/core/widgets/cyber_radar_widget.dart';
import 'package:friction_x/features/kickstart_bridge/presentation/two_minute_bridge_screen.dart';
import 'package:friction_x/features/target_apps/domain/interception_rule.dart';

class HardBlockScreen extends StatelessWidget {
  final TargetAppRule appRule;
  final VoidCallback onDismiss;

  const HardBlockScreen({
    super.key,
    required this.appRule,
    required this.onDismiss,
  });

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
                  color: AppColors.neonCrimson.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.neonCrimson.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCrimson.withOpacity(0.2),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, color: AppColors.neonCrimson, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'FIREWALL HARD-BLOCK ACTIVE',
                      style: TextStyle(
                        color: AppColors.neonCrimson,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Center Visual: Animated Vector Radar Scanner (Thay thế hoàn toàn emoji)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const CyberRadarWidget(size: 140, color: AppColors.neonCrimson),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF161926),
                          border: Border.all(color: AppColors.neonCrimson, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCrimson.withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text(
                    appRule.appName.toUpperCase(),
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
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Action Buttons (Chuyển sang Cây cầu 2 phút)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TwoMinuteBridgeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyberIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.cyberIndigo.withOpacity(0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Bắt Đầu 2 Phút Không Áp Lực',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text(
                      'Tắt cửa sổ và rời khỏi thiết bị',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
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
