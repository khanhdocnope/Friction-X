import 'dart:async';
import 'package:flutter/material.dart';
import 'package:friction_x/core/native_bridge/platform_native_bridge.dart';
import 'package:friction_x/features/target_apps/data/app_rule_repository.dart';
import 'package:friction_x/features/target_apps/domain/interception_router.dart';
import 'package:friction_x/features/target_apps/presentation/hard_block_screen.dart';
import 'package:friction_x/features/micro_friction_gate/presentation/micro_friction_gate.dart';

/// Service trung tâm chạy nền trên Flutter điều phối sự kiện mở App từ Native
class BackgroundInterceptionManager {
  final PlatformNativeBridge _bridge;
  final AppRuleRepository _repository;
  final GlobalKey<NavigatorState> navigatorKey;

  StreamSubscription<String>? _sub;
  bool isFocusModeActive = true;
  bool isHostageModeActive = false;

  BackgroundInterceptionManager({
    PlatformNativeBridge? bridge,
    AppRuleRepository? repository,
    required this.navigatorKey,
  })  : _bridge = bridge ?? FlutterPlatformNativeBridge(),
        _repository = repository ?? InMemoryAppRuleRepository();

  void initialize() {
    _sub = _bridge.onAppLaunchedStream.listen(_handleAppDetected);
  }

  void dispose() {
    _sub?.cancel();
  }

  Future<void> _handleAppDetected(String packageNameOrProcess) async {
    final rules = await _repository.getRules();
    final router = InterceptionRouter(
      rules: rules,
      isFocusModeActive: isFocusModeActive,
      isHostageModeActive: isHostageModeActive,
    );

    final decision = router.evaluate(packageNameOrProcess);
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (decision.action) {
      case InterceptionActionType.allow:
        // Đảm bảo tắt Grayscale & Scroll Lag nếu app này được phép
        await _bridge.setGrayscale(false);
        await _bridge.setScrollLag(false);
        break;

      case InterceptionActionType.triggerHardBlock:
        await _bridge.setGrayscale(false);
        await _bridge.setScrollLag(false);
        if (decision.matchedRule != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => HardBlockScreen(
                appRule: decision.matchedRule!,
                onDismiss: () => Navigator.of(context).pop(),
              ),
            ),
          );
        }
        break;

      case InterceptionActionType.triggerMicroFriction:
        await _bridge.setGrayscale(false);
        await _bridge.setScrollLag(false);
        if (decision.matchedRule != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => MicroFrictionGateScreen(
                targetAppName: decision.matchedRule!.appName,
                onUnlockGranted: () async {
                  // Cấp vé tạm thời 15 phút sau khi gõ xong
                  await _repository.grantTemporaryPass(
                    decision.matchedRule!.id,
                    decision.matchedRule!.temporaryPassDurationMinutes,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          );
        }
        break;

      case InterceptionActionType.applySensoryDegradation:
        // Kích hoạt Grayscale và Scroll Lag tại tầng Native!
        await _bridge.setGrayscale(true);
        await _bridge.setScrollLag(true);
        break;

      case InterceptionActionType.triggerHostageMode:
        // Sẽ điều hướng tới màn hình Quét mã QR Hostage Mode
        break;
    }
  }
}
