import 'package:useme/core/models/payment_method.dart';

/// Calculates the refund amount based on cancellation policy and timing.
class RefundCalculation {
  final double originalAmount;
  final double refundAmount;
  final int refundPercent;
  final CancellationPolicy policy;
  final Duration timeUntilSession;
  final bool isCancelledByStudio;

  const RefundCalculation({
    required this.originalAmount,
    required this.refundAmount,
    required this.refundPercent,
    required this.policy,
    required this.timeUntilSession,
    required this.isCancelledByStudio,
  });

  /// Calculate refund based on policy, timing, and who cancels.
  factory RefundCalculation.calculate({
    required double amountPaid,
    required CancellationPolicy policy,
    required DateTime sessionStart,
    required bool isCancelledByStudio,
  }) {
    final timeUntil = sessionStart.difference(DateTime.now());

    // Studio/pro cancels → always 100% refund
    if (isCancelledByStudio) {
      return RefundCalculation(
        originalAmount: amountPaid,
        refundAmount: amountPaid,
        refundPercent: 100,
        policy: policy,
        timeUntilSession: timeUntil,
        isCancelledByStudio: true,
      );
    }

    // No payment → nothing to refund
    if (amountPaid <= 0) {
      return RefundCalculation(
        originalAmount: 0,
        refundAmount: 0,
        refundPercent: 0,
        policy: policy,
        timeUntilSession: timeUntil,
        isCancelledByStudio: false,
      );
    }

    final hours = timeUntil.inHours;
    int percent = 0;

    switch (policy) {
      case CancellationPolicy.flexible:
        percent = hours >= 24 ? 100 : 0;
        break;
      case CancellationPolicy.moderate:
        if (hours >= 48) {
          percent = 100;
        } else if (hours >= 24) {
          percent = 50;
        } else {
          percent = 0;
        }
        break;
      case CancellationPolicy.strict:
        percent = 0;
        break;
      case CancellationPolicy.custom:
        // Custom defaults to moderate rules
        if (hours >= 48) {
          percent = 100;
        } else if (hours >= 24) {
          percent = 50;
        } else {
          percent = 0;
        }
        break;
    }

    return RefundCalculation(
      originalAmount: amountPaid,
      refundAmount: amountPaid * percent / 100,
      refundPercent: percent,
      policy: policy,
      timeUntilSession: timeUntil,
      isCancelledByStudio: false,
    );
  }

  bool get hasRefund => refundAmount > 0;
  bool get isFullRefund => refundPercent == 100;
  bool get isPartialRefund => refundPercent > 0 && refundPercent < 100;
}
