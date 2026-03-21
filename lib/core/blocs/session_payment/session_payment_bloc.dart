import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:useme/core/services/session_payment_service.dart';

import 'session_payment_event.dart';
import 'session_payment_state.dart';

/// BLoC that orchestrates the Stripe session payment flow.
class SessionPaymentBloc
    extends Bloc<SessionPaymentEvent, SessionPaymentState> {
  final SessionPaymentService _service;

  SessionPaymentBloc({SessionPaymentService? service})
      : _service = service ?? SessionPaymentService(),
        super(const SessionPaymentInitialState()) {
    on<InitiateSessionPaymentEvent>(_onInitiate);
    on<PresentPaymentSheetEvent>(_onPresent);
    on<CheckConnectStatusEvent>(_onCheckConnect);
    on<InitiateConnectOnboardingEvent>(_onInitiateConnect);
    on<ResetPaymentStateEvent>(_onReset);
  }

  Future<void> _onInitiate(
    InitiateSessionPaymentEvent event,
    Emitter<SessionPaymentState> emit,
  ) async {
    emit(const SessionPaymentLoadingState());
    try {
      final intent = await _service.createPaymentIntent(
        userId: event.userId,
        sessionId: event.sessionId,
        amountCents: event.amountCents,
        studioId: event.studioId,
        isDeposit: event.isDeposit,
      );
      emit(SessionPaymentReadyState(paymentIntent: intent));
    } catch (_) {
      emit(const SessionPaymentFailedState(
        errorMessage: 'Impossible de préparer le paiement. Réessayez.',
      ));
    }
  }

  Future<void> _onPresent(
    PresentPaymentSheetEvent event,
    Emitter<SessionPaymentState> emit,
  ) async {
    emit(const SessionPaymentLoadingState());
    try {
      await _service.presentPaymentSheet(event.paymentIntent);
      emit(SessionPaymentSuccessState(
        sessionId: event.paymentIntent.sessionId,
        paymentIntentId: event.paymentIntent.paymentIntentId,
        isDeposit: event.paymentIntent.isDeposit,
      ));
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        emit(const SessionPaymentCancelledState());
      } else {
        emit(const SessionPaymentFailedState(
          errorMessage: 'Le paiement a échoué. Réessayez.',
        ));
      }
    } catch (_) {
      emit(const SessionPaymentFailedState(
        errorMessage: 'Une erreur est survenue. Réessayez.',
      ));
    }
  }

  Future<void> _onCheckConnect(
    CheckConnectStatusEvent event,
    Emitter<SessionPaymentState> emit,
  ) async {
    emit(const SessionPaymentLoadingState());
    try {
      final status = await _service.getConnectStatus(
        userId: event.studioUserId,
      );
      emit(ConnectStatusLoadedState(status: status));
    } catch (_) {
      emit(const SessionPaymentFailedState(
        errorMessage: 'Impossible de vérifier le statut. Réessayez.',
      ));
    }
  }

  Future<void> _onInitiateConnect(
    InitiateConnectOnboardingEvent event,
    Emitter<SessionPaymentState> emit,
  ) async {
    emit(const SessionPaymentLoadingState());
    try {
      await _service.launchOnboarding(userId: event.userId);
      emit(const ConnectOnboardingLaunchedState());
    } catch (_) {
      emit(const SessionPaymentFailedState(
        errorMessage: 'Impossible de lancer la configuration. Réessayez.',
      ));
    }
  }

  void _onReset(
    ResetPaymentStateEvent event,
    Emitter<SessionPaymentState> emit,
  ) {
    emit(const SessionPaymentInitialState());
  }
}
