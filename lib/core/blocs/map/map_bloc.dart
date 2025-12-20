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
        userLocation: event.position,
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
}
