import 'package:flutter_test/flutter_test.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/pro_profile.dart';

void main() {
  const studioUser = AppUser(
    uid: 'u-1',
    email: 'studio@test.com',
    name: 'Studio Name',
    displayName: 'Cool Studio',
    role: BaseUserRole.admin,
    isPartner: true,
  );

  const engineerUser = AppUser(
    uid: 'u-2',
    email: 'eng@test.com',
    name: 'Eng Name',
    role: BaseUserRole.worker,
    studioId: 'studio-1',
  );

  const artistUser = AppUser(
    uid: 'u-3',
    email: 'artist@test.com',
    displayName: 'DJ Artist',
    role: BaseUserRole.client,
    stageName: 'DJ Art',
    genres: ['Hip-Hop', 'R&B'],
    studioIds: ['studio-1', 'studio-2'],
    city: 'Paris',
  );

  const superAdmin = AppUser(
    uid: 'u-4',
    email: 'admin@test.com',
    role: BaseUserRole.superAdmin,
    isDevMaster: true,
  );

  group('role helpers', () {
    test('isStudio', () {
      expect(studioUser.isStudio, isTrue);
      expect(engineerUser.isStudio, isFalse);
      expect(artistUser.isStudio, isFalse);
    });

    test('isEngineer', () {
      expect(engineerUser.isEngineer, isTrue);
      expect(studioUser.isEngineer, isFalse);
    });

    test('isArtist', () {
      expect(artistUser.isArtist, isTrue);
      expect(studioUser.isArtist, isFalse);
    });

    test('isSuperAdmin', () {
      expect(superAdmin.isSuperAdmin, isTrue);
      expect(studioUser.isSuperAdmin, isFalse);
    });
  });

  group('UseMeRoleExtension', () {
    test('useMeLabel', () {
      expect(BaseUserRole.admin.useMeLabel, 'Studio');
      expect(BaseUserRole.worker.useMeLabel, 'Ingénieur');
      expect(BaseUserRole.client.useMeLabel, 'Artiste');
      expect(BaseUserRole.superAdmin.useMeLabel, 'Super Admin');
    });

    test('useMeDescription is not empty', () {
      for (final role in BaseUserRole.values) {
        expect(role.useMeDescription, isNotEmpty);
      }
    });

    test('role boolean shortcuts', () {
      expect(BaseUserRole.admin.isStudio, isTrue);
      expect(BaseUserRole.worker.isEngineer, isTrue);
      expect(BaseUserRole.client.isArtist, isTrue);
      expect(BaseUserRole.superAdmin.isSuperAdmin, isTrue);
    });
  });

  group('studioDisplayName', () {
    test('returns studioProfile name when available', () {
      // No studioProfile set, falls back to displayName
      expect(studioUser.studioDisplayName, 'Cool Studio');
    });

    test('returns displayName when no profile', () {
      const user = AppUser(
        uid: 'u',
        email: 'e',
        displayName: 'Display',
        role: BaseUserRole.admin,
      );
      expect(user.studioDisplayName, 'Display');
    });

    test('returns name when no displayName', () {
      const user = AppUser(
        uid: 'u',
        email: 'e',
        name: 'Name',
        role: BaseUserRole.admin,
      );
      expect(user.studioDisplayName, 'Name');
    });

    test('returns Studio when no name at all', () {
      const user = AppUser(uid: 'u', email: 'e', role: BaseUserRole.admin);
      expect(user.studioDisplayName, 'Studio');
    });
  });

  group('hasStudioProfile', () {
    test('false when not partner', () {
      const user = AppUser(
        uid: 'u',
        email: 'e',
        isPartner: false,
      );
      expect(user.hasStudioProfile, isFalse);
    });

    test('false when partner but no profile', () {
      const user = AppUser(
        uid: 'u',
        email: 'e',
        isPartner: true,
      );
      expect(user.hasStudioProfile, isFalse);
    });
  });

  group('hasCalendarConnected', () {
    test('false when no connection', () {
      expect(artistUser.hasCalendarConnected, isFalse);
    });
  });

  group('subscription helpers', () {
    test('subscriptionTierId defaults to free', () {
      expect(artistUser.subscriptionTierId, 'free');
    });

    test('hasActiveSubscription defaults to true', () {
      expect(artistUser.hasActiveSubscription, isTrue);
    });

    test('hasPaidSubscription defaults to false', () {
      expect(artistUser.hasPaidSubscription, isFalse);
    });

    test('sessionsThisMonth defaults to 0', () {
      expect(artistUser.sessionsThisMonth, 0);
    });
  });

  group('defaults', () {
    test('role defaults to client', () {
      const user = AppUser(uid: 'u', email: 'e');
      expect(user.role, BaseUserRole.client);
    });

    test('isFirstTime defaults to true', () {
      const user = AppUser(uid: 'u', email: 'e');
      expect(user.isFirstTime, isTrue);
    });

    test('isPartner defaults to false', () {
      const user = AppUser(uid: 'u', email: 'e');
      expect(user.isPartner, isFalse);
    });

    test('isDevMaster defaults to false', () {
      const user = AppUser(uid: 'u', email: 'e');
      expect(user.isDevMaster, isFalse);
    });

    test('studioIds defaults to empty', () {
      const user = AppUser(uid: 'u', email: 'e');
      expect(user.studioIds, isEmpty);
    });

    test('genres defaults to empty', () {
      const user = AppUser(uid: 'u', email: 'e');
      expect(user.genres, isEmpty);
    });
  });

  group('copyWith', () {
    test('modifies specified fields', () {
      final modified = artistUser.copyWith(
        displayName: 'New Name',
        city: 'Lyon',
        role: BaseUserRole.admin,
      );
      expect(modified.displayName, 'New Name');
      expect(modified.city, 'Lyon');
      expect(modified.role, BaseUserRole.admin);
      expect(modified.uid, 'u-3'); // unchanged
      expect(modified.email, 'artist@test.com'); // unchanged
      expect(modified.genres, ['Hip-Hop', 'R&B']); // unchanged
    });
  });

  group('fromMap', () {
    test('parses basic fields', () {
      final user = AppUser.fromMap({
        'uid': 'u-5',
        'email': 'test@test.com',
        'name': 'Test',
        'displayName': 'Test Display',
        'role': 'admin',
        'isPartner': true,
        'isDevMaster': false,
      });

      expect(user.uid, 'u-5');
      expect(user.email, 'test@test.com');
      expect(user.name, 'Test');
      expect(user.displayName, 'Test Display');
      expect(user.role, BaseUserRole.admin);
      expect(user.isPartner, isTrue);
    });

    test('parses with document id override', () {
      final user = AppUser.fromMap({'email': 'a@b.com'}, 'doc-id');
      expect(user.uid, 'doc-id');
    });

    test('parses artist fields', () {
      final user = AppUser.fromMap({
        'uid': 'u-6',
        'email': 'a@b.com',
        'role': 'client',
        'stageName': 'MC Test',
        'genres': ['Rap', 'Trap'],
        'studioIds': ['s1', 's2'],
        'city': 'Marseille',
        'bio': 'Artiste from MRS',
      });

      expect(user.stageName, 'MC Test');
      expect(user.genres, ['Rap', 'Trap']);
      expect(user.studioIds, ['s1', 's2']);
      expect(user.city, 'Marseille');
      expect(user.bio, 'Artiste from MRS');
    });

    test('handles photoUrl legacy field', () {
      final user = AppUser.fromMap({
        'uid': 'u',
        'email': 'e',
        'photo_Url': 'https://photo.com/img.jpg',
      });
      expect(user.phoneNumber, isNull);
      expect(user.photoURL, 'https://photo.com/img.jpg');
    });

    test('handles phone legacy field', () {
      final user = AppUser.fromMap({
        'uid': 'u',
        'email': 'e',
        'phone': '+33612345678',
      });
      expect(user.phoneNumber, '+33612345678');
    });

    test('defaults when fields missing', () {
      final user = AppUser.fromMap({});
      expect(user.uid, '');
      expect(user.email, '');
      expect(user.isFirstTime, isTrue);
      expect(user.isPartner, isFalse);
      expect(user.studioIds, isEmpty);
      expect(user.genres, isEmpty);
    });
  });

  group('toMap', () {
    test('includes app-specific fields', () {
      final map = artistUser.toMap();
      expect(map['stageName'], 'DJ Art');
      expect(map['genres'], ['Hip-Hop', 'R&B']);
      expect(map['studioIds'], ['studio-1', 'studio-2']);
      expect(map['city'], 'Paris');
      expect(map['isPartner'], isFalse);
      expect(map['isDevMaster'], isFalse);
    });
  });

  group('proProfile helpers', () {
    test('hasProProfile false by default', () {
      expect(artistUser.hasProProfile, isFalse);
    });

    test('hasProProfile true when set', () {
      final user = artistUser.copyWith(
        proProfile: const ProProfile(displayName: 'DJ Art'),
      );
      expect(user.hasProProfile, isTrue);
    });

    test('isPro true when profile exists and available', () {
      final user = artistUser.copyWith(
        proProfile: const ProProfile(displayName: 'DJ Art', isAvailable: true),
      );
      expect(user.isPro, isTrue);
    });

    test('isPro false when profile exists but unavailable', () {
      final user = artistUser.copyWith(
        proProfile: const ProProfile(displayName: 'DJ Art', isAvailable: false),
      );
      expect(user.isPro, isFalse);
    });

    test('isPro false when no profile', () {
      expect(artistUser.isPro, isFalse);
    });
  });

  group('fromMap with proProfile', () {
    test('parses proProfile from map', () {
      final user = AppUser.fromMap({
        'uid': 'u-pro',
        'email': 'pro@test.com',
        'role': 'client',
        'proProfile': {
          'displayName': 'Beat King',
          'proTypes': ['producer', 'musician'],
          'hourlyRate': 60,
          'city': 'Lyon',
          'instruments': ['Piano', 'MPC'],
        },
      });
      expect(user.hasProProfile, isTrue);
      expect(user.proProfile!.displayName, 'Beat King');
      expect(user.proProfile!.proTypes, [ProType.producer, ProType.musician]);
      expect(user.proProfile!.hourlyRate, 60);
      expect(user.proProfile!.instruments, ['Piano', 'MPC']);
    });

    test('proProfile is null when not in map', () {
      final user = AppUser.fromMap({'uid': 'u', 'email': 'e'});
      expect(user.proProfile, isNull);
    });
  });

  group('toMap with proProfile', () {
    test('includes proProfile when set', () {
      final user = artistUser.copyWith(
        proProfile: const ProProfile(
          displayName: 'DJ Art',
          proTypes: [ProType.musician],
          hourlyRate: 40,
        ),
      );
      final map = user.toMap();
      expect(map['proProfile'], isNotNull);
      expect(map['proProfile']['displayName'], 'DJ Art');
      expect(map['proProfile']['proTypes'], ['musician']);
      expect(map['proProfile']['hourlyRate'], 40);
    });

    test('proProfile is null in map when not set', () {
      final map = artistUser.toMap();
      expect(map['proProfile'], isNull);
    });
  });

  group('copyWith proProfile', () {
    test('adds proProfile', () {
      final modified = artistUser.copyWith(
        proProfile: const ProProfile(
          displayName: 'Pro DJ',
          proTypes: [ProType.soundEngineer],
        ),
      );
      expect(modified.hasProProfile, isTrue);
      expect(modified.proProfile!.displayName, 'Pro DJ');
      // other fields unchanged
      expect(modified.uid, artistUser.uid);
      expect(modified.email, artistUser.email);
      expect(modified.stageName, artistUser.stageName);
    });
  });

  group('displayPhotoUrl', () {
    test('returns profilePhotoUrl when set on proProfile', () {
      final user = artistUser.copyWith(
        proProfile: const ProProfile(
          displayName: 'X',
          profilePhotoUrl: 'https://example.com/chosen.jpg',
          portfolioUrls: ['https://example.com/p1.jpg'],
        ),
      );
      expect(user.displayPhotoUrl, 'https://example.com/chosen.jpg');
    });

    test('returns photoURL when no profilePhotoUrl', () {
      const user = AppUser(
        uid: 'u',
        email: 'e',
        photoURL: 'https://example.com/account.jpg',
        proProfile: ProProfile(
          displayName: 'X',
          portfolioUrls: ['https://example.com/p1.jpg'],
        ),
      );
      expect(user.displayPhotoUrl, 'https://example.com/account.jpg');
    });

    test('returns first portfolio url when no photoURL or profilePhotoUrl', () {
      const user = AppUser(
        uid: 'u',
        email: 'e',
        proProfile: ProProfile(
          displayName: 'X',
          portfolioUrls: ['https://example.com/p1.jpg', 'https://example.com/p2.jpg'],
        ),
      );
      expect(user.displayPhotoUrl, 'https://example.com/p1.jpg');
    });

    test('returns null when no photos at all', () {
      expect(artistUser.displayPhotoUrl, isNull);
    });

    test('returns null when no proProfile and no photoURL', () {
      const user = AppUser(uid: 'u', email: 'e');
      expect(user.displayPhotoUrl, isNull);
    });
  });

  group('hasDevMasterAccess', () {
    test('true when superAdmin with isDevMaster flag', () {
      expect(superAdmin.hasDevMasterAccess, isTrue);
    });

    test('false when not superAdmin even with flag', () {
      const user = AppUser(
        uid: 'u',
        email: 'e',
        role: BaseUserRole.admin,
        isDevMaster: true,
      );
      expect(user.hasDevMasterAccess, isFalse);
    });

    test('false when superAdmin without flag', () {
      const user = AppUser(
        uid: 'u',
        email: 'e',
        role: BaseUserRole.superAdmin,
        isDevMaster: false,
      );
      expect(user.hasDevMasterAccess, isFalse);
    });
  });
}
