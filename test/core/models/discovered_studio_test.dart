import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uzme/core/models/discovered_studio.dart';
import 'package:uzme/core/models/studio_profile.dart';

void main() {
  const parisPosition = LatLng(48.8566, 2.3522);

  const testStudio = DiscoveredStudio(
    id: 'studio-1',
    name: 'Cool Studio',
    address: '1 rue de la Musique, Paris',
    position: parisPosition,
    rating: 4.5,
    reviewCount: 120,
    isPartner: true,
    isVerified: true,
    services: ['Recording', 'Mixing', 'Mastering'],
    distanceMeters: 1500,
    studioType: StudioType.pro,
  );

  group('formattedDistance', () {
    test('formats meters when < 1000', () {
      const studio = DiscoveredStudio(
        id: 's',
        name: 'S',
        position: parisPosition,
        distanceMeters: 500,
      );
      expect(studio.formattedDistance, '500 m');
    });

    test('rounds meters', () {
      const studio = DiscoveredStudio(
        id: 's',
        name: 'S',
        position: parisPosition,
        distanceMeters: 423.7,
      );
      expect(studio.formattedDistance, '424 m');
    });

    test('formats km when >= 1000', () {
      expect(testStudio.formattedDistance, '1.5 km');
    });

    test('formats km with decimal', () {
      const studio = DiscoveredStudio(
        id: 's',
        name: 'S',
        position: parisPosition,
        distanceMeters: 2350,
      );
      expect(studio.formattedDistance, '2.4 km');
    });

    test('returns empty when distance is null', () {
      const studio = DiscoveredStudio(
        id: 's',
        name: 'S',
        position: parisPosition,
      );
      expect(studio.formattedDistance, '');
    });
  });

  group('copyWithDistance', () {
    test('sets distance and preserves all fields', () {
      const studio = DiscoveredStudio(
        id: 'studio-1',
        name: 'Test',
        address: 'Addr',
        position: parisPosition,
        isPartner: true,
        services: ['Mix'],
        studioType: StudioType.pro,
      );
      final withDist = studio.copyWithDistance(750);
      expect(withDist.distanceMeters, 750);
      expect(withDist.id, 'studio-1');
      expect(withDist.name, 'Test');
      expect(withDist.isPartner, isTrue);
      expect(withDist.services, ['Mix']);
      expect(withDist.studioType, StudioType.pro);
    });
  });

  group('fromFirestore', () {
    test('parses internal studio data', () {
      final studio = DiscoveredStudio.fromFirestore({
        'name': 'Internal Studio',
        'address': '10 rue du Son',
        'latitude': 48.85,
        'longitude': 2.35,
        'rating': 4.0,
        'reviewCount': 50,
        'photoURL': 'https://img.com/photo.jpg',
        'phoneNumber': '+33612345678',
        'website': 'https://studio.com',
        'isVerified': true,
        'services': ['Recording'],
        'studioType': 'pro',
      }, 'doc-id');

      expect(studio.id, 'doc-id');
      expect(studio.name, 'Internal Studio');
      expect(studio.address, '10 rue du Son');
      expect(studio.position.latitude, 48.85);
      expect(studio.position.longitude, 2.35);
      expect(studio.rating, 4.0);
      expect(studio.isPartner, isTrue); // always true from Firestore
      expect(studio.isVerified, isTrue);
      expect(studio.services, ['Recording']);
      expect(studio.studioType, StudioType.pro);
      expect(studio.photoUrl, 'https://img.com/photo.jpg');
      expect(studio.phoneNumber, '+33612345678');
    });

    test('handles displayName fallback', () {
      final studio = DiscoveredStudio.fromFirestore({
        'displayName': 'Display Name',
      }, 'id');
      expect(studio.name, 'Display Name');
    });

    test('handles lat/lng alias', () {
      final studio = DiscoveredStudio.fromFirestore({
        'lat': 45.0,
        'lng': 3.0,
      }, 'id');
      expect(studio.position.latitude, 45.0);
      expect(studio.position.longitude, 3.0);
    });

    test('handles photoUrl alias', () {
      final studio = DiscoveredStudio.fromFirestore({
        'photoUrl': 'https://alt.com/photo.jpg',
      }, 'id');
      expect(studio.photoUrl, 'https://alt.com/photo.jpg');
    });

    test('handles missing fields with defaults', () {
      final studio = DiscoveredStudio.fromFirestore({}, 'id');
      expect(studio.name, 'Studio');
      expect(studio.position.latitude, 0);
      expect(studio.position.longitude, 0);
      expect(studio.services, isEmpty);
      expect(studio.studioType, StudioType.independent);
    });
  });

  group('fromGooglePlace', () {
    test('parses Google Places response', () {
      final studio = DiscoveredStudio.fromGooglePlace({
        'place_id': 'gp-123',
        'name': 'Google Studio',
        'vicinity': '5 rue Test',
        'geometry': {
          'location': {'lat': 48.86, 'lng': 2.34},
        },
        'rating': 4.2,
        'user_ratings_total': 85,
      });

      expect(studio.id, 'gp-123');
      expect(studio.name, 'Google Studio');
      expect(studio.address, '5 rue Test');
      expect(studio.position.latitude, 48.86);
      expect(studio.position.longitude, 2.34);
      expect(studio.rating, 4.2);
      expect(studio.reviewCount, 85);
      expect(studio.isPartner, isFalse);
      expect(studio.isVerified, isFalse);
    });

    test('uses formatted_address fallback', () {
      final studio = DiscoveredStudio.fromGooglePlace({
        'place_id': 'gp',
        'name': 'S',
        'formatted_address': 'Full Address, City',
        'geometry': {
          'location': {'lat': 0, 'lng': 0},
        },
      });
      expect(studio.address, 'Full Address, City');
    });

    test('handles missing fields', () {
      final studio = DiscoveredStudio.fromGooglePlace({
        'geometry': {
          'location': {'lat': 0, 'lng': 0},
        },
      });
      expect(studio.id, '');
      expect(studio.name, 'Studio inconnu');
      expect(studio.rating, isNull);
    });
  });

  group('defaults', () {
    test('isPartner defaults to false', () {
      const studio = DiscoveredStudio(
        id: 's',
        name: 'S',
        position: parisPosition,
      );
      expect(studio.isPartner, isFalse);
    });

    test('studioType defaults to independent', () {
      const studio = DiscoveredStudio(
        id: 's',
        name: 'S',
        position: parisPosition,
      );
      expect(studio.studioType, StudioType.independent);
    });
  });

  group('equality', () {
    test('same id are equal', () {
      const a = DiscoveredStudio(
        id: 'same',
        name: 'A',
        position: parisPosition,
      );
      const b = DiscoveredStudio(
        id: 'same',
        name: 'B',
        position: LatLng(0, 0),
      );
      expect(a, equals(b));
    });

    test('different id are not equal', () {
      const a = DiscoveredStudio(
        id: 'a',
        name: 'Same',
        position: parisPosition,
      );
      const b = DiscoveredStudio(
        id: 'b',
        name: 'Same',
        position: parisPosition,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('StudioType', () {
    test('fromString parses valid types', () {
      expect(StudioType.fromString('pro'), StudioType.pro);
      expect(StudioType.fromString('independent'), StudioType.independent);
      expect(StudioType.fromString('amateur'), StudioType.amateur);
    });

    test('fromString defaults to independent', () {
      expect(StudioType.fromString(null), StudioType.independent);
      expect(StudioType.fromString('unknown'), StudioType.independent);
    });
  });
}
