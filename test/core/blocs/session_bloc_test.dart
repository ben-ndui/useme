import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/blocs/session/session_bloc.dart';
import 'package:useme/core/blocs/session/session_event.dart';
import 'package:useme/core/blocs/session/session_state.dart';
import 'package:useme/core/models/models_exports.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockSessionService mockSessionService;
  late MockSubscriptionConfigService mockSubscriptionService;

  final testSession = SessionFactory.future(status: SessionStatus.confirmed);
  final testSessions = [testSession];

  setUpAll(() {
    registerFallbackValue(FakeSession());
  });

  setUp(() {
    mockSessionService = MockSessionService();
    mockSubscriptionService = MockSubscriptionConfigService();
  });

  SessionBloc buildBloc() => SessionBloc(
        sessionService: mockSessionService,
        subscriptionService: mockSubscriptionService,
      );

  group('LoadSessionsEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [loading, loaded] when sessions load successfully',
      build: () {
        when(() => mockSessionService.getSessions('studio-1'))
            .thenAnswer((_) async => testSessions);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadSessionsEvent(studioId: 'studio-1')),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionsLoadedState>()
            .having((s) => s.sessions.length, 'sessions count', 1),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [loading, error] when load fails',
      build: () {
        when(() => mockSessionService.getSessions('studio-1'))
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadSessionsEvent(studioId: 'studio-1')),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionErrorState>()
            .having((s) => s.errorMessage, 'message', contains('Network error')),
      ],
    );
  });

  group('LoadEngineerSessionsEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [loading, loaded] from engineer stream',
      build: () {
        when(() => mockSessionService.streamEngineerSessions('eng-1'))
            .thenAnswer((_) => Stream.value(testSessions));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadEngineerSessionsEvent(engineerId: 'eng-1')),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionsLoadedState>(),
      ],
    );
  });

  group('LoadArtistSessionsEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [loading, loaded] from artist stream',
      build: () {
        when(() => mockSessionService.streamArtistSessions('artist-1'))
            .thenAnswer((_) => Stream.value(testSessions));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadArtistSessionsEvent(artistId: 'artist-1')),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionsLoadedState>(),
      ],
    );
  });

  group('CreateSessionEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [loading, created] on success',
      build: () {
        when(() => mockSessionService.createSession(any()))
            .thenAnswer((_) async => SmoothResponse(
                  code: 200,
                  message: 'OK',
                  data: testSession,
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateSessionEvent(session: testSession)),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionCreatedState>()
            .having((s) => s.createdSession, 'created', testSession),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [loading, error] on failure (code 500)',
      build: () {
        when(() => mockSessionService.createSession(any()))
            .thenAnswer((_) async => const SmoothResponse(
                  code: 500,
                  message: 'Firestore error',
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateSessionEvent(session: testSession)),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Firestore error'),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [loading, limitReached] when subscription limit exceeded',
      build: () {
        when(() => mockSubscriptionService.canCreateSession(
              tierId: 'free',
              currentSessionsThisMonth: 10,
            )).thenAnswer((_) async => false);
        when(() => mockSubscriptionService.getTier('free'))
            .thenAnswer((_) async => SubscriptionTierConfig(
                  id: 'free',
                  name: 'Free',
                  maxSessions: 10,
                  maxRooms: 1,
                  maxServices: 3,
                  maxEngineers: 1,
                  sortOrder: 0,
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateSessionEvent(
        session: testSession,
        subscriptionTierId: 'free',
        currentSessionCount: 10,
      )),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionLimitReachedState>()
            .having((s) => s.maxAllowed, 'max', 10)
            .having((s) => s.currentCount, 'current', 10),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'creates session when under subscription limit',
      build: () {
        when(() => mockSubscriptionService.canCreateSession(
              tierId: 'pro',
              currentSessionsThisMonth: 5,
            )).thenAnswer((_) async => true);
        when(() => mockSessionService.createSession(any()))
            .thenAnswer((_) async => SmoothResponse(
                  code: 200,
                  message: 'OK',
                  data: testSession,
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateSessionEvent(
        session: testSession,
        subscriptionTierId: 'pro',
        currentSessionCount: 5,
      )),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionCreatedState>(),
      ],
    );
  });

  group('UpdateSessionEvent', () {
    final updated = testSession.copyWith(notes: 'Updated notes');

    blocTest<SessionBloc, SessionState>(
      'emits [loading, updated] on success',
      build: () {
        when(() => mockSessionService.updateSession(any()))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK'));
        return buildBloc();
      },
      seed: () => SessionsLoadedState(sessions: testSessions),
      act: (bloc) => bloc.add(UpdateSessionEvent(session: updated)),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionUpdatedState>()
            .having((s) => s.updatedSession.notes, 'notes', 'Updated notes'),
      ],
    );
  });

  group('DeleteSessionEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [loading, deleted] and removes session from list',
      build: () {
        when(() => mockSessionService.deleteSession('session-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK'));
        return buildBloc();
      },
      seed: () => SessionsLoadedState(sessions: testSessions),
      act: (bloc) =>
          bloc.add(const DeleteSessionEvent(sessionId: 'session-1')),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionDeletedState>()
            .having((s) => s.sessions, 'empty list', isEmpty),
      ],
    );
  });

  group('UpdateSessionStatusEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits statusUpdated with new status',
      build: () {
        when(() => mockSessionService.updateStatus(
                'session-1', SessionStatus.confirmed))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK'));
        return buildBloc();
      },
      seed: () => SessionsLoadedState(sessions: testSessions),
      act: (bloc) => bloc.add(const UpdateSessionStatusEvent(
        sessionId: 'session-1',
        status: SessionStatus.confirmed,
      )),
      expect: () => [
        isA<SessionStatusUpdatedState>()
            .having((s) => s.newStatus, 'status', SessionStatus.confirmed),
      ],
    );
  });

  group('CheckinSessionEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits statusUpdated with inProgress',
      build: () {
        when(() => mockSessionService.checkin('session-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => SessionsLoadedState(sessions: testSessions),
      act: (bloc) =>
          bloc.add(const CheckinSessionEvent(sessionId: 'session-1')),
      expect: () => [
        isA<SessionStatusUpdatedState>()
            .having((s) => s.newStatus, 'status', SessionStatus.inProgress),
      ],
    );
  });

  group('CheckoutSessionEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits statusUpdated with completed',
      build: () {
        when(() => mockSessionService.checkout('session-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => SessionsLoadedState(sessions: testSessions),
      act: (bloc) =>
          bloc.add(const CheckoutSessionEvent(sessionId: 'session-1')),
      expect: () => [
        isA<SessionStatusUpdatedState>()
            .having((s) => s.newStatus, 'status', SessionStatus.completed),
      ],
    );
  });

  group('LoadSessionByIdEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [loading, detail] when session found',
      build: () {
        when(() => mockSessionService.getSession('session-1'))
            .thenAnswer((_) async => testSession);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadSessionByIdEvent(sessionId: 'session-1')),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionDetailLoadedState>()
            .having((s) => s.selectedSession, 'session', testSession),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [loading, error] when session not found',
      build: () {
        when(() => mockSessionService.getSession('missing'))
            .thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadSessionByIdEvent(sessionId: 'missing')),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Session introuvable'),
      ],
    );
  });

  group('LoadProSessionsEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [loading, loaded] from pro stream',
      build: () {
        when(() => mockSessionService.streamProSessions('pro-1'))
            .thenAnswer((_) => Stream.value(testSessions));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadProSessionsEvent(proId: 'pro-1')),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionsLoadedState>()
            .having((s) => s.sessions.length, 'sessions count', 1),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [loading, error] when pro stream fails',
      build: () {
        when(() => mockSessionService.streamProSessions('pro-1'))
            .thenAnswer((_) => Stream.error(Exception('fail')));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadProSessionsEvent(proId: 'pro-1')),
      expect: () => [
        isA<SessionLoadingState>(),
        isA<SessionErrorState>(),
      ],
    );
  });

  group('ClearSessionsEvent', () {
    blocTest<SessionBloc, SessionState>(
      'resets to initial state',
      build: buildBloc,
      seed: () => SessionsLoadedState(sessions: testSessions),
      act: (bloc) => bloc.add(const ClearSessionsEvent()),
      expect: () => [isA<SessionInitialState>()],
    );
  });

  group('UpdateSessionNotesEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [notesUpdated] on success',
      build: () {
        when(() => mockSessionService.updateNotes('session-1', 'Great session'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => SessionsLoadedState(sessions: testSessions),
      act: (bloc) => bloc.add(const UpdateSessionNotesEvent(
        sessionId: 'session-1',
        notes: 'Great session',
      )),
      expect: () => [isA<SessionNotesUpdatedState>()],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [error] when updateNotes fails',
      build: () {
        when(() => mockSessionService.updateNotes('session-1', 'notes'))
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      seed: () => SessionsLoadedState(sessions: testSessions),
      act: (bloc) => bloc.add(const UpdateSessionNotesEvent(
        sessionId: 'session-1',
        notes: 'notes',
      )),
      expect: () => [
        isA<SessionErrorState>()
            .having((s) => s.errorMessage, 'msg', contains('Network error')),
      ],
    );
  });

  group('AddSessionPhotoEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [photoAdded] on success',
      build: () {
        when(() => mockSessionService.addPhoto('session-1', 'https://url.jpg'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => SessionsLoadedState(sessions: testSessions),
      act: (bloc) => bloc.add(const AddSessionPhotoEvent(
        sessionId: 'session-1',
        photoUrl: 'https://url.jpg',
      )),
      expect: () => [
        isA<SessionPhotoAddedState>()
            .having((s) => s.photoUrl, 'url', 'https://url.jpg'),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits [error] when addPhoto fails',
      build: () {
        when(() => mockSessionService.addPhoto('session-1', 'https://url.jpg'))
            .thenThrow(Exception('Upload failed'));
        return buildBloc();
      },
      seed: () => SessionsLoadedState(sessions: testSessions),
      act: (bloc) => bloc.add(const AddSessionPhotoEvent(
        sessionId: 'session-1',
        photoUrl: 'https://url.jpg',
      )),
      expect: () => [
        isA<SessionErrorState>()
            .having((s) => s.errorMessage, 'msg', contains('Upload failed')),
      ],
    );
  });
}
