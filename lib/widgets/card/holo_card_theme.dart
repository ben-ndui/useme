import 'package:flutter/material.dart';
import 'package:smoothandesign_package/smoothandesign.dart';

/// Role-based color themes for the holographic digital card.
class HoloCardTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color glowColor;
  final String roleLabel;

  const HoloCardTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.glowColor,
    required this.roleLabel,
  });

  factory HoloCardTheme.forRole(BaseUserRole role, {bool isPioneer = false}) {
    final base = switch (role) {
      BaseUserRole.admin || BaseUserRole.superAdmin => const HoloCardTheme(
          primaryColor: Color(0xFF0B38BF),
          secondaryColor: Color(0xFF3B5FC7),
          accentColor: Color(0xFF74B9FF),
          glowColor: Color(0xFF3B82F6),
          roleLabel: 'Studio',
        ),
      BaseUserRole.worker => const HoloCardTheme(
          primaryColor: Color(0xFF00CEC9),
          secondaryColor: Color(0xFF00B894),
          accentColor: Color(0xFF81ECEC),
          glowColor: Color(0xFF00CEC9),
          roleLabel: 'Engineer',
        ),
      _ => const HoloCardTheme(
          primaryColor: Color(0xFF8B5CF6),
          secondaryColor: Color(0xFFA78BFA),
          accentColor: Color(0xFFC4B5FD),
          glowColor: Color(0xFF8B5CF6),
          roleLabel: 'Artist',
        ),
    };

    if (!isPioneer) return base;

    return HoloCardTheme(
      primaryColor: base.primaryColor,
      secondaryColor: base.secondaryColor,
      accentColor: const Color(0xFFFFD700),
      glowColor: const Color(0xFFFFA500),
      roleLabel: base.roleLabel,
    );
  }

  /// The rainbow colors used for the holographic sweep gradient.
  static const List<Color> holoRainbow = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF4ECDC4),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFFF6B6B),
  ];
}
