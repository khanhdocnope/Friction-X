import '../domain/interception_rule.dart';

/// Kết quả quyết định can thiệp của hệ thống
enum InterceptionActionType {
  /// Không can thiệp, cho phép app chạy bình thường
  allow,

  /// Chặn cứng: Hiển thị màn hình khóa/đẩy về Home
  triggerHardBlock,

  /// Bật cổng gõ phím vi ma sát (50 từ)
  triggerMicroFriction,

  /// Bật chế độ suy giảm cảm giác (Trắng đen + Scroll Lag)
  applySensoryDegradation,

  /// Khóa con tin (yêu cầu quét QR tại bàn làm việc)
  triggerHostageMode,
}

class InterceptionDecision {
  final InterceptionActionType action;
  final TargetAppRule? matchedRule;
  final String reason;

  const InterceptionDecision({
    required this.action,
    this.matchedRule,
    required this.reason,
  });
}

/// Bộ phân xử quy tắc can thiệp (Interception Router)
/// Quyết định xem khi phát hiện mở 1 app/tiến trình thì can thiệp bằng cách nào
class InterceptionRouter {
  final List<TargetAppRule> rules;
  final bool isFocusModeActive;
  final bool isHostageModeActive;

  const InterceptionRouter({
    required this.rules,
    required this.isFocusModeActive,
    this.isHostageModeActive = false,
  });

  /// Kiểm tra và ra quyết định can thiệp cho một package (Android) hoặc process name (Windows/macOS)
  InterceptionDecision evaluate(String packageNameOrProcess) {
    // 1. Kiểm tra Hostage Mode toàn hệ thống (ưu tiên cao nhất)
    if (isHostageModeActive) {
      return const InterceptionDecision(
        action: InterceptionActionType.triggerHostageMode,
        reason: 'Hostage Mode is globally active. Device locked until QR scan.',
      );
    }

    // 2. Nếu không trong phiên Focus -> cho phép mở bình thường
    if (!isFocusModeActive) {
      return const InterceptionDecision(
        action: InterceptionActionType.allow,
        reason: 'Focus mode is inactive.',
      );
    }

    // 3. Tìm quy tắc tương ứng với app được mở
    final matched = rules.where((r) => r.isEnabled).cast<TargetAppRule?>().firstWhere(
          (r) =>
              r!.packageNameOrProcess.toLowerCase() ==
              packageNameOrProcess.toLowerCase(),
          orElse: () => null,
        );

    // Không nằm trong danh sách kiểm soát -> cho phép
    if (matched == null) {
      return const InterceptionDecision(
        action: InterceptionActionType.allow,
        reason: 'App is not in the monitored blacklist.',
      );
    }

    // 4. Kiểm tra vé thông hành tạm thời (Temporary Pass)
    if (matched.hasActivePass) {
      return InterceptionDecision(
        action: InterceptionActionType.allow,
        matchedRule: matched,
        reason: 'Active temporary pass granted (${matched.temporaryPassDurationMinutes}m).',
      );
    }

    // 5. Áp dụng chiến lược theo quy tắc đã cấu hình
    switch (matched.strategy) {
      case BlockStrategy.hardBlock:
        return InterceptionDecision(
          action: InterceptionActionType.triggerHardBlock,
          matchedRule: matched,
          reason: 'Hard block policy enforced for this application.',
        );

      case BlockStrategy.microFriction:
        return InterceptionDecision(
          action: InterceptionActionType.triggerMicroFriction,
          matchedRule: matched,
          reason: 'Micro-friction gate required (50-word typing challenge).',
        );

      case BlockStrategy.sensoryDegradation:
        return InterceptionDecision(
          action: InterceptionActionType.applySensoryDegradation,
          matchedRule: matched,
          reason: 'Sensory degradation applied (Grayscale & Scroll Lag).',
        );

      case BlockStrategy.hostageMode:
        return InterceptionDecision(
          action: InterceptionActionType.triggerHostageMode,
          matchedRule: matched,
          reason: 'Hostage mode contract requires physical QR verification.',
        );
    }
  }
}
