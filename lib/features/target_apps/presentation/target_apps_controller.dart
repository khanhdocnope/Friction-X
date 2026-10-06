import 'package:flutter/material.dart';
import '../data/app_rule_repository.dart';
import '../domain/interception_rule.dart';

class TargetAppsController extends ChangeNotifier {
  final AppRuleRepository _repository;
  List<TargetAppRule> _rules = [];
  bool _isLoading = true;

  TargetAppsController({AppRuleRepository? repository})
      : _repository = repository ?? InMemoryAppRuleRepository() {
    loadRules();
  }

  List<TargetAppRule> get rules => _rules;
  bool get isLoading => _isLoading;

  Future<void> loadRules() async {
    _isLoading = true;
    notifyListeners();
    _rules = await _repository.getRules();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleRuleEnabled(String id, bool isEnabled) async {
    final index = _rules.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updated = _rules[index].copyWith(isEnabled: isEnabled);
      await _repository.updateRule(updated);
      _rules = await _repository.getRules();
      notifyListeners();
    }
  }

  Future<void> updateStrategy(String id, BlockStrategy newStrategy) async {
    final index = _rules.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updated = _rules[index].copyWith(strategy: newStrategy);
      await _repository.updateRule(updated);
      _rules = await _repository.getRules();
      notifyListeners();
    }
  }

  Future<void> updateDuration(String id, int minutes) async {
    final index = _rules.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updated = _rules[index].copyWith(temporaryPassDurationMinutes: minutes);
      await _repository.updateRule(updated);
      _rules = await _repository.getRules();
      notifyListeners();
    }
  }

  Future<void> addNewApp({
    required String appName,
    required String packageNameOrProcess,
    required BlockStrategy strategy,
    int durationMinutes = 15,
  }) async {
    final newRule = TargetAppRule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      appName: appName,
      packageNameOrProcess: packageNameOrProcess,
      strategy: strategy,
      isEnabled: true,
      temporaryPassDurationMinutes: durationMinutes,
    );
    await _repository.saveRule(newRule);
    _rules = await _repository.getRules();
    notifyListeners();
  }

  Future<void> deleteRule(String id) async {
    await _repository.deleteRule(id);
    _rules = await _repository.getRules();
    notifyListeners();
  }
}
