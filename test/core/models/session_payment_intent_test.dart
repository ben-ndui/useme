import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/models/session_payment_intent.dart';

void main() {
  group('SessionPaymentIntent', () {
    const intent = SessionPaymentIntent(
      clientSecret: 'pi_secret_123',
      ephemeralKey: 'ek_test_123',
      customerId: 'cus_123',
      publishableKey: 'pk_test_123',
      paymentIntentId: 'pi_123',
      sessionId: 'sess_abc',
      amountCents: 5000,
      isDeposit: true,
    );

    test('props returns all fields', () {
      expect(intent.props, [
        'pi_secret_123',
        'ek_test_123',
        'cus_123',
        'pk_test_123',
        'pi_123',
        'sess_abc',
        5000,
        true,
      ]);
    });

    test('two intents with same values are equal', () {
      const intent2 = SessionPaymentIntent(
        clientSecret: 'pi_secret_123',
        ephemeralKey: 'ek_test_123',
        customerId: 'cus_123',
        publishableKey: 'pk_test_123',
        paymentIntentId: 'pi_123',
        sessionId: 'sess_abc',
        amountCents: 5000,
        isDeposit: true,
      );
      expect(intent, equals(intent2));
    });

    test('fromMap creates correct instance', () {
      final map = {
        'clientSecret': 'pi_secret_456',
        'ephemeralKey': 'ek_test_456',
        'customer': 'cus_456',
        'publishableKey': 'pk_test_456',
        'paymentIntentId': 'pi_456',
      };

      final result = SessionPaymentIntent.fromMap(
        map,
        sessionId: 'sess_xyz',
        amountCents: 3000,
        isDeposit: false,
      );

      expect(result.clientSecret, 'pi_secret_456');
      expect(result.ephemeralKey, 'ek_test_456');
      expect(result.customerId, 'cus_456');
      expect(result.publishableKey, 'pk_test_456');
      expect(result.paymentIntentId, 'pi_456');
      expect(result.sessionId, 'sess_xyz');
      expect(result.amountCents, 3000);
      expect(result.isDeposit, false);
    });

    test('fromMap handles null publishableKey', () {
      final map = {
        'clientSecret': 'pi_secret_789',
        'ephemeralKey': 'ek_test_789',
        'customer': 'cus_789',
        'publishableKey': null,
        'paymentIntentId': 'pi_789',
      };

      final result = SessionPaymentIntent.fromMap(
        map,
        sessionId: 'sess_001',
        amountCents: 1000,
        isDeposit: true,
      );

      expect(result.publishableKey, isNull);
    });
  });
}
