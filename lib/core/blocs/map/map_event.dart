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
