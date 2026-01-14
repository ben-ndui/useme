import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/core/services/location_service.dart';
import 'package:useme/core/services/studio_discovery_service.dart';

/// BLoC for managing map state and studio discovery
class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationService _locationService = LocationService();
  final StudioDiscoveryService _studioService = StudioDiscoveryService();

  MapBloc() : super(const MapState()) {
    on<InitMapEvent>(_onInitMap);
    on<LoadNearbyStudiosEvent>(_onLoadNearbyStudios);
    on<UpdateUserLocationEvent>(_onUpdateUserLocation);
    on<SelectStudioEvent>(_onSelectStudio);
    on<DeselectStudioEvent>(_onDeselectStudio);
    on<RefreshStudiosEvent>(_onRefreshStudios);
    on<SearchByAddressEvent>(_onSearchByAddress);
    on<UpdateSearchCenterEvent>(_onUpdateSearchCenter);
    on<SearchInAreaEvent>(_onSearchInArea);
    on<UpdateFiltersEvent>(_onUpdateFilters);
    on<ClearFiltersEvent>(_onClearFilters);
  }

  Future<void> _onInitMap(InitMapEvent event, Emitter<MapState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Get user location
      final position = await _locationService.getCurrentLatLng();
      final permission = await _locationService.checkPermission();
      final hasPermission = permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;

      emit(state.copyWith(
        userLocation: position,
        searchCenter: position,
        hasLocationPermission: hasPermission,
      ));

      // Load studios near user
      add(LoadNearbyStudiosEvent(position: position));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Impossible d\'obtenir votre position',
      ));
    }
  }

  Future<void> _onLoadNearbyStudios(
    LoadNearbyStudiosEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final studios = await _studioService.findNearbyStudios(
        event.position,
        radius: event.radius,
      );

      emit(state.copyWith(
        isLoading: false,
        nearbyStudios: studios,
        searchCenter: event.position,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la recherche de studios',
      ));
    }
  }

  Future<void> _onUpdateUserLocation(
    UpdateUserLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(userLocation: event.position));
  }

  void _onSelectStudio(SelectStudioEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(selectedStudio: event.studio));
  }

  void _onDeselectStudio(DeselectStudioEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(clearSelectedStudio: true));
  }

  Future<void> _onRefreshStudios(
    RefreshStudiosEvent event,
    Emitter<MapState> emit,
  ) async {
    _studioService.clearCache();
    add(LoadNearbyStudiosEvent(position: state.userLocation));
  }

  Future<void> _onSearchByAddress(
    SearchByAddressEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(
      isSearchingAddress: true,
      clearError: true,
      searchQuery: event.address,
    ));

    try {
      final position = await _studioService.geocodeAddress(event.address);

      if (position == null) {
        emit(state.copyWith(
          isSearchingAddress: false,
          error: 'Adresse non trouvée',
        ));
        return;
      }

      emit(state.copyWith(
        isSearchingAddress: false,
        searchCenter: position,
        hasCameraMoved: false,
      ));

      // Load studios at the new location
      add(SearchInAreaEvent(center: position, radius: event.radius));
    } catch (e) {
      emit(state.copyWith(
        isSearchingAddress: false,
        error: 'Erreur lors de la recherche',
      ));
    }
  }

  void _onUpdateSearchCenter(
    UpdateSearchCenterEvent event,
    Emitter<MapState> emit,
  ) {
    final hasMoved = event.center != state.searchCenter;
    emit(state.copyWith(
      searchCenter: event.center,
      hasCameraMoved: hasMoved,
    ));
  }

  Future<void> _onSearchInArea(
    SearchInAreaEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      hasCameraMoved: false,
      searchCenter: event.center,
      searchRadius: event.radius,
    ));

    try {
      final studios = await _studioService.findNearbyStudios(
        event.center,
        radius: event.radius,
      );

      emit(state.copyWith(
        isLoading: false,
        nearbyStudios: studios,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la recherche',
      ));
    }
  }

  void _onUpdateFilters(UpdateFiltersEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(
      serviceFilters: event.serviceFilters,
      partnerOnly: event.partnerOnly,
    ));
  }

  void _onClearFilters(ClearFiltersEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(
      serviceFilters: const {},
      partnerOnly: false,
    ));
  }
}
