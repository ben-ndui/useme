import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/models/payment_method.dart';

void main() {
  group('PaymentMethodType', () {
    test('label returns correct French labels', () {
      expect(PaymentMethodType.cash.label, 'Espèces');
      expect(PaymentMethodType.bankTransfer.label, 'Virement bancaire');
      expect(PaymentMethodType.paypal.label, 'PayPal');
      expect(PaymentMethodType.card.label, 'Carte bancaire');
      expect(PaymentMethodType.other.label, 'Autre');
    });

    test('icon returns correct icon names', () {
      expect(PaymentMethodType.cash.icon, 'moneyBill');
      expect(PaymentMethodType.bankTransfer.icon, 'buildingColumns');
      expect(PaymentMethodType.paypal.icon, 'paypal');
      expect(PaymentMethodType.card.icon, 'creditCard');
      expect(PaymentMethodType.other.icon, 'ellipsis');
    });
  });

  group('PaymentMethod', () {
    test('default isEnabled is true', () {
      const method = PaymentMethod(type: PaymentMethodType.cash);
      expect(method.isEnabled, isTrue);
    });

    test('fromMap / toMap round-trip', () {
      const method = PaymentMethod(
        type: PaymentMethodType.bankTransfer,
        isEnabled: true,
        details: 'FR76 1234 5678 9012',
        instructions: 'Reference: session ID',
        bic: 'BNPAFRPP',
        accountHolder: 'Studio ABC',
        bankName: 'BNP Paribas',
      );

      final map = method.toMap();
      final restored = PaymentMethod.fromMap(map);

      expect(restored.type, PaymentMethodType.bankTransfer);
      expect(restored.isEnabled, isTrue);
      expect(restored.details, 'FR76 1234 5678 9012');
      expect(restored.bic, 'BNPAFRPP');
      expect(restored.accountHolder, 'Studio ABC');
      expect(restored.bankName, 'BNP Paribas');
      expect(restored.instructions, 'Reference: session ID');
    });

    test('fromMap handles unknown type gracefully', () {
      final method = PaymentMethod.fromMap({'type': 'crypto'});
      expect(method.type, PaymentMethodType.other);
    });

    test('fromMap handles missing isEnabled', () {
      final method = PaymentMethod.fromMap({
        'type': 'cash',
      });
      expect(method.isEnabled, isTrue);
    });

    test('copyWith creates modified copy', () {
      const original = PaymentMethod(
        type: PaymentMethodType.cash,
        isEnabled: true,
      );
      final disabled = original.copyWith(isEnabled: false);
      expect(disabled.isEnabled, isFalse);
      expect(disabled.type, PaymentMethodType.cash);
    });

    test('equality via Equatable', () {
      const a = PaymentMethod(type: PaymentMethodType.paypal, details: 'a@b.com');
      const b = PaymentMethod(type: PaymentMethodType.paypal, details: 'a@b.com');
      const c = PaymentMethod(type: PaymentMethodType.paypal, details: 'x@y.com');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('CancellationPolicy', () {
    test('label and description for all values', () {
      for (final policy in CancellationPolicy.values) {
        expect(policy.label, isNotEmpty);
        expect(policy.description, isNotEmpty);
      }
    });

    test('specific labels', () {
      expect(CancellationPolicy.flexible.label, 'Flexible');
      expect(CancellationPolicy.moderate.label, 'Modérée');
      expect(CancellationPolicy.strict.label, 'Stricte');
      expect(CancellationPolicy.custom.label, 'Personnalisée');
    });
  });

  group('StudioPaymentConfig', () {
    test('default config has empty methods', () {
      const config = StudioPaymentConfig();
      expect(config.methods, isEmpty);
      expect(config.defaultDepositPercent, isNull);
      expect(config.cancellationPolicy, CancellationPolicy.moderate);
    });

    test('enabledMethods filters disabled', () {
      const config = StudioPaymentConfig(
        methods: [
          PaymentMethod(type: PaymentMethodType.cash, isEnabled: true),
          PaymentMethod(type: PaymentMethodType.paypal, isEnabled: false),
          PaymentMethod(type: PaymentMethodType.card, isEnabled: true),
        ],
      );
      expect(config.enabledMethods.length, 2);
      expect(config.enabledMethods.map((m) => m.type),
          containsAll([PaymentMethodType.cash, PaymentMethodType.card]));
    });

    test('defaultMethod returns specified default', () {
      const config = StudioPaymentConfig(
        methods: [
          PaymentMethod(type: PaymentMethodType.cash, isEnabled: true),
          PaymentMethod(type: PaymentMethodType.paypal, isEnabled: true),
        ],
        defaultPaymentMethod: PaymentMethodType.paypal,
      );
      expect(config.defaultMethod?.type, PaymentMethodType.paypal);
    });

    test('defaultMethod falls back to first enabled', () {
      const config = StudioPaymentConfig(
        methods: [
          PaymentMethod(type: PaymentMethodType.cash, isEnabled: true),
          PaymentMethod(type: PaymentMethodType.paypal, isEnabled: true),
        ],
      );
      expect(config.defaultMethod?.type, PaymentMethodType.cash);
    });

    test('defaultMethod returns null when no methods', () {
      const config = StudioPaymentConfig();
      expect(config.defaultMethod, isNull);
    });

    test('defaultMethod skips disabled default', () {
      const config = StudioPaymentConfig(
        methods: [
          PaymentMethod(type: PaymentMethodType.cash, isEnabled: true),
          PaymentMethod(type: PaymentMethodType.paypal, isEnabled: false),
        ],
        defaultPaymentMethod: PaymentMethodType.paypal,
      );
      // PayPal is disabled, falls back to first enabled (cash)
      expect(config.defaultMethod?.type, PaymentMethodType.cash);
    });

    test('fromMap / toMap round-trip', () {
      const config = StudioPaymentConfig(
        methods: [
          PaymentMethod(type: PaymentMethodType.cash),
        ],
        defaultDepositPercent: 30.0,
        paymentTerms: 'Due before session',
        defaultPaymentMethod: PaymentMethodType.cash,
        cancellationPolicy: CancellationPolicy.strict,
        customCancellationTerms: 'No refund',
      );

      final map = config.toMap();
      final restored = StudioPaymentConfig.fromMap(map);

      expect(restored.methods.length, 1);
      expect(restored.defaultDepositPercent, 30.0);
      expect(restored.paymentTerms, 'Due before session');
      expect(restored.defaultPaymentMethod, PaymentMethodType.cash);
      expect(restored.cancellationPolicy, CancellationPolicy.strict);
      expect(restored.customCancellationTerms, 'No refund');
    });

    test('fromMap handles null', () {
      final config = StudioPaymentConfig.fromMap(null);
      expect(config.methods, isEmpty);
      expect(config.cancellationPolicy, CancellationPolicy.moderate);
    });

    test('copyWith', () {
      const config = StudioPaymentConfig(defaultDepositPercent: 20);
      final updated = config.copyWith(defaultDepositPercent: 50);
      expect(updated.defaultDepositPercent, 50);
    });
  });
}
