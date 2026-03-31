import 'package:flutter/material.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/card_config.dart';

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

  /// Build a theme from a CardConfig, falling back to role-based defaults.
  factory HoloCardTheme.fromConfig({
    required CardConfig config,
    required BaseUserRole role,
    required bool isPioneer,
  }) {
    // Start with preset base
    final base = config.preset == CardThemePreset.defaultRole
        ? HoloCardTheme.forRole(role, isPioneer: isPioneer)
        : _presetTheme(config.preset, role);

    // Apply custom accent color override
    final accent = config.accentColor;
    if (accent == null) return base;

    return HoloCardTheme(
      primaryColor: base.primaryColor,
      secondaryColor: base.secondaryColor,
      accentColor: accent,
      glowColor: accent,
      roleLabel: base.roleLabel,
    );
  }

  /// Returns the theme for a given preset.
  static HoloCardTheme _presetTheme(CardThemePreset preset, BaseUserRole role) {
    final roleLabel = switch (role) {
      BaseUserRole.admin || BaseUserRole.superAdmin => 'Studio',
      BaseUserRole.worker => 'Engineer',
      _ => 'Artist',
    };

    return switch (preset) {
      CardThemePreset.dark => HoloCardTheme(
          primaryColor: const Color(0xFF1A1A2E),
          secondaryColor: const Color(0xFF16213E),
          accentColor: const Color(0xFFE94560),
          glowColor: const Color(0xFFE94560),
          roleLabel: roleLabel,
        ),
      CardThemePreset.light => HoloCardTheme(
          primaryColor: const Color(0xFFE8E8E8),
          secondaryColor: const Color(0xFFF5F5F5),
          accentColor: const Color(0xFF2D3436),
          glowColor: const Color(0xFF636E72),
          roleLabel: roleLabel,
        ),
      CardThemePreset.neon => HoloCardTheme(
          primaryColor: const Color(0xFF0D0221),
          secondaryColor: const Color(0xFF150734),
          accentColor: const Color(0xFF00FF87),
          glowColor: const Color(0xFF00FF87),
          roleLabel: roleLabel,
        ),
      CardThemePreset.minimal => HoloCardTheme(
          primaryColor: const Color(0xFF2C3E50),
          secondaryColor: const Color(0xFF34495E),
          accentColor: const Color(0xFFBDC3C7),
          glowColor: const Color(0xFF95A5A6),
          roleLabel: roleLabel,
        ),
      // Premium themes
      CardThemePreset.holographicPro => HoloCardTheme(
          primaryColor: const Color(0xFF1A0033),
          secondaryColor: const Color(0xFF2D1B69),
          accentColor: const Color(0xFFE040FB),
          glowColor: const Color(0xFFE040FB),
          roleLabel: roleLabel,
        ),
      CardThemePreset.carbon => HoloCardTheme(
          primaryColor: const Color(0xFF1C1C1C),
          secondaryColor: const Color(0xFF2A2A2A),
          accentColor: const Color(0xFFCFD8DC),
          glowColor: const Color(0xFF90A4AE),
          roleLabel: roleLabel,
        ),
      CardThemePreset.gold => HoloCardTheme(
          primaryColor: const Color(0xFF1A1205),
          secondaryColor: const Color(0xFF2C1E0A),
          accentColor: const Color(0xFFFFD700),
          glowColor: const Color(0xFFFFA000),
          roleLabel: roleLabel,
        ),
      CardThemePreset.galaxy => HoloCardTheme(
          primaryColor: const Color(0xFF0B0C2A),
          secondaryColor: const Color(0xFF1B1464),
          accentColor: const Color(0xFF7C4DFF),
          glowColor: const Color(0xFF651FFF),
          roleLabel: roleLabel,
        ),
      CardThemePreset.defaultRole => throw StateError('Handled above'),
    };
  }

  /// Preview colors for each preset (used in the editor UI).
  static List<Color> presetPreviewColors(CardThemePreset preset) {
    return switch (preset) {
      CardThemePreset.defaultRole => [
          const Color(0xFF0B38BF),
          const Color(0xFF74B9FF),
        ],
      CardThemePreset.dark => [
          const Color(0xFF1A1A2E),
          const Color(0xFFE94560),
        ],
      CardThemePreset.light => [
          const Color(0xFFE8E8E8),
          const Color(0xFF2D3436),
        ],
      CardThemePreset.neon => [
          const Color(0xFF0D0221),
          const Color(0xFF00FF87),
        ],
      CardThemePreset.minimal => [
          const Color(0xFF2C3E50),
          const Color(0xFFBDC3C7),
        ],
      CardThemePreset.holographicPro => [
          const Color(0xFF1A0033),
          const Color(0xFFE040FB),
        ],
      CardThemePreset.carbon => [
          const Color(0xFF1C1C1C),
          const Color(0xFFCFD8DC),
        ],
      CardThemePreset.gold => [
          const Color(0xFF1A1205),
          const Color(0xFFFFD700),
        ],
      CardThemePreset.galaxy => [
          const Color(0xFF0B0C2A),
          const Color(0xFF7C4DFF),
        ],
    };
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
