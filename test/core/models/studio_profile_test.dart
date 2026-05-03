import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/studio_profile.dart';

void main() {
  const testProfile = StudioProfile(
    name: 'Studio Test',
    description: 'A cool studio',
    address: '10 rue du Son',
    city: 'Paris',
    postalCode: '75001',
    country: 'France',
    photos: ['photo1.jpg', 'photo2.jpg'],
    genres: ['Hip-Hop', 'R&B'],
    services: ['Recording', 'Mixing'],
    hourlyRate: 50.0,
    currency: 'EUR',
    googlePlaceId: 'gp-123',
    googlePlaceName: 'Studio Google',
    rating: 4.5,
    reviewCount: 100,
    website: 'https://studio.com',
    phone: '+33612345678',
    isVerified: true,
    allowNoEngineer: true,
    studioType: StudioType.pro,
  );

  group('fullAddress', () {
    test('joins all address parts', () {
      expect(
        testProfile.fullAddress,
        '10 rue du Son, 75001, Paris, France',
      );
    });

    test('skips null parts', () {
      const profile = StudioProfile(
        name: 'S',
        city: 'Lyon',
        country: 'France',
      );
      expect(profile.fullAddress, 'Lyon, France');
    });

    test('skips empty parts', () {
      const profile = StudioProfile(
        name: 'S',
        address: '',
        city: 'Marseille',
        postalCode: '',
      );
      expect(profile.fullAddress, 'Marseille');
    });

    test('returns empty when no address parts', () {
      const profile = StudioProfile(name: 'S');
      expect(profile.fullAddress, '');
    });
  });

  group('boolean helpers', () {
    test('hasLocation', () {
      expect(testProfile.hasLocation, isFalse); // no location set
    });

    test('isLinkedToGoogle', () {
      expect(testProfile.isLinkedToGoogle, isTrue);
      expect(
        const StudioProfile(name: 'S').isLinkedToGoogle,
        isFalse,
      );
    });

    test('hasWorkingHours', () {
      expect(testProfile.hasWorkingHours, isFalse); // no workingHours set
      expect(const StudioProfile(name: 'S').hasWorkingHours, isFalse);
    });
  });

  group('defaults', () {
    test('default values', () {
      const profile = StudioProfile(name: 'S');
      expect(profile.photos, isEmpty);
      expect(profile.genres, isEmpty);
      expect(profile.services, isEmpty);
      expect(profile.currency, 'EUR');
      expect(profile.isVerified, isFalse);
      expect(profile.allowNoEngineer, isFalse);
      expect(profile.studioType, StudioType.independent);
      expect(profile.hourlyRate, isNull);
      expect(profile.rating, isNull);
    });
  });

  group('fromMap', () {
    test('parses all fields', () {
      final profile = StudioProfile.fromMap({
        'name': 'Map Studio',
        'description': 'Desc',
        'address': '1 rue A',
        'city': 'Lyon',
        'postalCode': '69001',
        'country': 'France',
        'photos': ['p1.jpg'],
        'genres': ['Jazz'],
        'services': ['Mastering'],
        'hourlyRate': 75,
        'currency': 'USD',
        'googlePlaceId': 'gp-abc',
        'googlePlaceName': 'Google Studio',
        'rating': 4.2,
        'reviewCount': 50,
        'website': 'https://web.com',
        'phone': '+33600000000',
        'isVerified': true,
        'allowNoEngineer': true,
        'studioType': 'pro',
      });

      expect(profile.name, 'Map Studio');
      expect(profile.description, 'Desc');
      expect(profile.city, 'Lyon');
      expect(profile.photos, ['p1.jpg']);
      expect(profile.genres, ['Jazz']);
      expect(profile.services, ['Mastering']);
      expect(profile.hourlyRate, 75.0);
      expect(profile.currency, 'USD');
      expect(profile.googlePlaceId, 'gp-abc');
      expect(profile.rating, 4.2);
      expect(profile.reviewCount, 50);
      expect(profile.isVerified, isTrue);
      expect(profile.allowNoEngineer, isTrue);
      expect(profile.studioType, StudioType.pro);
    });

    test('handles location as Map', () {
      final profile = StudioProfile.fromMap({
        'name': 'S',
        'location': {'latitude': 48.85, 'longitude': 2.35},
      });
      expect(profile.hasLocation, isTrue);
      expect(profile.location!.latitude, 48.85);
      expect(profile.location!.longitude, 2.35);
    });

    test('handles missing fields with defaults', () {
      final profile = StudioProfile.fromMap({});
      expect(profile.name, '');
      expect(profile.photos, isEmpty);
      expect(profile.genres, isEmpty);
      expect(profile.services, isEmpty);
      expect(profile.currency, 'EUR');
      expect(profile.isVerified, isFalse);
      expect(profile.allowNoEngineer, isFalse);
      expect(profile.studioType, StudioType.independent);
    });
  });

  group('toMap', () {
    test('includes all fields', () {
      final map = testProfile.toMap();
      expect(map['name'], 'Studio Test');
      expect(map['description'], 'A cool studio');
      expect(map['address'], '10 rue du Son');
      expect(map['city'], 'Paris');
      expect(map['photos'], ['photo1.jpg', 'photo2.jpg']);
      expect(map['genres'], ['Hip-Hop', 'R&B']);
      expect(map['services'], ['Recording', 'Mixing']);
      expect(map['hourlyRate'], 50.0);
      expect(map['currency'], 'EUR');
      expect(map['isVerified'], isTrue);
      expect(map['allowNoEngineer'], isTrue);
      expect(map['studioType'], 'pro');
    });
  });

  group('copyWith', () {
    test('modifies specified fields', () {
      final modified = testProfile.copyWith(
        name: 'New Name',
        city: 'Lyon',
        studioType: StudioType.amateur,
      );
      expect(modified.name, 'New Name');
      expect(modified.city, 'Lyon');
      expect(modified.studioType, StudioType.amateur);
      expect(modified.description, 'A cool studio'); // unchanged
      expect(modified.hourlyRate, 50.0); // unchanged
    });
  });
}
