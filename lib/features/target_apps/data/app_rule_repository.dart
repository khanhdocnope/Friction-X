import 'dart:convert';
import '../domain/interception_rule.dart';

/// Repository trừu tượng quản lý quy tắc chặn ứng dụng
abstract class AppRuleRepository {
  Future<List<TargetAppRule>> getRules();
  Future<void> saveRule(TargetAppRule rule);
  Future<void> updateRule(TargetAppRule rule);
  Future<void> deleteRule(String id);
  Future<void> grantTemporaryPass(String ruleId, int minutes);
}

/// InMemory / Default Repository với danh sách ứng dụng mẫu thường gây xao nhãng
class InMemoryAppRuleRepository implements AppRuleRepository {
  final List<TargetAppRule> _rules = [
    const TargetAppRule(
      id: '1',
      appName: 'YouTube',
      packageNameOrProcess: 'com.google.android.youtube',
      strategy: BlockStrategy.microFriction,
      isEnabled: true,
      temporaryPassDurationMinutes: 15,
    ),
    const TargetAppRule(
      id: '2',
      appName: 'TikTok',
      packageNameOrProcess: 'com.zhiliaoapp.musically',
      strategy: BlockStrategy.hardBlock,
      isEnabled: true,
      temporaryPassDurationMinutes: 10,
    ),
    const TargetAppRule(
      id: '3',
      appName: 'Facebook / Instagram',
      packageNameOrProcess: 'com.instagram.android',
      strategy: BlockStrategy.sensoryDegradation,
      isEnabled: true,
      temporaryPassDurationMinutes: 20,
    ),
    const TargetAppRule(
      id: '4',
      appName: 'Reddit',
      packageNameOrProcess: 'com.reddit.frontpage',
      strategy: BlockStrategy.microFriction,
      isEnabled: true,
      temporaryPassDurationMinutes: 15,
    ),
    const TargetAppRule(
      id: '5',
      appName: 'Steam / Game Client',
      packageNameOrProcess: 'steam.exe',
      strategy: BlockStrategy.hardBlock,
      isEnabled: true,
      temporaryPassDurationMinutes: 30,
    ),
  ];

  @override
  Future<List<TargetAppRule>> getRules() async {
    return List.unmodifiable(_rules);
  }

  @override
  Future<void> saveRule(TargetAppRule rule) async {
    _rules.add(rule);
  }

  @override
  Future<void> updateRule(TargetAppRule rule) async {
    final index = _rules.indexWhere((r) => r.id == rule.id);
    if (index != -1) {
      _rules[index] = rule;
    }
  }

  @override
  Future<void> deleteRule(String id) async {
    _rules.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> grantTemporaryPass(String ruleId, int minutes) async {
    final index = _rules.indexWhere((r) => r.id == ruleId);
    if (index != -1) {
      _rules[index] = _rules[index].copyWith(
        temporaryPassDurationMinutes: minutes,
        lastUnlockedAt: DateTime.now(),
      );
    }
  }
}
