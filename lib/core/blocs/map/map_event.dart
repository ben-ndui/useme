import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useme/core/models/discovered_studio.dart';

/// Map Events
abstract class MapEvent {
  const MapEvent();
}

/// Initialize the map and get user location
class InitMapEvent extends MapEvent {
  const InitMapEvent();
}

/// Load studios near a position
class LoadNearbyStudiosEvent extends MapEvent {
  final LatLng position;
  final int radius;

  const LoadNearbyStudiosEvent({
    required this.position,
    this.radius = 5000,
  });
}

/// Update user location
class UpdateUserLocationEvent extends MapEvent {
  final LatLng position;

  const UpdateUserLocationEvent({required this.position});
}

/// Select a studio on the map
class SelectStudioEvent extends MapEvent {
  final DiscoveredStudio studio;

  const SelectStudioEvent({required this.studio});
}

/// Deselect current studio
class DeselectStudioEvent extends MapEvent {
  const DeselectStudioEvent();
}

/// Refresh studios (force fetch)
class RefreshStudiosEvent extends MapEvent {
  const RefreshStudiosEvent();
}

/// Search studios by address (geocoding)
class SearchByAddressEvent extends MapEvent {
  final String address;
  final int radius;

  const SearchByAddressEvent({
    required this.address,
    this.radius = 5000,
  });
}

/// Update search center when user moves map
class UpdateSearchCenterEvent extends MapEvent {
  final LatLng center;

  const UpdateSearchCenterEvent({required this.center});
}

/// Search in the current visible area
class SearchInAreaEvent extends MapEvent {
  final LatLng center;
  final int radius;

  const SearchInAreaEvent({
    required this.center,
    this.radius = 5000,
  });
}

/// Update filters
class UpdateFiltersEvent extends MapEvent {
  final Set<String>? serviceFilters;
  final bool? partnerOnly;

  const UpdateFiltersEvent({
    this.serviceFilters,
    this.partnerOnly,
  });
}

/// Clear filters
class ClearFiltersEvent extends MapEvent {
  const ClearFiltersEvent();
}
