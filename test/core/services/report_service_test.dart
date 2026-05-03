// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uzme/core/services/report_service.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockWriteBatch extends Mock implements WriteBatch {}

void main() {
  late MockFirestore mockFirestore;
  late ReportService service;

  setUp(() {
    mockFirestore = MockFirestore();
    service = ReportService(firestore: mockFirestore);
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('ReportService', () {
    test('reportUser creates report and notifies superAdmins', () async {
      // Arrange
      final reportsCollection = MockCollectionReference();
      final usersCollection = MockCollectionReference();
      final notificationsCollection = MockCollectionReference();
      final mockDocRef = MockDocumentReference();
      final mockNotifDocRef = MockDocumentReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockAdminDoc = MockQueryDocumentSnapshot();
      final mockBatch = MockWriteBatch();

      when(() => mockFirestore.collection('reports'))
          .thenReturn(reportsCollection);
      when(() => reportsCollection.add(any()))
          .thenAnswer((_) async => mockDocRef);
      when(() => mockDocRef.id).thenReturn('report123');

      when(() => mockFirestore.collection('users'))
          .thenReturn(usersCollection);
      when(() => usersCollection.where('role', isEqualTo: 'superAdmin'))
          .thenReturn(mockQuery);
      when(() => mockQuery.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockAdminDoc]);
      when(() => mockAdminDoc.id).thenReturn('admin1');

      when(() => mockFirestore.batch()).thenReturn(mockBatch);
      when(() => mockFirestore.collection('user_notifications'))
          .thenReturn(notificationsCollection);
      when(() => notificationsCollection.doc()).thenReturn(mockNotifDocRef);
      when(() => mockBatch.set(mockNotifDocRef, any(), any()))
          .thenReturn(null);
      when(() => mockBatch.commit()).thenAnswer((_) async {});

      // Act
      await service.reportUser(
        reporterId: 'user1',
        reportedUserId: 'user2',
        conversationId: 'conv1',
        reason: 'Spam messages',
      );

      // Assert
      verify(() => reportsCollection.add(any(
            that: isA<Map<String, dynamic>>()
                .having((m) => m['reporterId'], 'reporterId', 'user1')
                .having(
                    (m) => m['reportedUserId'], 'reportedUserId', 'user2')
                .having(
                    (m) => m['conversationId'], 'conversationId', 'conv1')
                .having((m) => m['reason'], 'reason', 'Spam messages')
                .having((m) => m['status'], 'status', 'pending'),
          ))).called(1);

      verify(() => mockBatch.commit()).called(1);
    });

    test('reportUser works with empty reason', () async {
      // Arrange
      final reportsCollection = MockCollectionReference();
      final usersCollection = MockCollectionReference();
      final mockDocRef = MockDocumentReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockBatch = MockWriteBatch();

      when(() => mockFirestore.collection('reports'))
          .thenReturn(reportsCollection);
      when(() => reportsCollection.add(any()))
          .thenAnswer((_) async => mockDocRef);
      when(() => mockDocRef.id).thenReturn('report456');

      when(() => mockFirestore.collection('users'))
          .thenReturn(usersCollection);
      when(() => usersCollection.where('role', isEqualTo: 'superAdmin'))
          .thenReturn(mockQuery);
      when(() => mockQuery.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);
      when(() => mockFirestore.batch()).thenReturn(mockBatch);
      when(() => mockBatch.commit()).thenAnswer((_) async {});

      // Act
      await service.reportUser(
        reporterId: 'user1',
        reportedUserId: 'user2',
        conversationId: 'conv1',
      );

      // Assert — reason defaults to empty string
      verify(() => reportsCollection.add(any(
            that: isA<Map<String, dynamic>>()
                .having((m) => m['reason'], 'reason', ''),
          ))).called(1);
    });
  });
}
