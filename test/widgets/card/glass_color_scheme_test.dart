import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:useme/widgets/common/dashboard/glass_color_scheme.dart';

void main() {
  group('glassColorScheme', () {
    late ColorScheme base;
    late ColorScheme glass;

    setUp(() {
      base = ColorScheme.fromSeed(seedColor: Colors.blue);
      glass = glassColorScheme(base);
    });

    test('surface is transparent', () {
      expect(glass.surface, Colors.transparent);
    });

    test('onSurface is white', () {
      expect(glass.onSurface, Colors.white);
    });

    test('onPrimaryContainer is white', () {
      expect(glass.onPrimaryContainer, Colors.white);
    });

    test('preserves base primary color', () {
      expect(glass.primary, base.primary);
    });

    test('surfaceContainerHighest is translucent white', () {
      final c = glass.surfaceContainerHighest;
      expect(c.red, 255);
      expect(c.green, 255);
      expect(c.blue, 255);
    });

    test('outlineVariant is translucent white', () {
      final c = glass.outlineVariant;
      expect(c.red, 255);
      expect(c.green, 255);
      expect(c.blue, 255);
    });
  });
}
