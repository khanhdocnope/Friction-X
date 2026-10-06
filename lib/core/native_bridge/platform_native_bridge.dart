import 'dart:async';
import 'package:flutter/services.dart';

/// Các lệnh gửi xuống Native (Android / Windows)
class NativeBridgeMethods {
  static const String startMonitoring = 'startMonitoring';
  static const String stopMonitoring = 'stopMonitoring';
  static const String updateRules = 'updateRules';
  static const String requestPermissions = 'requestPermissions';
  static const String checkPermissions = 'checkPermissions';
  static const String enableGrayscale = 'enableGrayscale';
  static const String disableGrayscale = 'disableGrayscale';
  static const String triggerScrollLag = 'triggerScrollLag';
}

/// Trạng thái quyền hệ thống
class NativePermissionStatus {
  final bool hasAccessibility;
  final bool hasOverlayPermission;
  final bool hasUsageStats;

  const NativePermissionStatus({
    required this.hasAccessibility,
    required this.hasOverlayPermission,
    required this.hasUsageStats,
  });

  bool get isFullyAuthorized => hasAccessibility && hasOverlayPermission;

  factory NativePermissionStatus.fromMap(Map<dynamic, dynamic> map) {
    return NativePermissionStatus(
      hasAccessibility: map['hasAccessibility'] as bool? ?? false,
      hasOverlayPermission: map['hasOverlayPermission'] as bool? ?? false,
      hasUsageStats: map['hasUsageStats'] as bool? ?? false,
    );
  }
}

/// Interface trừu tượng của Platform Interceptor Bridge
abstract class PlatformNativeBridge {
  Stream<String> get onAppLaunchedStream;

  Future<NativePermissionStatus> checkPermissions();
  Future<void> requestPermissions();
  Future<void> startMonitoring(List<Map<String, dynamic>> rules);
  Future<void> stopMonitoring();
  Future<void> updateActiveRules(List<Map<String, dynamic>> rules);
  Future<void> setGrayscale(bool enabled);
  Future<void> setScrollLag(bool enabled);
}

/// Triển khai MethodChannel / EventChannel thực tế
class FlutterPlatformNativeBridge implements PlatformNativeBridge {
  static const MethodChannel _methodChannel =
      MethodChannel('com.frictionx/native_bridge');
  static const EventChannel _eventChannel =
      EventChannel('com.frictionx/app_events');

  Stream<String>? _appLaunchedStream;

  @override
  Stream<String> get onAppLaunchedStream {
    _appLaunchedStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => event.toString());
    return _appLaunchedStream!;
  }

  @override
  Future<NativePermissionStatus> checkPermissions() async {
    try {
      final res = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        NativeBridgeMethods.checkPermissions,
      );
      return NativePermissionStatus.fromMap(res ?? {});
    } on PlatformException catch (_) {
      return const NativePermissionStatus(
        hasAccessibility: false,
        hasOverlayPermission: false,
        hasUsageStats: false,
      );
    }
  }

  @override
  Future<void> requestPermissions() async {
    try {
      await _methodChannel.invokeMethod(NativeBridgeMethods.requestPermissions);
    } on PlatformException catch (e) {
      // ignore or log
    }
  }

  @override
  Future<void> startMonitoring(List<Map<String, dynamic>> rules) async {
    try {
      await _methodChannel.invokeMethod(
        NativeBridgeMethods.startMonitoring,
        {'rules': rules},
      );
    } on PlatformException catch (_) {}
  }

  @override
  Future<void> stopMonitoring() async {
    try {
      await _methodChannel.invokeMethod(NativeBridgeMethods.stopMonitoring);
    } on PlatformException catch (_) {}
  }

  @override
  Future<void> updateActiveRules(List<Map<String, dynamic>> rules) async {
    try {
      await _methodChannel.invokeMethod(
        NativeBridgeMethods.updateRules,
        {'rules': rules},
      );
    } on PlatformException catch (_) {}
  }

  @override
  Future<void> setGrayscale(bool enabled) async {
    try {
      if (enabled) {
        await _methodChannel.invokeMethod(NativeBridgeMethods.enableGrayscale);
      } else {
        await _methodChannel.invokeMethod(NativeBridgeMethods.disableGrayscale);
      }
    } on PlatformException catch (_) {}
  }

  @override
  Future<void> setScrollLag(bool enabled) async {
    try {
      await _methodChannel.invokeMethod(
        NativeBridgeMethods.triggerScrollLag,
        {'enabled': enabled},
      );
    } on PlatformException catch (_) {}
  }
}
