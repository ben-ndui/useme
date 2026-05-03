import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/payment_method.dart';
import 'package:uzme/core/models/refund_calculation.dart';

void main() {
  group('RefundCalculation', () {
    final future25h = DateTime.now().add(const Duration(hours: 25));
    final future49h = DateTime.now().add(const Duration(hours: 49));
    final future23h = DateTime.now().add(const Duration(hours: 23));

    test('studio cancels → always 100% refund', () {
      final r = RefundCalculation.calculate(
        amountPaid: 100,
        policy: CancellationPolicy.strict,
        sessionStart: future23h,
        isCancelledByStudio: true,
      );
      expect(r.refundPercent, 100);
      expect(r.refundAmount, 100);
      expect(r.isFullRefund, true);
    });

    test('flexible + >24h → 100%', () {
      final r = RefundCalculation.calculate(
        amountPaid: 80,
        policy: CancellationPolicy.flexible,
        sessionStart: future25h,
        isCancelledByStudio: false,
      );
      expect(r.refundPercent, 100);
      expect(r.refundAmount, 80);
    });

    test('flexible + <24h → 0%', () {
      final r = RefundCalculation.calculate(
        amountPaid: 80,
        policy: CancellationPolicy.flexible,
        sessionStart: future23h,
        isCancelledByStudio: false,
      );
      expect(r.refundPercent, 0);
      expect(r.refundAmount, 0);
      expect(r.hasRefund, false);
    });

    test('moderate + >48h → 100%', () {
      final r = RefundCalculation.calculate(
        amountPaid: 100,
        policy: CancellationPolicy.moderate,
        sessionStart: future49h,
        isCancelledByStudio: false,
      );
      expect(r.refundPercent, 100);
      expect(r.refundAmount, 100);
    });

    test('moderate + 24-48h → 50%', () {
      final r = RefundCalculation.calculate(
        amountPaid: 100,
        policy: CancellationPolicy.moderate,
        sessionStart: future25h,
        isCancelledByStudio: false,
      );
      expect(r.refundPercent, 50);
      expect(r.refundAmount, 50);
      expect(r.isPartialRefund, true);
    });

    test('moderate + <24h → 0%', () {
      final r = RefundCalculation.calculate(
        amountPaid: 100,
        policy: CancellationPolicy.moderate,
        sessionStart: future23h,
        isCancelledByStudio: false,
      );
      expect(r.refundPercent, 0);
    });

    test('strict → always 0%', () {
      final r = RefundCalculation.calculate(
        amountPaid: 200,
        policy: CancellationPolicy.strict,
        sessionStart: future49h,
        isCancelledByStudio: false,
      );
      expect(r.refundPercent, 0);
      expect(r.refundAmount, 0);
    });

    test('no payment → 0', () {
      final r = RefundCalculation.calculate(
        amountPaid: 0,
        policy: CancellationPolicy.flexible,
        sessionStart: future25h,
        isCancelledByStudio: false,
      );
      expect(r.refundAmount, 0);
      expect(r.hasRefund, false);
    });
  });
}
