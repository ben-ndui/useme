import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:useme/core/blocs/session/session_event.dart';
import 'package:useme/core/blocs/session/session_state.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/services_exports.dart';

/// Session BLoC - Manages session state
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionService _sessionService = SessionService();

  SessionBloc() : super(const SessionInitialState()) {
    on<LoadSessionsEvent>(_onLoadSessions);
    on<LoadEngineerSessionsEvent>(_onLoadEngineerSessions);
    on<LoadArtistSessionsEvent>(_onLoadArtistSessions);
    on<CreateSessionEvent>(_onCreateSession);
    on<UpdateSessionEvent>(_onUpdateSession);
    on<DeleteSessionEvent>(_onDeleteSession);
    on<UpdateSessionStatusEvent>(_onUpdateSessionStatus);
    on<AssignEngineerEvent>(_onAssignEngineer);
    on<CheckinSessionEvent>(_onCheckinSession);
    on<CheckoutSessionEvent>(_onCheckoutSession);
    on<LoadSessionByIdEvent>(_onLoadSessionById);
  }

  Future<void> _onLoadSessions(
      LoadSessionsEvent event, Emitter<SessionState> emit) async {
    emit(SessionLoadingState(sessions: state.sessions));
    try {
      final sessions = await _sessionService.getSessions(event.studioId);
      emit(SessionsLoadedState(sessions: sessions));
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur lors du chargement: $e',
        sessions: state.sessions,
      ));
    }
  }

  Future<void> _onLoadEngineerSessions(
      LoadEngineerSessionsEvent event, Emitter<SessionState> emit) async {
    emit(SessionLoadingState(sessions: state.sessions));
    try {
      final sessions = await _sessionService
          .streamEngineerSessions(event.engineerId)
          .first;
      emit(SessionsLoadedState(sessions: sessions));
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur: $e',
        sessions: state.sessions,
      ));
    }
  }

  Future<void> _onLoadArtistSessions(
      LoadArtistSessionsEvent event, Emitter<SessionState> emit) async {
    emit(SessionLoadingState(sessions: state.sessions));
    try {
      final sessions = await _sessionService
          .streamArtistSessions(event.artistId)
          .first;
      emit(SessionsLoadedState(sessions: sessions));
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur: $e',
        sessions: state.sessions,
      ));
    }
  }

  Future<void> _onCreateSession(
      CreateSessionEvent event, Emitter<SessionState> emit) async {
    emit(SessionLoadingState(sessions: state.sessions));
    try {
      final response = await _sessionService.createSession(event.session);
      if (response.code == 200 && response.data != null) {
        final updatedSessions = [response.data!, ...state.sessions];
        emit(SessionCreatedState(
          createdSession: response.data!,
          sessions: updatedSessions,
        ));
      } else {
        emit(SessionErrorState(
          errorMessage: response.message,
          sessions: state.sessions,
        ));
      }
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur: $e',
        sessions: state.sessions,
      ));
    }
  }

  Future<void> _onUpdateSession(
      UpdateSessionEvent event, Emitter<SessionState> emit) async {
    emit(SessionLoadingState(sessions: state.sessions));
    try {
      final response = await _sessionService.updateSession(event.session);
      if (response.code == 200) {
        final updatedSessions = state.sessions.map((s) {
          return s.id == event.session.id ? event.session : s;
        }).toList();
        emit(SessionUpdatedState(
          updatedSession: event.session,
          sessions: updatedSessions,
        ));
      } else {
        emit(SessionErrorState(
          errorMessage: response.message,
          sessions: state.sessions,
        ));
      }
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur: $e',
        sessions: state.sessions,
      ));
    }
  }

  Future<void> _onDeleteSession(
      DeleteSessionEvent event, Emitter<SessionState> emit) async {
    emit(SessionLoadingState(sessions: state.sessions));
    try {
      final response = await _sessionService.deleteSession(event.sessionId);
      if (response.code == 200) {
        final updatedSessions =
            state.sessions.where((s) => s.id != event.sessionId).toList();
        emit(SessionDeletedState(
          deletedSessionId: event.sessionId,
          sessions: updatedSessions,
        ));
      } else {
        emit(SessionErrorState(
          errorMessage: response.message,
          sessions: state.sessions,
        ));
      }
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur: $e',
        sessions: state.sessions,
      ));
    }
  }

  Future<void> _onUpdateSessionStatus(
      UpdateSessionStatusEvent event, Emitter<SessionState> emit) async {
    try {
      final response =
          await _sessionService.updateStatus(event.sessionId, event.status);
      if (response.code == 200) {
        final updatedSessions = state.sessions.map((s) {
          return s.id == event.sessionId
              ? s.copyWith(status: event.status)
              : s;
        }).toList();
        emit(SessionStatusUpdatedState(
          sessionId: event.sessionId,
          newStatus: event.status,
          sessions: updatedSessions,
        ));
      }
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur: $e',
        sessions: state.sessions,
      ));
    }
  }

  Future<void> _onAssignEngineer(
      AssignEngineerEvent event, Emitter<SessionState> emit) async {
    try {
      await _sessionService.assignEngineer(
        event.sessionId,
        event.engineerId,
        event.engineerName,
      );
      final updatedSessions = state.sessions.map((s) {
        return s.id == event.sessionId
            ? s.copyWith(
                engineerId: event.engineerId,
                engineerName: event.engineerName,
              )
            : s;
      }).toList();
      emit(SessionsLoadedState(sessions: updatedSessions));
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur: $e',
        sessions: state.sessions,
      ));
    }
  }

  Future<void> _onCheckinSession(
      CheckinSessionEvent event, Emitter<SessionState> emit) async {
    try {
      await _sessionService.checkin(event.sessionId);
      final updatedSessions = state.sessions.map((s) {
        return s.id == event.sessionId
            ? s.copyWith(status: SessionStatus.inProgress)
            : s;
      }).toList();
      emit(SessionStatusUpdatedState(
        sessionId: event.sessionId,
        newStatus: SessionStatus.inProgress,
        sessions: updatedSessions,
      ));
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur: $e',
        sessions: state.sessions,
      ));
    }
  }

  Future<void> _onCheckoutSession(
      CheckoutSessionEvent event, Emitter<SessionState> emit) async {
    try {
      await _sessionService.checkout(event.sessionId);
      final updatedSessions = state.sessions.map((s) {
        return s.id == event.sessionId
            ? s.copyWith(status: SessionStatus.completed)
            : s;
      }).toList();
      emit(SessionStatusUpdatedState(
        sessionId: event.sessionId,
        newStatus: SessionStatus.completed,
        sessions: updatedSessions,
      ));
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur: $e',
        sessions: state.sessions,
      ));
    }
  }

  Future<void> _onLoadSessionById(
      LoadSessionByIdEvent event, Emitter<SessionState> emit) async {
    emit(SessionLoadingState(sessions: state.sessions));
    try {
      final session = await _sessionService.getSession(event.sessionId);
      if (session != null) {
        emit(SessionDetailLoadedState(
          selectedSession: session,
          sessions: state.sessions,
        ));
      } else {
        emit(SessionErrorState(
          errorMessage: 'Session introuvable',
          sessions: state.sessions,
        ));
      }
    } catch (e) {
      emit(SessionErrorState(
        errorMessage: 'Erreur: $e',
        sessions: state.sessions,
      ));
    }
  }
}
