import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state before onboarding starts
class OnboardingInitialState extends OnboardingState {
  const OnboardingInitialState();
}

/// Showing content slides
class OnboardingContentState extends OnboardingState {
  final int currentPage;
  final int totalPages;
  final String role;

  const OnboardingContentState({
    required this.currentPage,
    required this.totalPages,
    required this.role,
  });

  bool get isLastPage => currentPage >= totalPages - 1;
  bool get isFirstPage => currentPage == 0;

  @override
  List<Object?> get props => [currentPage, totalPages, role];
}

/// Showing location permission screen
class OnboardingLocationState extends OnboardingState {
  final PermissionStatus status;

  const OnboardingLocationState({this.status = PermissionStatus.pending});

  @override
  List<Object?> get props => [status];
}

/// Showing notification permission screen
class OnboardingNotificationState extends OnboardingState {
  final PermissionStatus status;

  const OnboardingNotificationState({this.status = PermissionStatus.pending});

  @override
  List<Object?> get props => [status];
}

/// Showing terms acceptance screen
class OnboardingTermsState extends OnboardingState {
  final bool isAccepted;

  const OnboardingTermsState({this.isAccepted = false});

  @override
  List<Object?> get props => [isAccepted];
}

/// Completing onboarding (saving to Firestore)
class OnboardingCompletingState extends OnboardingState {
  const OnboardingCompletingState();
}

/// Onboarding completed successfully
class OnboardingCompletedState extends OnboardingState {
  const OnboardingCompletedState();
}

/// Error during onboarding
class OnboardingErrorState extends OnboardingState {
  final String message;

  const OnboardingErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Permission request status
enum PermissionStatus {
  pending,
  requesting,
  granted,
  denied,
  permanentlyDenied,
}
