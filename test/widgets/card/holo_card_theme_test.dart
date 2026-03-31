import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/card_config.dart';
import 'package:useme/widgets/card/holo_card_theme.dart';

void main() {
  group('HoloCardTheme', () {
    test('studio role returns blue theme', () {
      final theme = HoloCardTheme.forRole(BaseUserRole.admin);
      expect(theme.roleLabel, 'Studio');
      expect(theme.primaryColor, const Color(0xFF0B38BF));
    });

    test('superAdmin returns studio theme', () {
      final theme = HoloCardTheme.forRole(BaseUserRole.superAdmin);
      expect(theme.roleLabel, 'Studio');
    });

    test('engineer role returns turquoise theme', () {
      final theme = HoloCardTheme.forRole(BaseUserRole.worker);
      expect(theme.roleLabel, 'Engineer');
      expect(theme.primaryColor, const Color(0xFF00CEC9));
    });

    test('artist role returns purple theme', () {
      final theme = HoloCardTheme.forRole(BaseUserRole.client);
      expect(theme.roleLabel, 'Artist');
      expect(theme.primaryColor, const Color(0xFF8B5CF6));
    });

    test('pioneer override changes accent and glow to gold', () {
      final theme =
          HoloCardTheme.forRole(BaseUserRole.client, isPioneer: true);
      expect(theme.accentColor, const Color(0xFFFFD700));
      expect(theme.glowColor, const Color(0xFFFFA500));
      expect(theme.primaryColor, const Color(0xFF8B5CF6));
      expect(theme.roleLabel, 'Artist');
    });

    test('non-pioneer keeps default accent', () {
      final theme =
          HoloCardTheme.forRole(BaseUserRole.client, isPioneer: false);
      expect(theme.accentColor, const Color(0xFFC4B5FD));
    });

    test('holoRainbow has 7 colors forming a loop', () {
      expect(HoloCardTheme.holoRainbow.length, 7);
      expect(
          HoloCardTheme.holoRainbow.first, HoloCardTheme.holoRainbow.last);
    });
  });

  group('HoloCardTheme.fromConfig', () {
    test('defaultRole preset falls back to role theme', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(),
        role: BaseUserRole.worker,
        isPioneer: false,
      );
      expect(theme.roleLabel, 'Engineer');
      expect(theme.primaryColor, const Color(0xFF00CEC9));
    });

    test('dark preset applies dark theme', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(preset: CardThemePreset.dark),
        role: BaseUserRole.client,
        isPioneer: false,
      );
      expect(theme.primaryColor, const Color(0xFF1A1A2E));
      expect(theme.accentColor, const Color(0xFFE94560));
      expect(theme.roleLabel, 'Artist');
    });

    test('light preset applies light theme', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(preset: CardThemePreset.light),
        role: BaseUserRole.admin,
        isPioneer: false,
      );
      expect(theme.primaryColor, const Color(0xFFE8E8E8));
      expect(theme.roleLabel, 'Studio');
    });

    test('neon preset applies neon theme', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(preset: CardThemePreset.neon),
        role: BaseUserRole.worker,
        isPioneer: false,
      );
      expect(theme.primaryColor, const Color(0xFF0D0221));
      expect(theme.accentColor, const Color(0xFF00FF87));
    });

    test('minimal preset applies minimal theme', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(preset: CardThemePreset.minimal),
        role: BaseUserRole.client,
        isPioneer: false,
      );
      expect(theme.primaryColor, const Color(0xFF2C3E50));
      expect(theme.accentColor, const Color(0xFFBDC3C7));
    });

    test('holographicPro preset applies premium theme', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(preset: CardThemePreset.holographicPro),
        role: BaseUserRole.client,
        isPioneer: false,
      );
      expect(theme.primaryColor, const Color(0xFF1A0033));
      expect(theme.accentColor, const Color(0xFFE040FB));
    });

    test('carbon preset applies premium theme', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(preset: CardThemePreset.carbon),
        role: BaseUserRole.admin,
        isPioneer: false,
      );
      expect(theme.primaryColor, const Color(0xFF1C1C1C));
      expect(theme.accentColor, const Color(0xFFCFD8DC));
    });

    test('gold preset applies premium theme', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(preset: CardThemePreset.gold),
        role: BaseUserRole.worker,
        isPioneer: false,
      );
      expect(theme.primaryColor, const Color(0xFF1A1205));
      expect(theme.accentColor, const Color(0xFFFFD700));
    });

    test('galaxy preset applies premium theme', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(preset: CardThemePreset.galaxy),
        role: BaseUserRole.client,
        isPioneer: false,
      );
      expect(theme.primaryColor, const Color(0xFF0B0C2A));
      expect(theme.accentColor, const Color(0xFF7C4DFF));
    });

    test('custom accent overrides theme accent and glow', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(
          preset: CardThemePreset.dark,
          accentColorValue: 0xFF00FF87,
        ),
        role: BaseUserRole.client,
        isPioneer: false,
      );
      expect(theme.primaryColor, const Color(0xFF1A1A2E));
      expect(theme.accentColor, const Color(0xFF00FF87));
      expect(theme.glowColor, const Color(0xFF00FF87));
    });

    test('defaultRole with pioneer applies gold accent', () {
      final theme = HoloCardTheme.fromConfig(
        config: const CardConfig(),
        role: BaseUserRole.admin,
        isPioneer: true,
      );
      expect(theme.accentColor, const Color(0xFFFFD700));
    });

    test('presetPreviewColors returns 2 colors per preset', () {
      for (final preset in CardThemePreset.values) {
        final colors = HoloCardTheme.presetPreviewColors(preset);
        expect(colors.length, 2, reason: '$preset should have 2 colors');
      }
    });
  });
}
