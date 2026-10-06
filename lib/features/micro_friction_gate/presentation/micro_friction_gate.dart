import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

// ==========================================
// 1. DATA: Philosophical Corpus Repository
// ==========================================
class QuoteRepository {
  static final List<String> _philosophicalTexts = [
    "You have power over your mind not outside events. Realize this, and you will find strength. The happiness of your life depends upon the quality of your thoughts. Waste no more time arguing about what a good man should be. Be one. Every habit introduces its own kind of slavery.",
    "He who fears death will never do anything worthy of a man who is alive. We suffer more often in imagination than in reality. If a man knows not which port he sails, no wind is favorable. True happiness is to enjoy the present without anxious dependence upon the future.",
    "The soul becomes dyed with the color of its thoughts. Confine yourself to the present. Accept the things to which fate binds you, and love the people with whom fate brings you together, but do so with all your heart. It is not death that a man should fear.",
    "Man is not affected by events, but by the view he takes of them. When you arise in the morning think of what a privilege it is to be alive, to think, to enjoy, to love. Very little is needed to make a happy life; it is all within yourself.",
    "Freedom is the only worthy goal in life. It is won by disregarding things that lie beyond our control. Do not seek for things to happen the way you want them to; rather, wish that what happens happens the way it happens: then you will be happy."
  ];

  static String getRandom50WordChallenge() {
    final random = Random();
    return _philosophicalTexts[random.nextInt(_philosophicalTexts.length)];
  }
}

// ==========================================
// 2. DOMAIN: Typing Engine with Strict Penalties
// ==========================================
class TypingEngineState {
  final String targetText;
  final List<String> targetWords;
  final int currentWordIndex;
  final String currentWordInput;
  final int totalMistakes;
  final int totalCharactersTyped;
  final bool isCompleted;
  final DateTime? startTime;

  TypingEngineState({
    required this.targetText,
    required this.targetWords,
    this.currentWordIndex = 0,
    this.currentWordInput = '',
    this.totalMistakes = 0,
    this.totalCharactersTyped = 0,
    this.isCompleted = false,
    this.startTime,
  });

  factory TypingEngineState.initial(String text) {
    return TypingEngineState(
      targetText: text,
      targetWords: text.split(' '),
      currentWordIndex: 0,
      currentWordInput: '',
      totalMistakes: 0,
      totalCharactersTyped: 0,
      isCompleted: false,
    );
  }

  TypingEngineState copyWith({
    int? currentWordIndex,
    String? currentWordInput,
    int? totalMistakes,
    int? totalCharactersTyped,
    bool? isCompleted,
    DateTime? startTime,
  }) {
    return TypingEngineState(
      targetText: targetText,
      targetWords: targetWords,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      currentWordInput: currentWordInput ?? this.currentWordInput,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      totalCharactersTyped: totalCharactersTyped ?? this.totalCharactersTyped,
      isCompleted: isCompleted ?? this.isCompleted,
      startTime: startTime ?? this.startTime,
    );
  }

  double get progressPercentage {
    if (targetWords.isEmpty) return 0.0;
    return (currentWordIndex / targetWords.length).clamp(0.0, 1.0);
  }

  int get currentWpm {
    if (startTime == null || totalCharactersTyped == 0) return 0;
    final minutes = DateTime.now().difference(startTime!).inSeconds / 60.0;
    if (minutes <= 0.01) return 0;
    final wordsTyped = (totalCharactersTyped / 5.0);
    return (wordsTyped / minutes).round();
  }

  int get accuracyPercentage {
    final totalAttempts = totalCharactersTyped + (totalMistakes * 5);
    if (totalAttempts == 0) return 100;
    return ((totalCharactersTyped / totalAttempts) * 100).round().clamp(0, 100);
  }
}

class TypingEvaluator {
  static ({TypingEngineState state, bool typoOccurred}) processInput({
    required TypingEngineState currentState,
    required String newInput,
  }) {
    if (currentState.isCompleted) {
      return (state: currentState, typoOccurred: false);
    }

    final targetWord = currentState.targetWords[currentState.currentWordIndex];
    final startTime = currentState.startTime ?? DateTime.now();

    // Check for paste attempt
    final isPasted = (newInput.length - currentState.currentWordInput.length) > 1;
    if (isPasted) {
      return (
        state: currentState.copyWith(
          currentWordInput: '',
          totalMistakes: currentState.totalMistakes + 1,
          startTime: startTime,
        ),
        typoOccurred: true,
      );
    }

    // Check completed word
    final isLastWord = currentState.currentWordIndex == currentState.targetWords.length - 1;
    if (newInput.endsWith(' ') || (isLastWord && newInput == targetWord)) {
      final trimmedInput = newInput.trim();
      if (trimmedInput == targetWord) {
        final nextWordIndex = currentState.currentWordIndex + 1;
        final isDone = nextWordIndex >= currentState.targetWords.length;

        return (
          state: currentState.copyWith(
            currentWordIndex: nextWordIndex,
            currentWordInput: '',
            totalCharactersTyped: currentState.totalCharactersTyped + targetWord.length + 1,
            isCompleted: isDone,
            startTime: startTime,
          ),
          typoOccurred: false,
        );
      } else {
        return (
          state: currentState.copyWith(
            currentWordInput: '',
            totalMistakes: currentState.totalMistakes + 1,
            startTime: startTime,
          ),
          typoOccurred: true,
        );
      }
    }

    // Incremental character verification
    for (int i = 0; i < newInput.length; i++) {
      if (i >= targetWord.length || newInput[i] != targetWord[i]) {
        return (
          state: currentState.copyWith(
            currentWordInput: '',
            totalMistakes: currentState.totalMistakes + 1,
            startTime: startTime,
          ),
          typoOccurred: true,
        );
      }
    }

    return (
      state: currentState.copyWith(
        currentWordInput: newInput,
        totalCharactersTyped: currentState.totalCharactersTyped + (newInput.length > currentState.currentWordInput.length ? 1 : 0),
        startTime: startTime,
      ),
      typoOccurred: false,
    );
  }
}

// ==========================================
// 3. PRESENTATION: Micro-Friction Gate UI (Cyber-HUD)
// ==========================================
class MicroFrictionGateScreen extends StatefulWidget {
  final String targetAppName;
  final VoidCallback onUnlockGranted;

  const MicroFrictionGateScreen({
    super.key,
    required this.targetAppName,
    required this.onUnlockGranted,
  });

  @override
  State<MicroFrictionGateScreen> createState() => _MicroFrictionGateScreenState();
}

class _MicroFrictionGateScreenState extends State<MicroFrictionGateScreen>
    with SingleTickerProviderStateMixin {
  late TypingEngineState _state;
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _showShakeAnimation = false;

  @override
  void initState() {
    super.initState();
    final text = QuoteRepository.getRandom50WordChallenge();
    _state = TypingEngineState.initial(text);
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String val) {
    final result = TypingEvaluator.processInput(
      currentState: _state,
      newInput: val,
    );

    setState(() {
      _state = result.state;
      if (result.typoOccurred) {
        _textController.clear();
        _triggerShakePenalty();
      } else {
        if (_textController.text != result.state.currentWordInput) {
          _textController.text = result.state.currentWordInput;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        }
      }
    });

    if (_state.isCompleted) {
      HapticFeedback.heavyImpact();
      widget.onUnlockGranted();
    }
  }

  void _triggerShakePenalty() {
    HapticFeedback.vibrate();
    setState(() => _showShakeAnimation = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showShakeAnimation = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge & Live HUD Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.neonCrimson.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.neonCrimson.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCrimson.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.neonCrimson, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'INTERCEPT: ${widget.targetAppName.toUpperCase()}',
                          style: const TextStyle(
                            color: AppColors.neonCrimson,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildLiveHudChip('WPM', '${_state.currentWpm}', AppColors.cyberIndigo),
                      const SizedBox(width: 8),
                      _buildLiveHudChip('ACC', '${_state.accuracyPercentage}%', AppColors.neonGreen),
                      const SizedBox(width: 8),
                      _buildLiveHudChip('TYPOS', '${_state.totalMistakes}', AppColors.neonCrimson),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title & Psychological Cooldown Banner
              const Text(
                'Dopamine Friction Gate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gõ chính xác từng từ để vượt qua cổng ma sát. Sai 1 ký tự sẽ reset từ đang gõ. Không cho phép Copy-Paste.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Glowing Linear Progress Indicator
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 8,
                    width: MediaQuery.of(context).size.width * _state.progressPercentage,
                    decoration: BoxDecoration(
                      gradient: _state.progressPercentage == 1.0
                          ? const LinearGradient(colors: [AppColors.neonGreen, Color(0xFF34D399)])
                          : AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyberIndigo.withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Monospace Terminal Box with Live Word Diff
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F111A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _showShakeAnimation
                          ? AppColors.neonCrimson
                          : Colors.white.withValues(alpha: 0.08),
                      width: _showShakeAnimation ? 2 : 1.2,
                    ),
                    boxShadow: _showShakeAnimation
                        ? [
                            BoxShadow(
                              color: AppColors.neonCrimson.withValues(alpha: 0.3),
                              blurRadius: 20,
                            ),
                          ]
                        : [],
                  ),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 10.0,
                      children: List.generate(_state.targetWords.length, (index) {
                        final word = _state.targetWords[index];
                        final isPassed = index < _state.currentWordIndex;
                        final isCurrent = index == _state.currentWordIndex;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.cyberIndigo.withValues(alpha: 0.25)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: isCurrent
                                ? Border.all(color: AppColors.cyberIndigo, width: 1.5)
                                : null,
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.cyberIndigo.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'monospace',
                              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                              color: isPassed
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : isCurrent
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Protected Active Input Box
              TextField(
                controller: _textController,
                focusNode: _focusNode,
                autofocus: true,
                enableInteractiveSelection: false,
                contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF151824),
                  hintText: 'Gõ từ hiện tại và ấn phím cách...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                    fontFamily: 'sans-serif',
                  ),
                  prefixIcon: const Icon(Icons.terminal_rounded, color: AppColors.cyberIndigo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.cyberIndigo, width: 2),
                  ),
                ),
                onChanged: _onTextChanged,
              ),
              const SizedBox(height: 14),

              // Surrender Button
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  'Đóng Cửa Sổ & Tiếp Tục Làm Việc',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveHudChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
