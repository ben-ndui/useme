import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/blocs/card_config/card_config_exports.dart';
import 'package:uzme/core/models/card_config.dart';

void main() {
  group('CardConfigState', () {
    test('initial state has default config', () {
      const state = CardConfigState();
      expect(state.config, const CardConfig());
      expect(state.isLoading, isFalse);
      expect(state.isSaving, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.successMessage, isNull);
    });

    test('copyWith preserves unmodified fields', () {
      const state = CardConfigState(
        config: CardConfig(preset: CardThemePreset.dark),
        isLoading: true,
      );
      final modified = state.copyWith(isLoading: false);
      expect(modified.config.preset, CardThemePreset.dark);
      expect(modified.isLoading, isFalse);
    });

    test('copyWith clearError removes error message', () {
      const state = CardConfigState(errorMessage: 'some error');
      final modified = state.copyWith(clearError: true);
      expect(modified.errorMessage, isNull);
    });

    test('copyWith clearSuccess removes success message', () {
      const state = CardConfigState(successMessage: 'saved');
      final modified = state.copyWith(clearSuccess: true);
      expect(modified.successMessage, isNull);
    });

    test('isLoaded is true when not loading', () {
      const state = CardConfigState(isLoading: false);
      expect(state.isLoaded, isTrue);
    });

    test('isLoaded is false when loading', () {
      const state = CardConfigState(isLoading: true);
      expect(state.isLoaded, isFalse);
    });
  });

  group('CardConfigEvent', () {
    test('LoadCardConfigEvent equality', () {
      const a = LoadCardConfigEvent(userId: 'uid1');
      const b = LoadCardConfigEvent(userId: 'uid1');
      const c = LoadCardConfigEvent(userId: 'uid2');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('SaveCardConfigEvent equality', () {
      const config = CardConfig(preset: CardThemePreset.neon);
      const a = SaveCardConfigEvent(userId: 'uid1', config: config);
      const b = SaveCardConfigEvent(userId: 'uid1', config: config);
      expect(a, equals(b));
    });

    test('ResetCardConfigEvent equality', () {
      const a = ResetCardConfigEvent(userId: 'uid1');
      const b = ResetCardConfigEvent(userId: 'uid1');
      expect(a, equals(b));
    });

    test('ClearCardConfigEvent props are empty', () {
      const event = ClearCardConfigEvent();
      expect(event.props, isEmpty);
    });
  });
}
