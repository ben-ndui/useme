import 'package:equatable/equatable.dart';
import 'package:useme/core/models/models_exports.dart';

/// Base service event
abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

/// Load all services for a studio
class LoadServicesEvent extends ServiceEvent {
  final String studioId;

  const LoadServicesEvent({required this.studioId});

  @override
  List<Object?> get props => [studioId];
}

/// Search services
class SearchServicesEvent extends ServiceEvent {
  final String studioId;
  final String query;

  const SearchServicesEvent({required this.studioId, required this.query});

  @override
  List<Object?> get props => [studioId, query];
}

/// Create new service
class CreateServiceEvent extends ServiceEvent {
  final StudioService service;

  const CreateServiceEvent({required this.service});

  @override
  List<Object?> get props => [service];
}

/// Update existing service
class UpdateServiceEvent extends ServiceEvent {
  final StudioService service;

  const UpdateServiceEvent({required this.service});

  @override
  List<Object?> get props => [service];
}

/// Delete service
class DeleteServiceEvent extends ServiceEvent {
  final String serviceId;

  const DeleteServiceEvent({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}

/// Deactivate service
class DeactivateServiceEvent extends ServiceEvent {
  final String serviceId;

  const DeactivateServiceEvent({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}

/// Reactivate service
class ReactivateServiceEvent extends ServiceEvent {
  final String serviceId;

  const ReactivateServiceEvent({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}
