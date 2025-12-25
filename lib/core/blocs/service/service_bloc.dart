import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:useme/core/blocs/service/service_event.dart';
import 'package:useme/core/blocs/service/service_state.dart';
import 'package:useme/core/services/services_exports.dart';

/// Service BLoC - Manages studio service catalog state
class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceCatalogService _serviceCatalogService = ServiceCatalogService();
  final SubscriptionConfigService _subscriptionService =
      SubscriptionConfigService();

  ServiceBloc() : super(const ServiceInitialState()) {
    on<LoadServicesEvent>(_onLoadServices);
    on<SearchServicesEvent>(_onSearchServices);
    on<CreateServiceEvent>(_onCreateService);
    on<UpdateServiceEvent>(_onUpdateService);
    on<DeleteServiceEvent>(_onDeleteService);
    on<DeactivateServiceEvent>(_onDeactivateService);
    on<ReactivateServiceEvent>(_onReactivateService);
    on<ClearServicesEvent>(_onClearServices);
  }

  void _onClearServices(ClearServicesEvent event, Emitter<ServiceState> emit) {
    emit(const ServiceInitialState());
  }

  Future<void> _onLoadServices(
      LoadServicesEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoadingState(services: state.services));
    try {
      final services =
          await _serviceCatalogService.getServicesByStudioId(event.studioId);
      emit(ServicesLoadedState(services: services));
    } catch (e) {
      emit(ServiceErrorState(
        errorMessage: 'Erreur lors du chargement: $e',
        services: state.services,
      ));
    }
  }

  Future<void> _onSearchServices(
      SearchServicesEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoadingState(services: state.services));
    try {
      final services = await _serviceCatalogService.searchServices(
          event.studioId, event.query);
      emit(ServicesLoadedState(services: services));
    } catch (e) {
      emit(ServiceErrorState(
        errorMessage: 'Erreur lors de la recherche: $e',
        services: state.services,
      ));
    }
  }

  Future<void> _onCreateService(
      CreateServiceEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoadingState(services: state.services));

    try {
      // Check subscription limits if tier info is provided
      if (event.subscriptionTierId != null &&
          event.currentServiceCount != null) {
        final canCreate = await _subscriptionService.canCreateService(
          tierId: event.subscriptionTierId!,
          currentServicesCount: event.currentServiceCount!,
        );

        if (!canCreate) {
          final tier =
              await _subscriptionService.getTier(event.subscriptionTierId!);
          emit(ServiceLimitReachedState(
            currentCount: event.currentServiceCount!,
            maxAllowed: tier?.maxServices ?? 0,
            tierId: event.subscriptionTierId!,
            services: state.services,
          ));
          return;
        }
      }

      final service = event.service;
      final studioId = service.studioId;
      final response =
          await _serviceCatalogService.createService(studioId, service);
      if (response.code == 200) {
        final services =
            await _serviceCatalogService.getServicesByStudioId(studioId);
        emit(ServiceCreatedState(
          createdService: service,
          services: services,
        ));
      } else {
        emit(ServiceErrorState(
          errorMessage: response.message,
          services: state.services,
        ));
      }
    } catch (e) {
      emit(ServiceErrorState(
        errorMessage: 'Erreur lors de la création: $e',
        services: state.services,
      ));
    }
  }

  Future<void> _onUpdateService(
      UpdateServiceEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoadingState(services: state.services));
    try {
      final service = event.service;
      await _serviceCatalogService.updateService(service.id, service.toMap());
      final updatedServices = state.services.map((s) {
        return s.id == service.id ? service : s;
      }).toList();
      emit(ServiceUpdatedState(
        updatedService: service,
        services: updatedServices,
      ));
    } catch (e) {
      emit(ServiceErrorState(
        errorMessage: 'Erreur lors de la mise à jour: $e',
        services: state.services,
      ));
    }
  }

  Future<void> _onDeleteService(
      DeleteServiceEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceLoadingState(services: state.services));
    try {
      final response =
          await _serviceCatalogService.deleteService(event.serviceId);
      if (response.code == 200) {
        final updatedServices =
            state.services.where((s) => s.id != event.serviceId).toList();
        emit(ServiceDeletedState(
          deletedServiceId: event.serviceId,
          services: updatedServices,
        ));
      } else {
        emit(ServiceErrorState(
          errorMessage: response.message,
          services: state.services,
        ));
      }
    } catch (e) {
      emit(ServiceErrorState(
        errorMessage: 'Erreur lors de la suppression: $e',
        services: state.services,
      ));
    }
  }

  Future<void> _onDeactivateService(
      DeactivateServiceEvent event, Emitter<ServiceState> emit) async {
    try {
      await _serviceCatalogService.deactivateService(event.serviceId);
      final updatedServices = state.services.map((s) {
        return s.id == event.serviceId ? s.copyWith(isActive: false) : s;
      }).toList();
      emit(ServicesLoadedState(services: updatedServices));
    } catch (e) {
      emit(ServiceErrorState(
        errorMessage: 'Erreur: $e',
        services: state.services,
      ));
    }
  }

  Future<void> _onReactivateService(
      ReactivateServiceEvent event, Emitter<ServiceState> emit) async {
    try {
      await _serviceCatalogService.reactivateService(event.serviceId);
      final updatedServices = state.services.map((s) {
        return s.id == event.serviceId ? s.copyWith(isActive: true) : s;
      }).toList();
      emit(ServicesLoadedState(services: updatedServices));
    } catch (e) {
      emit(ServiceErrorState(
        errorMessage: 'Erreur: $e',
        services: state.services,
      ));
    }
  }
}
