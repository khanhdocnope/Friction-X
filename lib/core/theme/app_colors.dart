import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF07080C);
  static const Color surface = Color(0xFF0F111A);
  static const Color surfaceCard = Color(0xFF151824);
  static const Color surfaceGlass = Color(0x1AFFFFFF);

  // Accents & Neons
  static const Color cyberIndigo = Color(0xFF6366F1);
  static const Color electricViolet = Color(0xFF8B5CF6);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonCrimson = Color(0xFFFF2E5B);
  static const Color cyberRed = Color(0xFFEF4444);
  static const Color toxicAmber = Color(0xFFF59E0B);
  static const Color neonGreen = Color(0xFF10B981);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyberIndigo, electricViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [neonCrimson, cyberRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [toxicAmber, Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
