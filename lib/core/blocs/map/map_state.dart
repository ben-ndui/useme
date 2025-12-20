import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useme/core/models/discovered_studio.dart';
import 'package:useme/core/services/location_service.dart';

/// Map State
class MapState {
  final bool isLoading;
  final LatLng userLocation;
  final List<DiscoveredStudio> nearbyStudios;
  final DiscoveredStudio? selectedStudio;
  final String? error;
  final bool hasLocationPermission;

  const MapState({
    this.isLoading = false,
    this.userLocation = LocationService.defaultPosition,
    this.nearbyStudios = const [],
    this.selectedStudio,
    this.error,
    this.hasLocationPermission = false,
  });

  MapState copyWith({
    bool? isLoading,
    LatLng? userLocation,
    List<DiscoveredStudio>? nearbyStudios,
    DiscoveredStudio? selectedStudio,
    String? error,
    bool? hasLocationPermission,
    bool clearSelectedStudio = false,
    bool clearError = false,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      userLocation: userLocation ?? this.userLocation,
      nearbyStudios: nearbyStudios ?? this.nearbyStudios,
      selectedStudio:
          clearSelectedStudio ? null : (selectedStudio ?? this.selectedStudio),
      error: clearError ? null : (error ?? this.error),
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
    );
  }

  /// Get markers for the map
  Set<Marker> get markers {
    final Set<Marker> markerSet = {};

    for (final studio in nearbyStudios) {
      markerSet.add(
        Marker(
          markerId: MarkerId(studio.id),
          position: studio.position,
          infoWindow: InfoWindow(
            title: studio.name,
            snippet: studio.formattedDistance,
          ),
          icon: studio.isPartner
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    return markerSet;
  }

  bool get hasStudios => nearbyStudios.isNotEmpty;
  bool get hasError => error != null && error!.isNotEmpty;
}
