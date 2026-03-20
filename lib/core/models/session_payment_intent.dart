import 'package:equatable/equatable.dart';

/// Holds the data returned by the backend after creating a PaymentIntent
/// for a session payment. Used to initialise the Stripe PaymentSheet.
class SessionPaymentIntent extends Equatable {
  final String clientSecret;
  final String ephemeralKey;
  final String customerId;
  final String? publishableKey;
  final String paymentIntentId;
  final String sessionId;
  final int amountCents;
  final bool isDeposit;

  const SessionPaymentIntent({
    required this.clientSecret,
    required this.ephemeralKey,
    required this.customerId,
    this.publishableKey,
    required this.paymentIntentId,
    required this.sessionId,
    required this.amountCents,
    required this.isDeposit,
  });

  factory SessionPaymentIntent.fromMap(
    Map<String, dynamic> map, {
    required String sessionId,
    required int amountCents,
    required bool isDeposit,
  }) {
    return SessionPaymentIntent(
      clientSecret: map['clientSecret'] as String,
      ephemeralKey: map['ephemeralKey'] as String,
      customerId: map['customer'] as String,
      publishableKey: map['publishableKey'] as String?,
      paymentIntentId: map['paymentIntentId'] as String,
      sessionId: sessionId,
      amountCents: amountCents,
      isDeposit: isDeposit,
    );
  }

  @override
  List<Object?> get props => [
        clientSecret,
        ephemeralKey,
        customerId,
        publishableKey,
        paymentIntentId,
        sessionId,
        amountCents,
        isDeposit,
      ];
}
