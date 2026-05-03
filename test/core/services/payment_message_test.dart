import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uzme/core/models/payment_method.dart';
import 'package:uzme/core/services/encryption_service.dart';
import 'package:uzme/core/services/payment_config_service.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockFunctions extends Mock implements FirebaseFunctions {}

class MockEncryptionService extends Mock implements EncryptionService {}

void main() {
  late PaymentConfigService service;

  setUp(() {
    service = PaymentConfigService(
      firestore: MockFirestore(),
      functions: MockFunctions(),
      encryptionService: MockEncryptionService(),
    );
  });

  group('generatePaymentMessageLocal', () {
    test('contains session title and date', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Recording - DJ Test',
        sessionDate: DateTime(2026, 3, 15),
        totalAmount: 200,
        depositAmount: 60,
        paymentMethod: const PaymentMethod(type: PaymentMethodType.cash),
      );

      expect(msg, contains('Recording - DJ Test'));
      expect(msg, contains('15/3/2026'));
    });

    test('contains amounts formatted with 2 decimals', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 150.5,
        depositAmount: 45.00,
        paymentMethod: const PaymentMethod(type: PaymentMethodType.cash),
      );

      expect(msg, contains('150.50'));
      expect(msg, contains('45.00'));
    });

    test('contains payment method label', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        depositAmount: 30,
        paymentMethod: const PaymentMethod(type: PaymentMethodType.bankTransfer),
      );

      expect(msg, contains('Virement bancaire'));
    });

    test('includes IBAN details for bank transfer', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        depositAmount: 30,
        paymentMethod: const PaymentMethod(
          type: PaymentMethodType.bankTransfer,
          details: 'FR76 1234 5678 9012',
          bic: 'BNPAFRPP',
          accountHolder: 'Studio ABC',
          bankName: 'BNP Paribas',
        ),
      );

      expect(msg, contains('IBAN: FR76 1234 5678 9012'));
      expect(msg, contains('BIC: BNPAFRPP'));
      expect(msg, contains('Titulaire: Studio ABC'));
      expect(msg, contains('Banque: BNP Paribas'));
    });

    test('includes PayPal email for paypal', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        depositAmount: 30,
        paymentMethod: const PaymentMethod(
          type: PaymentMethodType.paypal,
          details: 'studio@paypal.com',
        ),
      );

      expect(msg, contains('PayPal: studio@paypal.com'));
    });

    test('includes generic details for other types', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        depositAmount: 30,
        paymentMethod: const PaymentMethod(
          type: PaymentMethodType.other,
          details: 'Lydia: 06 12 34 56 78',
        ),
      );

      expect(msg, contains('Lydia: 06 12 34 56 78'));
    });

    test('omits details section when details is null', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        depositAmount: 30,
        paymentMethod: const PaymentMethod(type: PaymentMethodType.cash),
      );

      expect(msg, isNot(contains('IBAN')));
      expect(msg, isNot(contains('PayPal:')));
    });

    test('omits details section when details is empty', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        depositAmount: 30,
        paymentMethod: const PaymentMethod(
          type: PaymentMethodType.bankTransfer,
          details: '',
        ),
      );

      expect(msg, isNot(contains('IBAN')));
    });

    test('includes instructions when present', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        depositAmount: 30,
        paymentMethod: const PaymentMethod(
          type: PaymentMethodType.cash,
          instructions: 'Payer en arrivant au studio',
        ),
      );

      expect(msg, contains('Instructions: Payer en arrivant au studio'));
    });

    test('omits instructions when null', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        depositAmount: 30,
        paymentMethod: const PaymentMethod(type: PaymentMethodType.cash),
      );

      expect(msg, isNot(contains('Instructions')));
    });

    test('omits BIC/holder/bank when empty for bank transfer', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        depositAmount: 30,
        paymentMethod: const PaymentMethod(
          type: PaymentMethodType.bankTransfer,
          details: 'FR76 1234',
          bic: '',
          accountHolder: '',
          bankName: '',
        ),
      );

      expect(msg, contains('IBAN: FR76 1234'));
      expect(msg, isNot(contains('BIC:')));
      expect(msg, isNot(contains('Titulaire:')));
      expect(msg, isNot(contains('Banque:')));
    });

    test('ends with confirmation message', () {
      final msg = service.generatePaymentMessageLocal(
        sessionTitle: 'Mix',
        sessionDate: DateTime(2026, 1, 1),
        totalAmount: 100,
        depositAmount: 30,
        paymentMethod: const PaymentMethod(type: PaymentMethodType.cash),
      );

      expect(msg, contains('Merci de régler'));
    });
  });
}
