import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/studio_claim.dart';
import 'package:uzme/core/models/studio_profile.dart';

void main() {
  final now = DateTime.now();
  final nowMs = now.millisecondsSinceEpoch;

  final testClaim = StudioClaim(
    id: 'claim-1',
    userId: 'user-1',
    userEmail: 'test@test.com',
    userName: 'Test User',
    studioProfile: const StudioProfile(name: 'My Studio'),
    status: ClaimStatus.pending,
    createdAt: now,
  );

  group('status helpers', () {
    test('isPending', () {
      expect(testClaim.isPending, isTrue);
      expect(testClaim.isApproved, isFalse);
      expect(testClaim.isRejected, isFalse);
    });

    test('isApproved', () {
      final approved = StudioClaim(
        id: 'c',
        userId: 'u',
        userEmail: 'e',
        userName: 'n',
        studioProfile: const StudioProfile(name: 'S'),
        status: ClaimStatus.approved,
        createdAt: now,
      );
      expect(approved.isApproved, isTrue);
      expect(approved.isPending, isFalse);
    });

    test('isRejected', () {
      final rejected = StudioClaim(
        id: 'c',
        userId: 'u',
        userEmail: 'e',
        userName: 'n',
        studioProfile: const StudioProfile(name: 'S'),
        status: ClaimStatus.rejected,
        createdAt: now,
        rejectionReason: 'Not verified',
      );
      expect(rejected.isRejected, isTrue);
      expect(rejected.rejectionReason, 'Not verified');
    });
  });

  group('fromMap', () {
    test('parses all fields with int timestamps', () {
      final claim = StudioClaim.fromMap({
        'userId': 'user-1',
        'userEmail': 'test@test.com',
        'userName': 'Test',
        'studioProfile': {'name': 'Studio A'},
        'status': 'approved',
        'createdAt': nowMs,
        'reviewedAt': nowMs,
        'reviewedBy': 'admin-1',
        'rejectionReason': null,
      }, 'doc-id');

      expect(claim.id, 'doc-id');
      expect(claim.userId, 'user-1');
      expect(claim.status, ClaimStatus.approved);
      expect(claim.studioProfile.name, 'Studio A');
      expect(claim.reviewedBy, 'admin-1');
    });

    test('uses docId over map id', () {
      final claim = StudioClaim.fromMap({
        'id': 'map-id',
      }, 'doc-id');
      expect(claim.id, 'doc-id');
    });

    test('handles missing fields', () {
      final claim = StudioClaim.fromMap({});
      expect(claim.id, '');
      expect(claim.userId, '');
      expect(claim.userEmail, '');
      expect(claim.status, ClaimStatus.pending);
      expect(claim.studioProfile.name, '');
    });

    test('parses unknown status as pending', () {
      final claim = StudioClaim.fromMap({'status': 'unknown'});
      expect(claim.status, ClaimStatus.pending);
    });
  });

  group('toMap', () {
    test('includes all fields', () {
      final map = testClaim.toMap();
      expect(map['id'], 'claim-1');
      expect(map['userId'], 'user-1');
      expect(map['userEmail'], 'test@test.com');
      expect(map['userName'], 'Test User');
      expect(map['status'], 'pending');
      expect(map['createdAt'], isA<int>());
      expect(map['studioProfile'], isA<Map>());
      expect(map['reviewedAt'], isNull);
      expect(map['rejectionReason'], isNull);
    });
  });

  group('toMap/fromMap round-trip', () {
    test('preserves data through serialization', () {
      final map = testClaim.toMap();
      final restored = StudioClaim.fromMap(map);
      expect(restored.id, testClaim.id);
      expect(restored.userId, testClaim.userId);
      expect(restored.status, testClaim.status);
      expect(restored.studioProfile.name, 'My Studio');
    });
  });
}
