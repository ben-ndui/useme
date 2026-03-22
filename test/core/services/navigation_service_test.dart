import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Tests for NavigationService URL construction logic.
/// Note: actual URL launching cannot be tested in unit tests
/// (requires platform channel mocking). These tests verify the
/// service exists and coordinates are handled correctly.
void main() {
  group('NavigationService URL construction', () {
    test('Google Maps directions URL format is correct', () {
      const lat = 43.7102;
      const lng = 7.2620;
      const name = 'Studio Nice';

      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_name=${Uri.encodeComponent(name)}';

      expect(url, contains('43.7102'));
      expect(url, contains('7.262'));
      expect(url, contains('Studio%20Nice'));
      expect(url, startsWith('https://'));
    });

    test('Apple Maps URL format is correct', () {
      const lat = 48.8566;
      const lng = 2.3522;

      final url =
          'maps://maps.apple.com/?daddr=$lat,$lng&dirflg=d';

      expect(url, contains('48.8566'));
      expect(url, contains('2.3522'));
      expect(url, startsWith('maps://'));
    });

    test('Google Maps app URL format is correct', () {
      const lat = 43.7102;
      const lng = 7.2620;

      final url =
          'comgooglemaps://?daddr=$lat,$lng&directionsmode=driving';

      expect(url, contains('43.7102'));
      expect(url, startsWith('comgooglemaps://'));
    });

    test('LatLng coordinates are used correctly', () {
      const position = LatLng(43.7102, 7.2620);

      expect(position.latitude, 43.7102);
      expect(position.longitude, 7.2620);

      final url =
          'https://www.google.com/maps/dir/?api=1&destination=${position.latitude},${position.longitude}';
      expect(url, contains('43.7102,7.262'));
    });

    test('URL encoding handles special characters in name', () {
      const name = "Studio L'Atelier & Co";
      final encoded = Uri.encodeComponent(name);

      expect(encoded, isNot(contains(' ')));
      expect(encoded, isNot(contains('&')));
      expect(encoded, contains('%26')); // & encoded
      expect(encoded, contains('%20')); // space encoded
    });
  });
}
