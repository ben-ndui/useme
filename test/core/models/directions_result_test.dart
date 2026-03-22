import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useme/core/models/navigation/navigation_exports.dart';

void main() {
  group('DirectionsResult', () {
    test('fromMap parses a valid directions API response', () {
      final map = {
        'summary': 'A8',
        'overview_polyline': {
          'points': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
        },
        'legs': [
          {
            'duration': {'text': '25 min', 'value': 1500},
            'distance': {'text': '18.2 km', 'value': 18200},
            'steps': [
              {
                'html_instructions': 'Head <b>north</b>',
                'duration': {'text': '2 min', 'value': 120},
                'distance': {'text': '500 m', 'value': 500},
                'start_location': {'lat': 43.71, 'lng': 7.26},
                'end_location': {'lat': 43.72, 'lng': 7.27},
              },
            ],
          },
        ],
        'bounds': {
          'northeast': {'lat': 43.75, 'lng': 7.30},
          'southwest': {'lat': 43.70, 'lng': 7.25},
        },
      };

      final result = DirectionsResult.fromMap(map);

      expect(result.summary, 'A8');
      expect(result.duration, '25 min');
      expect(result.distance, '18.2 km');
      expect(result.polylinePoints, isNotEmpty);
      expect(result.steps.length, 1);
      expect(result.steps.first.instructions, 'Head north');
      expect(result.bounds.northeast.latitude, 43.75);
      expect(result.bounds.southwest.longitude, 7.25);
    });

    test('polyline decoder produces valid LatLng points', () {
      // Known encoded polyline: "_p~iF~ps|U" decodes to ~(38.5, -120.2)
      final map = {
        'summary': '',
        'overview_polyline': {'points': '_p~iF~ps|U'},
        'legs': [
          {
            'duration': {'text': '1 min', 'value': 60},
            'distance': {'text': '100 m', 'value': 100},
            'steps': <Map<String, dynamic>>[],
          },
        ],
        'bounds': {
          'northeast': {'lat': 39.0, 'lng': -120.0},
          'southwest': {'lat': 38.0, 'lng': -121.0},
        },
      };

      final result = DirectionsResult.fromMap(map);
      expect(result.polylinePoints, isNotEmpty);
      final first = result.polylinePoints.first;
      expect(first.latitude, closeTo(38.5, 0.1));
      expect(first.longitude, closeTo(-120.2, 0.1));
    });
  });

  group('DirectionStep', () {
    test('fromMap cleans HTML instructions', () {
      final step = DirectionStep.fromMap({
        'html_instructions': 'Turn <b>left</b> onto <b>Rue de la Paix</b>',
        'duration': {'text': '1 min', 'value': 60},
        'distance': {'text': '200 m', 'value': 200},
        'start_location': {'lat': 43.71, 'lng': 7.26},
        'end_location': {'lat': 43.72, 'lng': 7.27},
      });

      expect(step.instructions, 'Turn left onto Rue de la Paix');
      expect(step.duration, '1 min');
      expect(step.distance, '200 m');
    });
  });

  group('TravelMode', () {
    test('apiValue matches name', () {
      expect(TravelMode.driving.apiValue, 'driving');
      expect(TravelMode.walking.apiValue, 'walking');
      expect(TravelMode.transit.apiValue, 'transit');
      expect(TravelMode.bicycling.apiValue, 'bicycling');
    });

    test('label returns localized string', () {
      expect(TravelMode.driving.label, isNotEmpty);
      expect(TravelMode.walking.label, isNotEmpty);
    });
  });
}
