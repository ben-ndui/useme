// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uzme/core/services/block_service.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirestore mockFirestore;
  late BlockService service;
  late MockCollectionReference usersCollection;
  late MockDocumentReference userDocRef;

  setUp(() {
    mockFirestore = MockFirestore();
    service = BlockService(firestore: mockFirestore);
    usersCollection = MockCollectionReference();
    userDocRef = MockDocumentReference();

    when(() => mockFirestore.collection('users'))
        .thenReturn(usersCollection);
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('BlockService', () {
    test('blockUser updates user document with blockedUsers field', () async {
      when(() => usersCollection.doc('user1')).thenReturn(userDocRef);
      when(() => userDocRef.update(any())).thenAnswer((_) async {});

      await service.blockUser('user1', 'user2');

      final captured =
          verify(() => userDocRef.update(captureAny())).captured;
      expect(captured.length, 1);
      final updateMap = Map<String, dynamic>.from(captured.first as Map);
      expect(updateMap.containsKey('blockedUsers.user2'), true);
      expect(updateMap['blockedUsers.user2'], isA<Timestamp>());
    });

    test('unblockUser removes user from blockedUsers map', () async {
      when(() => usersCollection.doc('user1')).thenReturn(userDocRef);
      when(() => userDocRef.update(any())).thenAnswer((_) async {});

      await service.unblockUser('user1', 'user2');

      final captured =
          verify(() => userDocRef.update(captureAny())).captured;
      expect(captured.length, 1);
      final updateMap = Map<String, dynamic>.from(captured.first as Map);
      expect(updateMap.containsKey('blockedUsers.user2'), true);
    });

    test('getBlockedUserIds returns list of blocked user IDs', () async {
      final mockSnapshot = MockDocumentSnapshot();
      when(() => usersCollection.doc('user1')).thenReturn(userDocRef);
      when(() => userDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.data()).thenReturn({
        'name': 'Test',
        'blockedUsers': {
          'blocked1': Timestamp.now(),
          'blocked2': Timestamp.now(),
        },
      });

      final result = await service.getBlockedUserIds('user1');

      expect(result, containsAll(['blocked1', 'blocked2']));
      expect(result.length, 2);
    });

    test('getBlockedUserIds returns empty list when no blockedUsers', () async {
      final mockSnapshot = MockDocumentSnapshot();
      when(() => usersCollection.doc('user1')).thenReturn(userDocRef);
      when(() => userDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.data()).thenReturn({'name': 'Test'});

      final result = await service.getBlockedUserIds('user1');

      expect(result, isEmpty);
    });

    test('getBlockedUserIds returns empty list when doc is null', () async {
      final mockSnapshot = MockDocumentSnapshot();
      when(() => usersCollection.doc('user1')).thenReturn(userDocRef);
      when(() => userDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.data()).thenReturn(null);

      final result = await service.getBlockedUserIds('user1');

      expect(result, isEmpty);
    });

    test('isBlocked returns true when user is blocked', () async {
      final mockSnapshot = MockDocumentSnapshot();
      when(() => usersCollection.doc('user1')).thenReturn(userDocRef);
      when(() => userDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.data()).thenReturn({
        'blockedUsers': {'user2': Timestamp.now()},
      });

      final result = await service.isBlocked('user1', 'user2');

      expect(result, true);
    });

    test('isBlocked returns false when user is not blocked', () async {
      final mockSnapshot = MockDocumentSnapshot();
      when(() => usersCollection.doc('user1')).thenReturn(userDocRef);
      when(() => userDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.data()).thenReturn({
        'blockedUsers': {'user3': Timestamp.now()},
      });

      final result = await service.isBlocked('user1', 'user2');

      expect(result, false);
    });
  });
}
