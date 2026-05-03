import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uzme/core/blocs/session_payment/session_payment_bloc.dart';
import 'package:uzme/core/blocs/session_payment/session_payment_event.dart';
import 'package:uzme/core/blocs/session_payment/session_payment_state.dart';
import 'package:uzme/core/models/session_payment_intent.dart';
import 'package:uzme/core/services/session_payment_service.dart';

class MockSessionPaymentService extends Mock implements SessionPaymentService {}

void main() {
  late MockSessionPaymentService mockService;

  const testIntent = SessionPaymentIntent(
    clientSecret: 'pi_secret_test',
    ephemeralKey: 'ek_test',
    customerId: 'cus_test',
    publishableKey: 'pk_test',
    paymentIntentId: 'pi_test',
    sessionId: 'sess_test',
    amountCents: 5000,
    isDeposit: true,
  );

  setUp(() {
    mockService = MockSessionPaymentService();
  });

  group('SessionPaymentBloc', () {
    blocTest<SessionPaymentBloc, SessionPaymentState>(
      'emits [Loading, Ready] on InitiateSessionPaymentEvent success',
      build: () {
        when(() => mockService.createPaymentIntent(
              userId: any(named: 'userId'),
              sessionId: any(named: 'sessionId'),
              amountCents: any(named: 'amountCents'),
              studioId: any(named: 'studioId'),
              isDeposit: any(named: 'isDeposit'),
              currency: any(named: 'currency'),
            )).thenAnswer((_) async => testIntent);
        return SessionPaymentBloc(service: mockService);
      },
      act: (bloc) => bloc.add(const InitiateSessionPaymentEvent(
        sessionId: 'sess_test',
        studioId: 'studio_1',
        userId: 'user_1',
        amountCents: 5000,
        isDeposit: true,
      )),
      expect: () => [
        isA<SessionPaymentLoadingState>(),
        isA<SessionPaymentReadyState>().having(
          (s) => s.paymentIntent,
          'paymentIntent',
          testIntent,
        ),
      ],
    );

    blocTest<SessionPaymentBloc, SessionPaymentState>(
      'emits [Loading, Failed] on InitiateSessionPaymentEvent error',
      build: () {
        when(() => mockService.createPaymentIntent(
              userId: any(named: 'userId'),
              sessionId: any(named: 'sessionId'),
              amountCents: any(named: 'amountCents'),
              studioId: any(named: 'studioId'),
              isDeposit: any(named: 'isDeposit'),
              currency: any(named: 'currency'),
            )).thenThrow(Exception('Network error'));
        return SessionPaymentBloc(service: mockService);
      },
      act: (bloc) => bloc.add(const InitiateSessionPaymentEvent(
        sessionId: 'sess_test',
        studioId: 'studio_1',
        userId: 'user_1',
        amountCents: 5000,
        isDeposit: true,
      )),
      expect: () => [
        isA<SessionPaymentLoadingState>(),
        isA<SessionPaymentFailedState>(),
      ],
    );

    blocTest<SessionPaymentBloc, SessionPaymentState>(
      'emits [Loading, ConnectStatusLoaded] on CheckConnectStatusEvent',
      build: () {
        when(() => mockService.getConnectStatus(
              userId: any(named: 'userId'),
            )).thenAnswer((_) async => const ConnectStatus(
              connected: true,
              accountId: 'acct_123',
              chargesEnabled: true,
              payoutsEnabled: true,
              detailsSubmitted: true,
            ));
        return SessionPaymentBloc(service: mockService);
      },
      act: (bloc) => bloc.add(
        const CheckConnectStatusEvent(studioUserId: 'studio_1'),
      ),
      expect: () => [
        isA<SessionPaymentLoadingState>(),
        isA<ConnectStatusLoadedState>().having(
          (s) => s.status.connected,
          'connected',
          true,
        ),
      ],
    );

    blocTest<SessionPaymentBloc, SessionPaymentState>(
      'emits [Initial] on ResetPaymentStateEvent',
      build: () => SessionPaymentBloc(service: mockService),
      seed: () => const SessionPaymentFailedState(errorMessage: 'test'),
      act: (bloc) => bloc.add(const ResetPaymentStateEvent()),
      expect: () => [isA<SessionPaymentInitialState>()],
    );
  });
}
