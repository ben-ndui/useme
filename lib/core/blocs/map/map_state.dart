import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uzme/core/models/discovered_studio.dart';
import 'package:uzme/core/models/navigation/navigation_exports.dart';
import 'package:uzme/core/services/location_service.dart';

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
  final DirectionsResult? directions;
  final DiscoveredStudio? directionsDestination;
  final TravelMode travelMode;
  final bool isLoadingDirections;

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
    this.directions,
    this.directionsDestination,
    this.travelMode = TravelMode.driving,
    this.isLoadingDirections = false,
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
    DirectionsResult? directions,
    DiscoveredStudio? directionsDestination,
    TravelMode? travelMode,
    bool? isLoadingDirections,
    bool clearSelectedStudio = false,
    bool clearError = false,
    bool clearSearchQuery = false,
    bool clearDirections = false,
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
      directions: clearDirections ? null : (directions ?? this.directions),
      directionsDestination: clearDirections
          ? null
          : (directionsDestination ?? this.directionsDestination),
      travelMode: travelMode ?? this.travelMode,
      isLoadingDirections: isLoadingDirections ?? this.isLoadingDirections,
    );
  }

  /// Whether directions are currently displayed.
  bool get hasDirections => directions != null;

  /// Polylines for the route.
  Set<Polyline> get routePolylines {
    if (directions == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: directions!.polylinePoints,
        color: const Color(0xFF6C63FF), // UZME primary purple
        width: 5,
        patterns: [],
        jointType: JointType.round,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
      ),
    };
  }

  static double _markerHue(DiscoveredStudio studio) {
    if (studio.isPro) return BitmapDescriptor.hueOrange;
    if (studio.isPartner) return BitmapDescriptor.hueGreen;
    return BitmapDescriptor.hueAzure;
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
          icon: BitmapDescriptor.defaultMarkerWithHue(_markerHue(studio)),
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
      // Pros are always shown (not affected by studio-specific filters)
      if (studio.isPro) return true;

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
          icon: BitmapDescriptor.defaultMarkerWithHue(_markerHue(studio)),
        ),
      );
    }

    return markerSet;
  }
}
