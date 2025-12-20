import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service for handling user location
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _lastKnownPosition;

  /// Default position (Paris) if location not available
  static const LatLng defaultPosition = LatLng(48.8566, 2.3522);

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position with permission handling
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      _lastKnownPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return _lastKnownPosition;
    } catch (e) {
      return _lastKnownPosition;
    }
  }

  /// Get current position as LatLng
  Future<LatLng> getCurrentLatLng() async {
    final position = await getCurrentPosition();
    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    }
    return defaultPosition;
  }

  /// Get last known position
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Get last known LatLng or default
  LatLng get lastKnownLatLng {
    if (_lastKnownPosition != null) {
      return LatLng(_lastKnownPosition!.latitude, _lastKnownPosition!.longitude);
    }
    return defaultPosition;
  }

  /// Stream position updates
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters
      ),
    );
  }

  /// Calculate distance between two points in meters
  double distanceBetween(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Format distance for display
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}
