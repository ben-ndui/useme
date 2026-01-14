import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useme/core/models/discovered_studio.dart';
import 'package:useme/core/services/location_service.dart';

/// Map State
class MapState {
  final bool isLoading;
  final bool isSearchingAddress;
  final LatLng userLocation;
  final LatLng searchCenter;
  final int searchRadius;
  final List<DiscoveredStudio> nearbyStudios;
  final DiscoveredStudio? selectedStudio;
  final String? error;
  final bool hasLocationPermission;
  final bool hasCameraMoved;
  final Set<String> serviceFilters;
  final bool partnerOnly;
  final String? searchQuery;

  const MapState({
    this.isLoading = false,
    this.isSearchingAddress = false,
    this.userLocation = LocationService.defaultPosition,
    this.searchCenter = LocationService.defaultPosition,
    this.searchRadius = 5000,
    this.nearbyStudios = const [],
    this.selectedStudio,
    this.error,
    this.hasLocationPermission = false,
    this.hasCameraMoved = false,
    this.serviceFilters = const {},
    this.partnerOnly = false,
    this.searchQuery,
  });

  MapState copyWith({
    bool? isLoading,
    bool? isSearchingAddress,
    LatLng? userLocation,
    LatLng? searchCenter,
    int? searchRadius,
    List<DiscoveredStudio>? nearbyStudios,
    DiscoveredStudio? selectedStudio,
    String? error,
    bool? hasLocationPermission,
    bool? hasCameraMoved,
    Set<String>? serviceFilters,
    bool? partnerOnly,
    String? searchQuery,
    bool clearSelectedStudio = false,
    bool clearError = false,
    bool clearSearchQuery = false,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      isSearchingAddress: isSearchingAddress ?? this.isSearchingAddress,
      userLocation: userLocation ?? this.userLocation,
      searchCenter: searchCenter ?? this.searchCenter,
      searchRadius: searchRadius ?? this.searchRadius,
      nearbyStudios: nearbyStudios ?? this.nearbyStudios,
      selectedStudio:
          clearSelectedStudio ? null : (selectedStudio ?? this.selectedStudio),
      error: clearError ? null : (error ?? this.error),
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      hasCameraMoved: hasCameraMoved ?? this.hasCameraMoved,
      serviceFilters: serviceFilters ?? this.serviceFilters,
      partnerOnly: partnerOnly ?? this.partnerOnly,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
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
  bool get hasActiveFilters => serviceFilters.isNotEmpty || partnerOnly;

  /// Get studios filtered by current filters
  List<DiscoveredStudio> get filteredStudios {
    if (!hasActiveFilters) return nearbyStudios;

    return nearbyStudios.where((studio) {
      // Partner filter
      if (partnerOnly && !studio.isPartner) return false;

      // Service filter (if studio has any of the selected services)
      if (serviceFilters.isNotEmpty) {
        final studioServices = studio.services.map((s) => s.toLowerCase()).toSet();
        final hasMatchingService = serviceFilters.any(
          (filter) => studioServices.contains(filter.toLowerCase()),
        );
        if (!hasMatchingService) return false;
      }

      return true;
    }).toList();
  }

  /// Get markers for filtered studios
  Set<Marker> get filteredMarkers {
    final Set<Marker> markerSet = {};

    for (final studio in filteredStudios) {
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
}
