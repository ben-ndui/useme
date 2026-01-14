import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final LocationService _locationService = LocationService();
  final UseMeNotificationService _notificationService =
      UseMeNotificationService.instance;

  static const int contentPagesCount = 5;
  String _currentRole = 'client';

  OnboardingBloc() : super(const OnboardingInitialState()) {
    on<StartOnboardingEvent>(_onStartOnboarding);
    on<NextPageEvent>(_onNextPage);
    on<PreviousPageEvent>(_onPreviousPage);
    on<SkipToPermissionsEvent>(_onSkipToPermissions);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<SkipLocationPermissionEvent>(_onSkipLocationPermission);
    on<RequestNotificationPermissionEvent>(_onRequestNotificationPermission);
    on<SkipNotificationPermissionEvent>(_onSkipNotificationPermission);
    on<ToggleTermsAcceptanceEvent>(_onToggleTermsAcceptance);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
  }

  void _onStartOnboarding(
    StartOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) {
    _currentRole = event.role;
    emit(OnboardingContentState(
      currentPage: 0,
      totalPages: contentPagesCount,
      role: _currentRole,
    ));
  }

  void _onNextPage(
    NextPageEvent event,
    Emitter<OnboardingState> emit,
  ) {
    final currentState = state;
    if (currentState is OnboardingContentState) {
      if (currentState.isLastPage) {
        // Go to location permission
        emit(const OnboardingLocationState());
      } else {
        emit(OnboardingContentState(
          currentPage: currentState.currentPage + 1,
          totalPages: currentState.totalPages,
          role: _currentRole,
        ));
      }
    }
  }

  void _onPreviousPage(
    PreviousPageEvent event,
    Emitter<OnboardingState> emit,
  ) {
    final currentState = state;
    if (currentState is OnboardingContentState && !currentState.isFirstPage) {
      emit(OnboardingContentState(
        currentPage: currentState.currentPage - 1,
        totalPages: currentState.totalPages,
        role: _currentRole,
      ));
    }
  }

  void _onSkipToPermissions(
    SkipToPermissionsEvent event,
    Emitter<OnboardingState> emit,
  ) {
    emit(const OnboardingLocationState());
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermissionEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLocationState(status: PermissionStatus.requesting));

    try {
      final permission = await _locationService.requestPermission();

      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          emit(const OnboardingLocationState(status: PermissionStatus.granted));
          await Future.delayed(const Duration(milliseconds: 500));
          emit(const OnboardingNotificationState());
          break;
        case LocationPermission.denied:
          emit(const OnboardingLocationState(status: PermissionStatus.denied));
          break;
        case LocationPermission.deniedForever:
          emit(const OnboardingLocationState(
              status: PermissionStatus.permanentlyDenied));
          break;
        default:
          emit(const OnboardingLocationState(status: PermissionStatus.denied));
      }
    } catch (e) {
      emit(const OnboardingLocationState(status: PermissionStatus.denied));
    }
  }

  void _onSkipLocationPermission(
    SkipLocationPermissionEvent event,
    Emitter<OnboardingState> emit,
  ) {
    emit(const OnboardingNotificationState());
  }

  Future<void> _onRequestNotificationPermission(
    RequestNotificationPermissionEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
        const OnboardingNotificationState(status: PermissionStatus.requesting));

    try {
      final granted = await _notificationService.requestPermissions();

      if (granted) {
        emit(const OnboardingNotificationState(
            status: PermissionStatus.granted));
        await Future.delayed(const Duration(milliseconds: 500));
        emit(const OnboardingTermsState());
      } else {
        emit(
            const OnboardingNotificationState(status: PermissionStatus.denied));
      }
    } catch (e) {
      emit(const OnboardingNotificationState(status: PermissionStatus.denied));
    }
  }

  void _onSkipNotificationPermission(
    SkipNotificationPermissionEvent event,
    Emitter<OnboardingState> emit,
  ) {
    emit(const OnboardingTermsState());
  }

  void _onToggleTermsAcceptance(
    ToggleTermsAcceptanceEvent event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingTermsState(isAccepted: event.accepted));
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingCompletingState());

    try {
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();

      // Save locally
      await prefs.setBool('onboarding_completed', true);
      await prefs.setString('terms_accepted_at', now.toIso8601String());
      await prefs.setString('terms_version', '1.0');

      // Save to Firestore
      await SmoothFirebase.collection('users').doc(event.userId).update({
        'isFirstTime': false,
        'termsAcceptedAt': now,
        'termsVersion': '1.0',
        'onboardingCompletedAt': now,
      });

      emit(const OnboardingCompletedState());
    } catch (e) {
      emit(OnboardingErrorState(message: e.toString()));
    }
  }
}
