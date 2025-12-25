import 'package:equatable/equatable.dart';
import 'package:useme/core/models/models_exports.dart';

/// Base service state
class ServiceState extends Equatable {
  final List<StudioService> services;
  final StudioService? selectedService;
  final bool isLoading;
  final String? errorMessage;

  const ServiceState({
    this.services = const [],
    this.selectedService,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [services, selectedService, isLoading, errorMessage];

  ServiceState copyWith({
    List<StudioService>? services,
    StudioService? selectedService,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ServiceState(
      services: services ?? this.services,
      selectedService: selectedService ?? this.selectedService,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Initial state
class ServiceInitialState extends ServiceState {
  const ServiceInitialState() : super();
}

/// Loading state
class ServiceLoadingState extends ServiceState {
  const ServiceLoadingState({super.services, super.selectedService})
      : super(isLoading: true);
}

/// Services loaded successfully
class ServicesLoadedState extends ServiceState {
  const ServicesLoadedState({required super.services}) : super(isLoading: false);
}

/// Service created successfully
class ServiceCreatedState extends ServiceState {
  final StudioService createdService;

  const ServiceCreatedState({
    required this.createdService,
    required super.services,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [createdService, services, isLoading];
}

/// Service updated successfully
class ServiceUpdatedState extends ServiceState {
  final StudioService updatedService;

  const ServiceUpdatedState({
    required this.updatedService,
    required super.services,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [updatedService, services, isLoading];
}

/// Service deleted successfully
class ServiceDeletedState extends ServiceState {
  final String deletedServiceId;

  const ServiceDeletedState({
    required this.deletedServiceId,
    required super.services,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [deletedServiceId, services, isLoading];
}

/// Error state
class ServiceErrorState extends ServiceState {
  const ServiceErrorState({
    required super.errorMessage,
    super.services,
    super.selectedService,
  }) : super(isLoading: false);
}

/// Service limit reached state (subscription limit)
class ServiceLimitReachedState extends ServiceState {
  final int currentCount;
  final int maxAllowed;
  final String tierId;

  const ServiceLimitReachedState({
    required this.currentCount,
    required this.maxAllowed,
    required this.tierId,
    super.services,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [currentCount, maxAllowed, tierId, services];
}
