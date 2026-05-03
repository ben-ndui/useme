import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/payment_method.dart';
import 'package:uzme/core/models/pro_profile.dart';

void main() {
  group('ProType', () {
    test('fromString parses known values', () {
      expect(ProType.fromString('soundEngineer'), ProType.soundEngineer);
      expect(ProType.fromString('musician'), ProType.musician);
      expect(ProType.fromString('artisticDirector'), ProType.artisticDirector);
      expect(ProType.fromString('producer'), ProType.producer);
      expect(ProType.fromString('vocalist'), ProType.vocalist);
      expect(ProType.fromString('composer'), ProType.composer);
    });

    test('fromString defaults to soundEngineer for unknown', () {
      expect(ProType.fromString('unknown'), ProType.soundEngineer);
      expect(ProType.fromString(null), ProType.soundEngineer);
    });

    test('label returns localized name', () {
      expect(ProType.soundEngineer.label, contains('son'));
      expect(ProType.musician.label, 'Musicien');
      expect(ProType.artisticDirector.label, contains('Directeur'));
      expect(ProType.producer.label, contains('Beatmaker'));
      expect(ProType.vocalist.label, contains('Chanteur'));
      expect(ProType.composer.label, contains('Compositeur'));
    });

    test('all values have a non-empty label', () {
      for (final type in ProType.values) {
        expect(type.label, isNotEmpty);
      }
    });
  });

  group('ProProfile', () {
    const minimalProfile = ProProfile(displayName: 'DJ Test');

    group('defaults', () {
      test('has correct default values', () {
        expect(minimalProfile.proTypes, isEmpty);
        expect(minimalProfile.specialties, isEmpty);
        expect(minimalProfile.instruments, isEmpty);
        expect(minimalProfile.genres, isEmpty);
        expect(minimalProfile.daws, isEmpty);
        expect(minimalProfile.portfolioUrls, isEmpty);
        expect(minimalProfile.paymentMethods, isEmpty);
        expect(minimalProfile.profilePhotoUrl, isNull);
        expect(minimalProfile.currency, 'EUR');
        expect(minimalProfile.remote, isFalse);
        expect(minimalProfile.isVerified, isFalse);
        expect(minimalProfile.isAvailable, isTrue);
        expect(minimalProfile.hourlyRate, isNull);
        expect(minimalProfile.bio, isNull);
        expect(minimalProfile.city, isNull);
        expect(minimalProfile.location, isNull);
        expect(minimalProfile.workingHours, isNull);
        expect(minimalProfile.rating, isNull);
        expect(minimalProfile.reviewCount, isNull);
        expect(minimalProfile.activatedAt, isNull);
      });
    });

    group('computed properties', () {
      test('hasLocation', () {
        expect(minimalProfile.hasLocation, isFalse);
      });

      test('hasRate', () {
        expect(minimalProfile.hasRate, isFalse);
        const withRate = ProProfile(displayName: 'X', hourlyRate: 50);
        expect(withRate.hasRate, isTrue);
        const withZero = ProProfile(displayName: 'X', hourlyRate: 0);
        expect(withZero.hasRate, isFalse);
      });

      test('formattedRate with rate', () {
        const profile = ProProfile(displayName: 'X', hourlyRate: 60);
        expect(profile.formattedRate, '60 EUR/h');
      });

      test('formattedRate without rate', () {
        expect(minimalProfile.formattedRate, 'Sur devis');
      });

      test('formattedLocation with city', () {
        const profile = ProProfile(displayName: 'X', city: 'Paris');
        expect(profile.formattedLocation, 'Paris');
      });

      test('formattedLocation remote', () {
        const profile = ProProfile(displayName: 'X', remote: true);
        expect(profile.formattedLocation, 'A distance');
      });

      test('formattedLocation empty', () {
        expect(minimalProfile.formattedLocation, '');
      });

      test('isMusician', () {
        const profile = ProProfile(
          displayName: 'X',
          proTypes: [ProType.musician, ProType.composer],
        );
        expect(profile.isMusician, isTrue);
        expect(profile.isSoundEngineer, isFalse);
        expect(profile.isProducer, isFalse);
      });

      test('isSoundEngineer', () {
        const profile = ProProfile(
          displayName: 'X',
          proTypes: [ProType.soundEngineer],
        );
        expect(profile.isSoundEngineer, isTrue);
      });

      test('isProducer', () {
        const profile = ProProfile(
          displayName: 'X',
          proTypes: [ProType.producer],
        );
        expect(profile.isProducer, isTrue);
      });

      test('proTypesLabel joins labels', () {
        const profile = ProProfile(
          displayName: 'X',
          proTypes: [ProType.musician, ProType.producer],
        );
        expect(profile.proTypesLabel, contains('Musicien'));
        expect(profile.proTypesLabel, contains('Beatmaker'));
      });

      test('proTypesLabel empty when no types', () {
        expect(minimalProfile.proTypesLabel, '');
      });

      test('hasWorkingHours', () {
        expect(minimalProfile.hasWorkingHours, isFalse);
      });
    });

    group('fromMap', () {
      test('parses all fields', () {
        final profile = ProProfile.fromMap({
          'displayName': 'Beat Master',
          'proTypes': ['producer', 'soundEngineer'],
          'bio': 'Producer from Paris',
          'specialties': ['Trap', 'Drill'],
          'instruments': ['MPC', 'Keys'],
          'genres': ['Hip-Hop', 'Afro'],
          'daws': ['FL Studio', 'Ableton'],
          'hourlyRate': 75.0,
          'currency': 'USD',
          'remote': true,
          'city': 'Paris',
          'portfolioUrls': ['https://soundcloud.com/beat'],
          'website': 'https://beatmaster.com',
          'phone': '+33600000000',
          'rating': 4.8,
          'reviewCount': 42,
          'isVerified': true,
          'isAvailable': false,
        });

        expect(profile.displayName, 'Beat Master');
        expect(profile.proTypes, [ProType.producer, ProType.soundEngineer]);
        expect(profile.bio, 'Producer from Paris');
        expect(profile.specialties, ['Trap', 'Drill']);
        expect(profile.instruments, ['MPC', 'Keys']);
        expect(profile.genres, ['Hip-Hop', 'Afro']);
        expect(profile.daws, ['FL Studio', 'Ableton']);
        expect(profile.hourlyRate, 75.0);
        expect(profile.currency, 'USD');
        expect(profile.remote, isTrue);
        expect(profile.city, 'Paris');
        expect(profile.portfolioUrls, ['https://soundcloud.com/beat']);
        expect(profile.website, 'https://beatmaster.com');
        expect(profile.phone, '+33600000000');
        expect(profile.rating, 4.8);
        expect(profile.reviewCount, 42);
        expect(profile.isVerified, isTrue);
        expect(profile.isAvailable, isFalse);
      });

      test('handles missing fields with defaults', () {
        final profile = ProProfile.fromMap({});
        expect(profile.displayName, '');
        expect(profile.proTypes, isEmpty);
        expect(profile.specialties, isEmpty);
        expect(profile.currency, 'EUR');
        expect(profile.remote, isFalse);
        expect(profile.isVerified, isFalse);
        expect(profile.isAvailable, isTrue);
      });

      test('parses location as Map', () {
        final profile = ProProfile.fromMap({
          'displayName': 'X',
          'location': {'latitude': 48.85, 'longitude': 2.35},
        });
        expect(profile.hasLocation, isTrue);
        expect(profile.location!.latitude, 48.85);
        expect(profile.location!.longitude, 2.35);
      });

      test('parses activatedAt as ISO string', () {
        final profile = ProProfile.fromMap({
          'displayName': 'X',
          'activatedAt': '2024-06-15T10:00:00.000',
        });
        expect(profile.activatedAt, isNotNull);
        expect(profile.activatedAt!.year, 2024);
        expect(profile.activatedAt!.month, 6);
      });
    });

    group('toMap', () {
      test('serializes all fields', () {
        const profile = ProProfile(
          displayName: 'Mix Pro',
          proTypes: [ProType.soundEngineer],
          bio: 'Expert mix',
          specialties: ['Mix voix'],
          instruments: [],
          genres: ['Pop'],
          daws: ['Pro Tools'],
          hourlyRate: 80,
          currency: 'EUR',
          remote: true,
          city: 'Lyon',
          isVerified: true,
          isAvailable: true,
        );

        final map = profile.toMap();
        expect(map['displayName'], 'Mix Pro');
        expect(map['proTypes'], ['soundEngineer']);
        expect(map['bio'], 'Expert mix');
        expect(map['specialties'], ['Mix voix']);
        expect(map['genres'], ['Pop']);
        expect(map['daws'], ['Pro Tools']);
        expect(map['hourlyRate'], 80);
        expect(map['currency'], 'EUR');
        expect(map['remote'], isTrue);
        expect(map['city'], 'Lyon');
        expect(map['isVerified'], isTrue);
        expect(map['isAvailable'], isTrue);
      });
    });

    group('round-trip', () {
      test('fromMap(toMap()) preserves data', () {
        const original = ProProfile(
          displayName: 'Test Pro',
          proTypes: [ProType.musician, ProType.vocalist],
          bio: 'Multi-instrumentiste',
          specialties: ['Jazz', 'Soul'],
          instruments: ['Guitare', 'Basse'],
          genres: ['Jazz', 'Neo-Soul'],
          daws: ['Logic Pro'],
          hourlyRate: 45,
          remote: false,
          city: 'Bordeaux',
          isAvailable: true,
        );

        final map = original.toMap();
        // Remove Timestamp fields for test (would be Timestamp in Firestore)
        map.remove('activatedAt');
        final restored = ProProfile.fromMap(map);

        expect(restored.displayName, original.displayName);
        expect(restored.proTypes, original.proTypes);
        expect(restored.bio, original.bio);
        expect(restored.specialties, original.specialties);
        expect(restored.instruments, original.instruments);
        expect(restored.genres, original.genres);
        expect(restored.daws, original.daws);
        expect(restored.hourlyRate, original.hourlyRate);
        expect(restored.remote, original.remote);
        expect(restored.city, original.city);
        expect(restored.isAvailable, original.isAvailable);
      });
    });

    group('copyWith', () {
      test('modifies specified fields only', () {
        const original = ProProfile(
          displayName: 'Original',
          proTypes: [ProType.musician],
          hourlyRate: 50,
          city: 'Paris',
        );

        final modified = original.copyWith(
          displayName: 'Modified',
          hourlyRate: 75,
          remote: true,
        );

        expect(modified.displayName, 'Modified');
        expect(modified.hourlyRate, 75);
        expect(modified.remote, isTrue);
        // unchanged
        expect(modified.proTypes, [ProType.musician]);
        expect(modified.city, 'Paris');
      });
    });

    group('paymentMethods', () {
      test('hasPaymentMethods is false when empty', () {
        expect(minimalProfile.hasPaymentMethods, isFalse);
      });

      test('hasPaymentMethods is true with enabled methods', () {
        const profile = ProProfile(
          displayName: 'X',
          paymentMethods: [
            PaymentMethod(type: PaymentMethodType.paypal, isEnabled: true),
          ],
        );
        expect(profile.hasPaymentMethods, isTrue);
      });

      test('enabledPaymentMethods filters disabled', () {
        const profile = ProProfile(
          displayName: 'X',
          paymentMethods: [
            PaymentMethod(type: PaymentMethodType.paypal, isEnabled: true),
            PaymentMethod(type: PaymentMethodType.cash, isEnabled: false),
            PaymentMethod(type: PaymentMethodType.bankTransfer, isEnabled: true, details: 'FR76...'),
          ],
        );
        expect(profile.enabledPaymentMethods, hasLength(2));
        expect(profile.enabledPaymentMethods.map((m) => m.type),
            containsAll([PaymentMethodType.paypal, PaymentMethodType.bankTransfer]));
      });

      test('fromMap parses paymentMethods', () {
        final profile = ProProfile.fromMap({
          'displayName': 'X',
          'paymentMethods': [
            {'type': 'paypal', 'isEnabled': true, 'details': 'me@paypal.com'},
            {'type': 'bankTransfer', 'isEnabled': true, 'details': 'FR76123', 'bic': 'BNPAFRPP'},
          ],
        });
        expect(profile.paymentMethods, hasLength(2));
        expect(profile.paymentMethods[0].type, PaymentMethodType.paypal);
        expect(profile.paymentMethods[0].details, 'me@paypal.com');
        expect(profile.paymentMethods[1].bic, 'BNPAFRPP');
      });

      test('toMap serializes paymentMethods', () {
        const profile = ProProfile(
          displayName: 'X',
          paymentMethods: [
            PaymentMethod(type: PaymentMethodType.cash, isEnabled: true),
          ],
        );
        final map = profile.toMap();
        expect(map['paymentMethods'], isList);
        expect((map['paymentMethods'] as List).first['type'], 'cash');
      });

      test('copyWith updates paymentMethods', () {
        const methods = [
          PaymentMethod(type: PaymentMethodType.card, isEnabled: true),
        ];
        final updated = minimalProfile.copyWith(paymentMethods: methods);
        expect(updated.paymentMethods, hasLength(1));
        expect(updated.paymentMethods.first.type, PaymentMethodType.card);
        expect(updated.displayName, 'DJ Test');
      });

      test('round-trip preserves paymentMethods', () {
        const original = ProProfile(
          displayName: 'X',
          paymentMethods: [
            PaymentMethod(
              type: PaymentMethodType.bankTransfer,
              isEnabled: true,
              details: 'FR7612345',
              bic: 'BNPAFRPP',
              accountHolder: 'Jean Pro',
            ),
          ],
        );
        final map = original.toMap();
        map.remove('activatedAt');
        final restored = ProProfile.fromMap(map);
        expect(restored.paymentMethods, hasLength(1));
        expect(restored.paymentMethods.first.details, 'FR7612345');
        expect(restored.paymentMethods.first.bic, 'BNPAFRPP');
        expect(restored.paymentMethods.first.accountHolder, 'Jean Pro');
      });
    });

    group('profilePhotoUrl', () {
      test('defaults to null', () {
        expect(minimalProfile.profilePhotoUrl, isNull);
      });

      test('fromMap parses profilePhotoUrl', () {
        final profile = ProProfile.fromMap({
          'displayName': 'X',
          'profilePhotoUrl': 'https://example.com/photo.jpg',
        });
        expect(profile.profilePhotoUrl, 'https://example.com/photo.jpg');
      });

      test('toMap serializes profilePhotoUrl', () {
        const profile = ProProfile(
          displayName: 'X',
          profilePhotoUrl: 'https://example.com/photo.jpg',
        );
        final map = profile.toMap();
        expect(map['profilePhotoUrl'], 'https://example.com/photo.jpg');
      });

      test('toMap serializes null profilePhotoUrl', () {
        const profile = ProProfile(displayName: 'X');
        final map = profile.toMap();
        expect(map['profilePhotoUrl'], isNull);
      });

      test('copyWith updates profilePhotoUrl', () {
        final updated = minimalProfile.copyWith(
          profilePhotoUrl: 'https://example.com/new.jpg',
        );
        expect(updated.profilePhotoUrl, 'https://example.com/new.jpg');
        expect(updated.displayName, 'DJ Test');
      });

      test('round-trip preserves profilePhotoUrl', () {
        const original = ProProfile(
          displayName: 'X',
          profilePhotoUrl: 'https://example.com/photo.jpg',
          portfolioUrls: ['https://example.com/p1.jpg'],
        );
        final map = original.toMap();
        map.remove('activatedAt');
        final restored = ProProfile.fromMap(map);
        expect(restored.profilePhotoUrl, 'https://example.com/photo.jpg');
      });
    });

    group('defaultDepositPercent', () {
      test('defaults to null', () {
        expect(minimalProfile.defaultDepositPercent, isNull);
      });

      test('fromMap parses defaultDepositPercent', () {
        final profile = ProProfile.fromMap({
          'displayName': 'X',
          'defaultDepositPercent': 50.0,
        });
        expect(profile.defaultDepositPercent, 50.0);
      });

      test('toMap serializes defaultDepositPercent', () {
        const profile = ProProfile(
          displayName: 'X',
          defaultDepositPercent: 40,
        );
        final map = profile.toMap();
        expect(map['defaultDepositPercent'], 40);
      });

      test('copyWith updates defaultDepositPercent', () {
        final updated =
            minimalProfile.copyWith(defaultDepositPercent: 25);
        expect(updated.defaultDepositPercent, 25);
        expect(updated.displayName, 'DJ Test');
      });
    });

    group('equality', () {
      test('equal profiles are equal', () {
        const a = ProProfile(
          displayName: 'Pro',
          proTypes: [ProType.soundEngineer],
        );
        const b = ProProfile(
          displayName: 'Pro',
          proTypes: [ProType.soundEngineer],
        );
        expect(a, equals(b));
      });

      test('different profiles are not equal', () {
        const a = ProProfile(displayName: 'Pro A');
        const b = ProProfile(displayName: 'Pro B');
        expect(a, isNot(equals(b)));
      });

      test('different paymentMethods make profiles unequal', () {
        const a = ProProfile(
          displayName: 'Pro',
          paymentMethods: [PaymentMethod(type: PaymentMethodType.cash)],
        );
        const b = ProProfile(displayName: 'Pro');
        expect(a, isNot(equals(b)));
      });
    });
  });
}
