import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glowing_card.dart';
import '../../dashboard/presentation/widgets/focus_stats_header.dart';
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
  bool _isFocusActive = true;

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
        return AppColors.neonCrimson;
      case BlockStrategy.microFriction:
        return AppColors.cyberIndigo;
      case BlockStrategy.sensoryDegradation:
        return AppColors.toxicAmber;
      case BlockStrategy.hostageMode:
        return const Color(0xFFEC4899);
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
      backgroundColor: const Color(0xFF0F111A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Tên ứng dụng (vd: Discord, TikTok, Steam)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF161926),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: packageCtrl,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      labelText: 'Package / Process (com.discord / discord.exe)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF161926),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Chiến Lược Can Thiệp (Interception Strategy):',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<BlockStrategy>(
                    value: selectedStrategy,
                    dropdownColor: const Color(0xFF181B29),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF161926),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
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
                  const SizedBox(height: 24),
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
                      'Thêm Vào Danh Sách Kiểm Soát',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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
      backgroundColor: const Color(0xFF0F111A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              ...BlockStrategy.values.map((strategy) {
                final isSelected = rule.strategy == strategy;
                final color = _getStrategyColor(strategy);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      _controller.updateStrategy(rule.id, strategy);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : const Color(0xFF161926),
                        borderRadius: BorderRadius.circular(14),
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
                            child: Text(
                              _getStrategyTitle(strategy),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cyberIndigo.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cyberIndigo.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.cyberIndigo, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'FRICTION-X',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
            onPressed: _showAddAppDialog,
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.cyberIndigo))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: FocusStatsHeader(
                    isFocusActive: _isFocusActive,
                    onToggleFocus: () {
                      setState(() => _isFocusActive = !_isFocusActive);
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DANH SÁCH ỨNG DỤNG GIÁM SÁT',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '${_controller.rules.length} apps',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final rule = _controller.rules[index];
                        final strategyColor = _getStrategyColor(rule.strategy);

                        return Dismissible(
                          key: Key(rule.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.neonCrimson.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.delete_outline, color: AppColors.neonCrimson),
                          ),
                          onDismissed: (_) => _controller.deleteRule(rule.id),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlowingCard(
                              glowColor: strategyColor,
                              isGlowing: rule.isEnabled,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: strategyColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          _getStrategyIcon(rule.strategy),
                                          color: strategyColor,
                                          size: 22,
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
                                                fontWeight: FontWeight.w800,
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
                                  const SizedBox(height: 14),
                                  const Divider(color: Colors.white10, height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => _showEditStrategySheet(rule),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: strategyColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: strategyColor.withValues(alpha: 0.4),
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
                                                  fontWeight: FontWeight.w700,
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
                                        'Vé tạm: ${rule.temporaryPassDurationMinutes}m',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.4),
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _controller.rules.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.cyberIndigo,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text(
          'Thêm App Giám Sát',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        onPressed: _showAddAppDialog,
      ),
    );
  }
}
