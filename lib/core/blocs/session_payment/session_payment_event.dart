import 'package:equatable/equatable.dart';
import 'package:useme/core/models/session_payment_intent.dart';

/// Events for the session payment flow.
abstract class SessionPaymentEvent extends Equatable {
  const SessionPaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Create a PaymentIntent on the backend.
class InitiateSessionPaymentEvent extends SessionPaymentEvent {
  final String sessionId;
  final String studioId;
  final String userId;
  final int amountCents;
  final bool isDeposit;

  const InitiateSessionPaymentEvent({
    required this.sessionId,
    required this.studioId,
    required this.userId,
    required this.amountCents,
    required this.isDeposit,
  });

  @override
  List<Object?> get props => [sessionId, studioId, userId, amountCents, isDeposit];
}

/// Present the Stripe PaymentSheet to the user.
class PresentPaymentSheetEvent extends SessionPaymentEvent {
  final SessionPaymentIntent paymentIntent;

  const PresentPaymentSheetEvent({required this.paymentIntent});

  @override
  List<Object?> get props => [paymentIntent];
}

/// Check whether the studio has Stripe Connect set up.
class CheckConnectStatusEvent extends SessionPaymentEvent {
  final String studioUserId;

  const CheckConnectStatusEvent({required this.studioUserId});

  @override
  List<Object?> get props => [studioUserId];
}

/// Start Stripe Connect onboarding for a studio.
class InitiateConnectOnboardingEvent extends SessionPaymentEvent {
  final String userId;

  const InitiateConnectOnboardingEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Reset the BLoC to its initial state.
class ResetPaymentStateEvent extends SessionPaymentEvent {
  const ResetPaymentStateEvent();
}
