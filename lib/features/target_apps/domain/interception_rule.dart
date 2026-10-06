/// Các chiến lược can thiệp đối với ứng dụng gây xao nhãng
enum BlockStrategy {
  /// Chặn tuyệt đối: Ngay lập tức đẩy về Home / Khóa cửa sổ
  hardBlock,

  /// Cổng ma sát: Bắt buộc gõ đúng 50 từ triết học mới được mở
  microFriction,

  /// Suy giảm cảm giác: Cho vào app nhưng chuyển màn hình Trắng Đen & gây giật lag thao tác cuộn
  sensoryDegradation,

  /// Cầm chân theo hợp đồng giờ hẹn: Khóa thiết bị đến khi quét mã QR
  hostageMode,
}

/// Cấu hình quy tắc can thiệp cho một ứng dụng mục tiêu
class TargetAppRule {
  final String id;
  final String appName;
  final String packageNameOrProcess;
  final BlockStrategy strategy;
  final bool isEnabled;
  final int temporaryPassDurationMinutes;
  final DateTime? lastUnlockedAt;

  const TargetAppRule({
    required this.id,
    required this.appName,
    required this.packageNameOrProcess,
    this.strategy = BlockStrategy.microFriction,
    this.isEnabled = true,
    this.temporaryPassDurationMinutes = 15,
    this.lastUnlockedAt,
  });

  /// Kiểm tra xem ứng dụng hiện có đang trong thời gian được mở tạm thời hay không
  bool get hasActivePass {
    if (lastUnlockedAt == null) return false;
    final expiration = lastUnlockedAt!.add(
      Duration(minutes: temporaryPassDurationMinutes),
    );
    return DateTime.now().isBefore(expiration);
  }

  TargetAppRule copyWith({
    String? id,
    String? appName,
    String? packageNameOrProcess,
    BlockStrategy? strategy,
    bool? isEnabled,
    int? temporaryPassDurationMinutes,
    DateTime? lastUnlockedAt,
  }) {
    return TargetAppRule(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      packageNameOrProcess: packageNameOrProcess ?? this.packageNameOrProcess,
      strategy: strategy ?? this.strategy,
      isEnabled: isEnabled ?? this.isEnabled,
      temporaryPassDurationMinutes:
          temporaryPassDurationMinutes ?? this.temporaryPassDurationMinutes,
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appName': appName,
      'packageNameOrProcess': packageNameOrProcess,
      'strategy': strategy.name,
      'isEnabled': isEnabled,
      'temporaryPassDurationMinutes': temporaryPassDurationMinutes,
      'lastUnlockedAt': lastUnlockedAt?.toIso8601String(),
    };
  }

  factory TargetAppRule.fromJson(Map<String, dynamic> json) {
    return TargetAppRule(
      id: json['id'] as String,
      appName: json['appName'] as String,
      packageNameOrProcess: json['packageNameOrProcess'] as String,
      strategy: BlockStrategy.values.firstWhere(
        (e) => e.name == json['strategy'],
        orElse: () => BlockStrategy.microFriction,
      ),
      isEnabled: json['isEnabled'] as bool? ?? true,
      temporaryPassDurationMinutes:
          json['temporaryPassDurationMinutes'] as int? ?? 15,
      lastUnlockedAt: json['lastUnlockedAt'] != null
          ? DateTime.parse(json['lastUnlockedAt'] as String)
          : null,
    );
  }
}
