import 'package:flutter/material.dart';

class GlowingCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isGlowing;

  const GlowingCard({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF6366F1),
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.isGlowing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13151F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGlowing ? glowColor.withOpacity(0.35) : Colors.white.withOpacity(0.06),
          width: 1.2,
        ),
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.12),
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
