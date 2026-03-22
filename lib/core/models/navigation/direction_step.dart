import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A single step in turn-by-turn directions.
class DirectionStep {
  final String instructions;
  final String duration;
  final String distance;
  final LatLng startLocation;
  final LatLng endLocation;

  const DirectionStep({
    required this.instructions,
    required this.duration,
    required this.distance,
    required this.startLocation,
    required this.endLocation,
  });

  factory DirectionStep.fromMap(Map<String, dynamic> map) {
    return DirectionStep(
      instructions: _cleanHtml(map['html_instructions'] ?? ''),
      duration: map['duration']['text'] ?? '',
      distance: map['distance']['text'] ?? '',
      startLocation: LatLng(
        map['start_location']['lat'].toDouble(),
        map['start_location']['lng'].toDouble(),
      ),
      endLocation: LatLng(
        map['end_location']['lat'].toDouble(),
        map['end_location']['lng'].toDouble(),
      ),
    );
  }

  static String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}
