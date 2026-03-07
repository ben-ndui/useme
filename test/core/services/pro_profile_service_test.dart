import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/core/services/pro_profile_service.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late ProProfileService service;

  setUp(() {
    service = ProProfileService(firestore: MockFirestore());
  });

  AppUser makeProUser({
    required String uid,
    required String displayName,
    List<ProType> proTypes = const [],
    List<String> specialties = const [],
    List<String> instruments = const [],
    List<String> genres = const [],
    String? city,
    bool remote = false,
    bool isAvailable = true,
    bool isVerified = false,
    double? rating,
  }) {
    return AppUser(
      uid: uid,
      email: '$uid@test.com',
      proProfile: ProProfile(
        displayName: displayName,
        proTypes: proTypes,
        specialties: specialties,
        instruments: instruments,
        genres: genres,
        city: city,
        remote: remote,
        isAvailable: isAvailable,
        isVerified: isVerified,
        rating: rating,
      ),
    );
  }

  group('filterProsByText', () {
    final pros = [
      makeProUser(
        uid: 'u1',
        displayName: 'Beat King',
        proTypes: [ProType.producer],
        specialties: ['Trap', 'Drill'],
        instruments: ['MPC'],
        genres: ['Hip-Hop'],
      ),
      makeProUser(
        uid: 'u2',
        displayName: 'Guitar Hero',
        proTypes: [ProType.musician],
        specialties: ['Jazz manouche'],
        instruments: ['Guitare', 'Basse'],
        genres: ['Jazz', 'Blues'],
      ),
      makeProUser(
        uid: 'u3',
        displayName: 'Mix Master',
        proTypes: [ProType.soundEngineer],
        specialties: ['Mix voix', 'Mastering'],
        instruments: [],
        genres: ['Pop', 'R&B'],
      ),
      makeProUser(
        uid: 'u4',
        displayName: 'Sarah Voice',
        proTypes: [ProType.vocalist],
        specialties: ['Choeurs', 'Lead'],
        instruments: [],
        genres: ['Gospel', 'Soul'],
      ),
    ];

    test('returns all when query is empty', () {
      final result = service.filterProsByText(pros, '');
      expect(result.length, 4);
    });

    test('filters by displayName', () {
      final result = service.filterProsByText(pros, 'Beat');
      expect(result.length, 1);
      expect(result.first.uid, 'u1');
    });

    test('filters by displayName case insensitive', () {
      final result = service.filterProsByText(pros, 'mix master');
      expect(result.length, 1);
      expect(result.first.uid, 'u3');
    });

    test('filters by specialty', () {
      final result = service.filterProsByText(pros, 'Trap');
      expect(result.length, 1);
      expect(result.first.uid, 'u1');
    });

    test('filters by instrument', () {
      final result = service.filterProsByText(pros, 'Guitare');
      expect(result.length, 1);
      expect(result.first.uid, 'u2');
    });

    test('filters by genre', () {
      final result = service.filterProsByText(pros, 'Jazz');
      expect(result.length, 1);
      expect(result.first.uid, 'u2');
    });

    test('filters by proType label', () {
      final result = service.filterProsByText(pros, 'Musicien');
      expect(result.length, 1);
      expect(result.first.uid, 'u2');
    });

    test('filters by partial match', () {
      final result = service.filterProsByText(pros, 'Master');
      expect(result.length, 1); // Mix Master (displayName + Mastering specialty = same user)
      expect(result.first.uid, 'u3');
    });

    test('returns empty when no match', () {
      final result = service.filterProsByText(pros, 'ClassicalPiano');
      expect(result, isEmpty);
    });

    test('excludes users without proProfile', () {
      final mixedList = [
        ...pros,
        const AppUser(uid: 'no-pro', email: 'no@test.com', name: 'No Pro'),
      ];
      final result = service.filterProsByText(mixedList, 'No Pro');
      expect(result, isEmpty);
    });

    test('matches across multiple fields', () {
      // 'Soul' matches genre in u4
      final result = service.filterProsByText(pros, 'Soul');
      expect(result.length, 1);
      expect(result.first.uid, 'u4');
    });
  });

  group('filterProsByText edge cases', () {
    test('handles empty pros list', () {
      final result = service.filterProsByText([], 'test');
      expect(result, isEmpty);
    });

    test('handles special characters in query', () {
      final pros = [
        makeProUser(uid: 'u1', displayName: 'R&B Master'),
      ];
      final result = service.filterProsByText(pros, 'R&B');
      expect(result.length, 1);
    });
  });
}
