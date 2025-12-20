import 'package:equatable/equatable.dart';
import 'package:useme/core/models/models_exports.dart';

/// Base session state
class SessionState extends Equatable {
  final List<Session> sessions;
  final Session? selectedSession;
  final bool isLoading;
  final String? errorMessage;

  const SessionState({
    this.sessions = const [],
    this.selectedSession,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [sessions, selectedSession, isLoading, errorMessage];

  SessionState copyWith({
    List<Session>? sessions,
    Session? selectedSession,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SessionState(
      sessions: sessions ?? this.sessions,
      selectedSession: selectedSession ?? this.selectedSession,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Initial state
class SessionInitialState extends SessionState {
  const SessionInitialState() : super();
}

/// Loading state
class SessionLoadingState extends SessionState {
  const SessionLoadingState({super.sessions, super.selectedSession})
      : super(isLoading: true);
}

/// Sessions loaded successfully
class SessionsLoadedState extends SessionState {
  const SessionsLoadedState({required super.sessions}) : super(isLoading: false);
}

/// Single session loaded
class SessionDetailLoadedState extends SessionState {
  const SessionDetailLoadedState({
    required super.selectedSession,
    super.sessions,
  }) : super(isLoading: false);
}

/// Session created successfully
class SessionCreatedState extends SessionState {
  final Session createdSession;

  const SessionCreatedState({
    required this.createdSession,
    required super.sessions,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [createdSession, sessions, isLoading];
}

/// Session updated successfully
class SessionUpdatedState extends SessionState {
  final Session updatedSession;

  const SessionUpdatedState({
    required this.updatedSession,
    required super.sessions,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [updatedSession, sessions, isLoading];
}

/// Session deleted successfully
class SessionDeletedState extends SessionState {
  final String deletedSessionId;

  const SessionDeletedState({
    required this.deletedSessionId,
    required super.sessions,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [deletedSessionId, sessions, isLoading];
}

/// Session status updated
class SessionStatusUpdatedState extends SessionState {
  final String sessionId;
  final SessionStatus newStatus;

  const SessionStatusUpdatedState({
    required this.sessionId,
    required this.newStatus,
    required super.sessions,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [sessionId, newStatus, sessions, isLoading];
}

/// Error state
class SessionErrorState extends SessionState {
  const SessionErrorState({
    required super.errorMessage,
    super.sessions,
    super.selectedSession,
  }) : super(isLoading: false);
}
