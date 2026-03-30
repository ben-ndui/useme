import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
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
      final theme = HoloCardTheme.forRole(BaseUserRole.client, isPioneer: true);
      expect(theme.accentColor, const Color(0xFFFFD700));
      expect(theme.glowColor, const Color(0xFFFFA500));
      // Primary stays the same
      expect(theme.primaryColor, const Color(0xFF8B5CF6));
      expect(theme.roleLabel, 'Artist');
    });

    test('non-pioneer keeps default accent', () {
      final theme = HoloCardTheme.forRole(BaseUserRole.client, isPioneer: false);
      expect(theme.accentColor, const Color(0xFFC4B5FD));
    });

    test('holoRainbow has 7 colors forming a loop', () {
      expect(HoloCardTheme.holoRainbow.length, 7);
      // First and last should be the same for seamless gradient
      expect(HoloCardTheme.holoRainbow.first, HoloCardTheme.holoRainbow.last);
    });
  });
}
