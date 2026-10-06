import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final bool isCompleted;
  final DateTime? startTime;

  TypingEngineState({
    required this.targetText,
    required this.targetWords,
    this.currentWordIndex = 0,
    this.currentWordInput = '',
    this.totalMistakes = 0,
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
      isCompleted: false,
    );
  }

  TypingEngineState copyWith({
    int? currentWordIndex,
    String? currentWordInput,
    int? totalMistakes,
    bool? isCompleted,
    DateTime? startTime,
  }) {
    return TypingEngineState(
      targetText: targetText,
      targetWords: targetWords,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      currentWordInput: currentWordInput ?? this.currentWordInput,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      isCompleted: isCompleted ?? this.isCompleted,
      startTime: startTime ?? this.startTime,
    );
  }

  double get progressPercentage {
    if (targetWords.isEmpty) return 0.0;
    return (currentWordIndex / targetWords.length).clamp(0.0, 1.0);
  }
}

class TypingEvaluator {
  /// Evaluates input changes against the current active word.
  /// Rule: Typing mistake resets the current word input back to empty.
  static ({TypingEngineState state, bool typoOccurred}) processInput({
    required TypingEngineState currentState,
    required String newInput,
  }) {
    if (currentState.isCompleted) {
      return (state: currentState, typoOccurred: false);
    }

    final targetWord = currentState.targetWords[currentState.currentWordIndex];
    final startTime = currentState.startTime ?? DateTime.now();

    // Check for paste attempt (difference in length > 1 char per frame)
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

    // Check if user finished the word (space pressed or matched last word)
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
        startTime: startTime,
      ),
      typoOccurred: false,
    );
  }
}

// ==========================================
// 3. PRESENTATION: Micro-Friction Gate UI
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
      backgroundColor: const Color(0xFF0F0F12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'GATE ACTIVE: ${widget.targetAppName.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    'Mistakes: ${_state.totalMistakes}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Dopamine Intercept',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Type the philosophical reflection verbatim to pass. Any typo resets the word. Copy-paste is disabled.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _state.progressPercentage,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _state.progressPercentage == 1.0 ? Colors.greenAccent : const Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17171C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _showShakeAnimation
                          ? Colors.redAccent
                          : Colors.white.withValues(alpha: 0.07),
                      width: _showShakeAnimation ? 2 : 1,
                    ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFF6366F1).withValues(alpha: 0.25)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: isCurrent
                                ? Border.all(color: const Color(0xFF6366F1), width: 1)
                                : null,
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'monospace',
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                              color: isPassed
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : isCurrent
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E24),
                  hintText: 'Type current word followed by space...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                    fontFamily: 'sans-serif',
                  ),
                  prefixIcon: const Icon(Icons.keyboard_outlined, color: Color(0xFF6366F1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                  ),
                ),
                onChanged: _onTextChanged,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  'Close & Return to Productive Work',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
