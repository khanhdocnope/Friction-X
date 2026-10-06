import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glowing_card.dart';

/// Màn hình Cây Cầu Bắt Đầu 2 Phút (The 2-Minute Kickstart Bridge)
/// Ứng dụng nguyên lý tâm lý học: Giảm áp lực nhận thức xuống mức tối thiểu,
/// cam kết chỉ làm trong 120 giây để vượt qua sự kháng cự của Hạch Hạnh Nhân (Amygdala).
class TwoMinuteBridgeScreen extends StatefulWidget {
  final String? initialTaskName;

  const TwoMinuteBridgeScreen({
    super.key,
    this.initialTaskName,
  });

  @override
  State<TwoMinuteBridgeScreen> createState() => _TwoMinuteBridgeScreenState();
}

class _TwoMinuteBridgeScreenState extends State<TwoMinuteBridgeScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _taskController;
  Timer? _timer;
  int _remainingSeconds = 120;
  bool _isRunning = false;
  bool _isCompleted = false;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.initialTaskName ?? '');
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_taskController.text.trim().isEmpty) return;

    setState(() {
      _isRunning = true;
      _isCompleted = false;
      _remainingSeconds = 120;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
          _isCompleted = true;
        });
      }
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'THE 2-MINUTE BRIDGE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Psychological Reassurance Banner
              GlowingCard(
                glowColor: AppColors.cyberIndigo,
                isGlowing: true,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cyberIndigo.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: AppColors.cyberIndigo,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chỉ cần 2 phút, không áp lực!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Bạn chỉ cần bắt tay vào làm đúng 120 giây. Hết giờ nếu vẫn thấy mệt, bạn hoàn toàn có thể dừng lại nghỉ mà không cần tự trách mình.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Task Input (Micro-Action Definition)
              if (!_isRunning && !_isCompleted) ...[
                const Text(
                  'Chọn 1 việc siêu nhỏ để làm ngay:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ví dụ: "Mở file Word viết 1 câu", "Đọc 3 dòng sách", "Dọn bàn làm việc"',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _taskController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Nhập việc bạn định làm...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: const Color(0xFF141724),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.cyberIndigo, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyberIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.cyberIndigo.withValues(alpha: 0.5),
                  ),
                  child: const Text(
                    'Bấm Vào Đây & Làm Trong 2 Phút',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ],

              // Running Timer / Countdown Display
              if (_isRunning) ...[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _taskController.text.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Circular Countdown Indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: CircularProgressIndicator(
                              value: _remainingSeconds / 120.0,
                              strokeWidth: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formattedTime,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'CHỈ CẦN 120S',
                                style: TextStyle(
                                  color: AppColors.neonCyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        'Đừng lo lắng về kết quả. Bạn chỉ cần hiện diện và làm.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Completed State (Flow State Triggered)
              if (_isCompleted) ...[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonGreen.withValues(alpha: 0.15),
                          border: Border.all(color: AppColors.neonGreen, width: 2),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.neonGreen,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Bạn Đã Vượt Qua Bước Khó Nhất Rồi!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Khởi động xong rồi đấy! Bạn thấy làm việc cũng đâu quá tệ đúng không? Giờ bạn muốn làm tiếp hay dừng lại nghỉ ngơi?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Đang Vào Cơn Hăng - Làm Tiếp Luôn!',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text(
                          'Thôi nghỉ một lát đã',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
