import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/card_config.dart';

void main() {
  group('CardConfig', () {
    test('default config has expected values', () {
      const config = CardConfig();
      expect(config.preset, CardThemePreset.defaultRole);
      expect(config.accentColorValue, isNull);
      expect(config.accentColor, isNull);
      expect(config.backgroundPattern, CardBackgroundPattern.none);
      expect(config.backgroundImageUrl, isNull);
      expect(config.isDefault, isTrue);
      expect(config.usesPremium, isFalse);
    });

    test('isDefault returns false when preset is changed', () {
      const config = CardConfig(preset: CardThemePreset.dark);
      expect(config.isDefault, isFalse);
    });

    test('isDefault returns false when accent color is set', () {
      const config = CardConfig(accentColorValue: 0xFFFF0000);
      expect(config.isDefault, isFalse);
    });

    test('isDefault returns false when pattern is set', () {
      const config =
          CardConfig(backgroundPattern: CardBackgroundPattern.waves);
      expect(config.isDefault, isFalse);
    });

    test('isDefault returns false when backgroundImageUrl is set', () {
      const config = CardConfig(backgroundImageUrl: 'https://example.com/bg.jpg');
      expect(config.isDefault, isFalse);
    });

    test('accentColor returns correct Color from int', () {
      const config = CardConfig(accentColorValue: 0xFFFF6B6B);
      expect(config.accentColor, const Color(0xFFFF6B6B));
    });

    test('fromMap creates correct config', () {
      final config = CardConfig.fromMap({
        'preset': 'neon',
        'accentColorValue': 0xFF00FF87,
        'backgroundPattern': 'dots',
        'backgroundImageUrl': 'https://example.com/bg.jpg',
      });
      expect(config.preset, CardThemePreset.neon);
      expect(config.accentColorValue, 0xFF00FF87);
      expect(config.backgroundPattern, CardBackgroundPattern.dots);
      expect(config.backgroundImageUrl, 'https://example.com/bg.jpg');
    });

    test('fromMap handles missing fields gracefully', () {
      final config = CardConfig.fromMap({});
      expect(config.preset, CardThemePreset.defaultRole);
      expect(config.accentColorValue, isNull);
      expect(config.backgroundPattern, CardBackgroundPattern.none);
      expect(config.backgroundImageUrl, isNull);
    });

    test('fromMap handles unknown enum values', () {
      final config = CardConfig.fromMap({
        'preset': 'unknown_preset',
        'backgroundPattern': 'unknown_pattern',
      });
      expect(config.preset, CardThemePreset.defaultRole);
      expect(config.backgroundPattern, CardBackgroundPattern.none);
    });

    test('fromMap parses premium presets', () {
      final config = CardConfig.fromMap({'preset': 'holographicPro'});
      expect(config.preset, CardThemePreset.holographicPro);
    });

    test('toMap serializes correctly', () {
      const config = CardConfig(
        preset: CardThemePreset.dark,
        accentColorValue: 0xFFE94560,
        backgroundPattern: CardBackgroundPattern.gradient,
        backgroundImageUrl: 'https://example.com/bg.jpg',
      );
      final map = config.toMap();
      expect(map['preset'], 'dark');
      expect(map['accentColorValue'], 0xFFE94560);
      expect(map['backgroundPattern'], 'gradient');
      expect(map['backgroundImageUrl'], 'https://example.com/bg.jpg');
    });

    test('toMap omits null optional fields', () {
      const config = CardConfig(preset: CardThemePreset.light);
      final map = config.toMap();
      expect(map.containsKey('accentColorValue'), isFalse);
      expect(map.containsKey('backgroundImageUrl'), isFalse);
    });

    test('copyWith works correctly', () {
      const original = CardConfig(
        preset: CardThemePreset.dark,
        accentColorValue: 0xFFFF0000,
        backgroundPattern: CardBackgroundPattern.waves,
      );

      final modified = original.copyWith(preset: CardThemePreset.neon);
      expect(modified.preset, CardThemePreset.neon);
      expect(modified.accentColorValue, 0xFFFF0000);
      expect(modified.backgroundPattern, CardBackgroundPattern.waves);
    });

    test('copyWith clearAccentColor removes accent color', () {
      const original = CardConfig(accentColorValue: 0xFFFF0000);
      final modified = original.copyWith(clearAccentColor: true);
      expect(modified.accentColorValue, isNull);
    });

    test('copyWith clearBackgroundImage removes image URL', () {
      const original =
          CardConfig(backgroundImageUrl: 'https://example.com/bg.jpg');
      final modified = original.copyWith(clearBackgroundImage: true);
      expect(modified.backgroundImageUrl, isNull);
    });

    test('Equatable works for identical configs', () {
      const a = CardConfig(preset: CardThemePreset.dark);
      const b = CardConfig(preset: CardThemePreset.dark);
      expect(a, equals(b));
    });

    test('Equatable works for different configs', () {
      const a = CardConfig(preset: CardThemePreset.dark);
      const b = CardConfig(preset: CardThemePreset.neon);
      expect(a, isNot(equals(b)));
    });

    test('roundtrip fromMap/toMap preserves data', () {
      const original = CardConfig(
        preset: CardThemePreset.minimal,
        accentColorValue: 0xFFBDC3C7,
        backgroundPattern: CardBackgroundPattern.dots,
        backgroundImageUrl: 'https://example.com/bg.jpg',
      );
      final roundtripped = CardConfig.fromMap(original.toMap());
      expect(roundtripped, equals(original));
    });
  });

  group('CardThemePreset.isPremium', () {
    test('free presets are not premium', () {
      expect(CardThemePreset.defaultRole.isPremium, isFalse);
      expect(CardThemePreset.dark.isPremium, isFalse);
      expect(CardThemePreset.light.isPremium, isFalse);
      expect(CardThemePreset.neon.isPremium, isFalse);
      expect(CardThemePreset.minimal.isPremium, isFalse);
    });

    test('premium presets are premium', () {
      expect(CardThemePreset.holographicPro.isPremium, isTrue);
      expect(CardThemePreset.carbon.isPremium, isTrue);
      expect(CardThemePreset.gold.isPremium, isTrue);
      expect(CardThemePreset.galaxy.isPremium, isTrue);
    });
  });

  group('CardConfig.usesPremium', () {
    test('free preset without image is not premium', () {
      const config = CardConfig(preset: CardThemePreset.dark);
      expect(config.usesPremium, isFalse);
    });

    test('premium preset is premium', () {
      const config = CardConfig(preset: CardThemePreset.gold);
      expect(config.usesPremium, isTrue);
    });

    test('background image makes config premium', () {
      const config = CardConfig(
        backgroundImageUrl: 'https://example.com/bg.jpg',
      );
      expect(config.usesPremium, isTrue);
    });
  });
}
