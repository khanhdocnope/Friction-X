import 'package:flutter/material.dart';
import '../domain/interception_rule.dart';
import 'target_apps_controller.dart';

class TargetAppsSettingsScreen extends StatefulWidget {
  const TargetAppsSettingsScreen({super.key});

  @override
  State<TargetAppsSettingsScreen> createState() =>
      _TargetAppsSettingsScreenState();
}

class _TargetAppsSettingsScreenState extends State<TargetAppsSettingsScreen> {
  late final TargetAppsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TargetAppsController();
    _controller.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  Color _getStrategyColor(BlockStrategy strategy) {
    switch (strategy) {
      case BlockStrategy.hardBlock:
        return const Color(0xFFEF4444); // Red
      case BlockStrategy.microFriction:
        return const Color(0xFF6366F1); // Indigo
      case BlockStrategy.sensoryDegradation:
        return const Color(0xFFF59E0B); // Amber / Grayscale tint
      case BlockStrategy.hostageMode:
        return const Color(0xFFEC4899); // Pink / Warning
    }
  }

  String _getStrategyTitle(BlockStrategy strategy) {
    switch (strategy) {
      case BlockStrategy.hardBlock:
        return 'Chặn Cứng (Hard Block)';
      case BlockStrategy.microFriction:
        return 'Cổng Vi Ma Sát (50 từ)';
      case BlockStrategy.sensoryDegradation:
        return 'Dopamine Drain (Trắng đen + Lag)';
      case BlockStrategy.hostageMode:
        return 'Khóa Con Tin (Hostage Mode)';
    }
  }

  IconData _getStrategyIcon(BlockStrategy strategy) {
    switch (strategy) {
      case BlockStrategy.hardBlock:
        return Icons.block_flipped;
      case BlockStrategy.microFriction:
        return Icons.keyboard_outlined;
      case BlockStrategy.sensoryDegradation:
        return Icons.filter_b_and_w_rounded;
      case BlockStrategy.hostageMode:
        return Icons.qr_code_scanner_rounded;
    }
  }

  void _showAddAppDialog() {
    final nameCtrl = TextEditingController();
    final packageCtrl = TextEditingController();
    BlockStrategy selectedStrategy = BlockStrategy.microFriction;
    int duration = 15;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141419),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thêm Ứng Dụng Giám Sát',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Tên ứng dụng (vd: Discord, TikTok)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1C1C24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: packageCtrl,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      labelText: 'Package / Process (vd: com.discord / discord.exe)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1C1C24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chiến Lược Can Thiệp (Interception Strategy):',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<BlockStrategy>(
                    value: selectedStrategy,
                    dropdownColor: const Color(0xFF1E1E28),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1C1C24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: BlockStrategy.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(_getStrategyIcon(s), color: _getStrategyColor(s), size: 18),
                            const SizedBox(width: 10),
                            Text(_getStrategyTitle(s), style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedStrategy = val);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isNotEmpty &&
                          packageCtrl.text.trim().isNotEmpty) {
                        _controller.addNewApp(
                          appName: nameCtrl.text.trim(),
                          packageNameOrProcess: packageCtrl.text.trim(),
                          strategy: selectedStrategy,
                          durationMinutes: duration,
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Thêm Vào Danh Sách Kiểm Soát',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditStrategySheet(TargetAppRule rule) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141419),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Chọn Chế Độ Can Thiệp Cho ${rule.appName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...BlockStrategy.values.map((strategy) {
                final isSelected = rule.strategy == strategy;
                final color = _getStrategyColor(strategy);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _controller.updateStrategy(rule.id, strategy);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : const Color(0xFF1C1C24),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_getStrategyIcon(strategy), color: color, size: 22),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getStrategyTitle(strategy),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: color, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0C0F),
        elevation: 0,
        title: const Text(
          'Quản Lý Ứng Dụng Mục Tiêu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: _showAddAppDialog,
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _controller.rules.length,
              itemBuilder: (context, index) {
                final rule = _controller.rules[index];
                final strategyColor = _getStrategyColor(rule.strategy);

                return Dismissible(
                  key: Key(rule.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  ),
                  onDismissed: (_) => _controller.deleteRule(rule.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141419),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: rule.isEnabled
                            ? strategyColor.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: strategyColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getStrategyIcon(rule.strategy),
                                color: strategyColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rule.appName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    rule.packageNameOrProcess,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: rule.isEnabled,
                              activeColor: strategyColor,
                              onChanged: (val) =>
                                  _controller.toggleRuleEnabled(rule.id, val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white10, height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => _showEditStrategySheet(rule),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: strategyColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: strategyColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getStrategyTitle(rule.strategy),
                                      style: TextStyle(
                                        color: strategyColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: strategyColor,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              'Vé tạm: ${rule.temporaryPassDurationMinutes} phút',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm App Giám Sát'),
        onPressed: _showAddAppDialog,
      ),
    );
  }
}
