import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'direction_step.dart';

/// Parsed result from the Google Directions API.
class DirectionsResult {
  final String summary;
  final List<LatLng> polylinePoints;
  final String duration;
  final String distance;
  final LatLng northeast;
  final LatLng southwest;
  final List<DirectionStep> steps;

  const DirectionsResult({
    required this.summary,
    required this.polylinePoints,
    required this.duration,
    required this.distance,
    required this.northeast,
    required this.southwest,
    required this.steps,
  });

  factory DirectionsResult.fromMap(Map<String, dynamic> map) {
    final route = map;
    final leg = route['legs'][0];
    final overview = route['overview_polyline']['points'] as String;

    return DirectionsResult(
      summary: route['summary'] ?? '',
      polylinePoints: _decodePolyline(overview),
      duration: leg['duration']['text'] ?? '',
      distance: leg['distance']['text'] ?? '',
      northeast: LatLng(
        route['bounds']['northeast']['lat'].toDouble(),
        route['bounds']['northeast']['lng'].toDouble(),
      ),
      southwest: LatLng(
        route['bounds']['southwest']['lat'].toDouble(),
        route['bounds']['southwest']['lng'].toDouble(),
      ),
      steps: (leg['steps'] as List)
          .map((s) => DirectionStep.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Camera bounds encompassing the entire route.
  LatLngBounds get bounds =>
      LatLngBounds(southwest: southwest, northeast: northeast);

  /// Decodes Google's encoded polyline string into LatLng points.
  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}
