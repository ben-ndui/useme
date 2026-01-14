import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Start onboarding with user role
class StartOnboardingEvent extends OnboardingEvent {
  final String role;

  const StartOnboardingEvent({required this.role});

  @override
  List<Object?> get props => [role];
}

/// Go to next content page
class NextPageEvent extends OnboardingEvent {
  const NextPageEvent();
}

/// Go to previous content page
class PreviousPageEvent extends OnboardingEvent {
  const PreviousPageEvent();
}

/// Skip content slides and go to permissions
class SkipToPermissionsEvent extends OnboardingEvent {
  const SkipToPermissionsEvent();
}

/// Request location permission
class RequestLocationPermissionEvent extends OnboardingEvent {
  const RequestLocationPermissionEvent();
}

/// Skip location permission
class SkipLocationPermissionEvent extends OnboardingEvent {
  const SkipLocationPermissionEvent();
}

/// Request notification permission
class RequestNotificationPermissionEvent extends OnboardingEvent {
  const RequestNotificationPermissionEvent();
}

/// Skip notification permission
class SkipNotificationPermissionEvent extends OnboardingEvent {
  const SkipNotificationPermissionEvent();
}

/// Toggle terms acceptance checkbox
class ToggleTermsAcceptanceEvent extends OnboardingEvent {
  final bool accepted;

  const ToggleTermsAcceptanceEvent({required this.accepted});

  @override
  List<Object?> get props => [accepted];
}

/// Complete onboarding and save to Firestore
class CompleteOnboardingEvent extends OnboardingEvent {
  final String userId;

  const CompleteOnboardingEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
