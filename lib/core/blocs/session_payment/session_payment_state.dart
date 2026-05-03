import 'package:equatable/equatable.dart';
import 'package:uzme/core/models/session_payment_intent.dart';
import 'package:uzme/core/services/session_payment_service.dart';

/// States for the session payment flow.
abstract class SessionPaymentState extends Equatable {
  const SessionPaymentState();

  @override
  List<Object?> get props => [];
}

class SessionPaymentInitialState extends SessionPaymentState {
  const SessionPaymentInitialState();
}

class SessionPaymentLoadingState extends SessionPaymentState {
  const SessionPaymentLoadingState();
}

/// PaymentIntent created — ready to show PaymentSheet.
class SessionPaymentReadyState extends SessionPaymentState {
  final SessionPaymentIntent paymentIntent;

  const SessionPaymentReadyState({required this.paymentIntent});

  @override
  List<Object?> get props => [paymentIntent];
}

class SessionPaymentSuccessState extends SessionPaymentState {
  final String sessionId;
  final String paymentIntentId;
  final bool isDeposit;

  const SessionPaymentSuccessState({
    required this.sessionId,
    required this.paymentIntentId,
    required this.isDeposit,
  });

  @override
  List<Object?> get props => [sessionId, paymentIntentId, isDeposit];
}

class SessionPaymentFailedState extends SessionPaymentState {
  final String errorMessage;

  const SessionPaymentFailedState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class SessionPaymentCancelledState extends SessionPaymentState {
  const SessionPaymentCancelledState();
}

/// Stripe Connect status for a studio.
class ConnectStatusLoadedState extends SessionPaymentState {
  final ConnectStatus status;

  const ConnectStatusLoadedState({required this.status});

  @override
  List<Object?> get props => [status];
}

class ConnectOnboardingLaunchedState extends SessionPaymentState {
  const ConnectOnboardingLaunchedState();
}
