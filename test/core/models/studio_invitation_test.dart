import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/models/studio_invitation.dart';

void main() {
  final now = DateTime.now();
  final futureDate = now.add(const Duration(days: 30));
  final pastDate = now.subtract(const Duration(days: 1));

  final testInvitation = StudioInvitation(
    id: 'inv-1',
    studioId: 'studio-1',
    studioName: 'Cool Studio',
    email: 'artist@test.com',
    phone: '+33612345678',
    code: 'USEME-ABC123',
    status: InvitationStatus.pending,
    createdAt: now,
    expiresAt: futureDate,
  );

  group('InvitationStatus', () {
    test('fromString parses valid statuses', () {
      expect(InvitationStatus.fromString('pending'), InvitationStatus.pending);
      expect(
          InvitationStatus.fromString('accepted'), InvitationStatus.accepted);
      expect(InvitationStatus.fromString('expired'), InvitationStatus.expired);
      expect(InvitationStatus.fromString('cancelled'),
          InvitationStatus.cancelled);
    });

    test('fromString defaults to pending', () {
      expect(InvitationStatus.fromString(null), InvitationStatus.pending);
      expect(InvitationStatus.fromString('unknown'), InvitationStatus.pending);
    });
  });

  group('generateCode', () {
    test('starts with USEME-', () {
      final code = StudioInvitation.generateCode();
      expect(code, startsWith('USEME-'));
    });

    test('has correct length (USEME- + 6 chars)', () {
      final code = StudioInvitation.generateCode();
      expect(code.length, 12); // "USEME-" (6) + 6 chars
    });

    test('generates unique codes', () {
      final codes = List.generate(10, (_) => StudioInvitation.generateCode());
      expect(codes.toSet().length, codes.length);
    });
  });

  group('isExpired', () {
    test('false when expiresAt in future', () {
      expect(testInvitation.isExpired, isFalse);
    });

    test('true when expiresAt in past', () {
      final expired = testInvitation.copyWith(expiresAt: pastDate);
      expect(expired.isExpired, isTrue);
    });
  });

  group('isValid', () {
    test('true when pending and not expired', () {
      expect(testInvitation.isValid, isTrue);
    });

    test('false when expired', () {
      final expired = testInvitation.copyWith(expiresAt: pastDate);
      expect(expired.isValid, isFalse);
    });

    test('false when accepted', () {
      final accepted =
          testInvitation.copyWith(status: InvitationStatus.accepted);
      expect(accepted.isValid, isFalse);
    });

    test('false when cancelled', () {
      final cancelled =
          testInvitation.copyWith(status: InvitationStatus.cancelled);
      expect(cancelled.isValid, isFalse);
    });
  });

  group('fromMap / toMap', () {
    test('round-trip preserves data', () {
      final map = testInvitation.toMap();
      final restored = StudioInvitation.fromMap(map);
      expect(restored.id, 'inv-1');
      expect(restored.studioId, 'studio-1');
      expect(restored.studioName, 'Cool Studio');
      expect(restored.email, 'artist@test.com');
      expect(restored.phone, '+33612345678');
      expect(restored.code, 'USEME-ABC123');
      expect(restored.status, InvitationStatus.pending);
    });

    test('fromMap handles missing fields', () {
      final inv = StudioInvitation.fromMap({});
      expect(inv.id, '');
      expect(inv.studioId, '');
      expect(inv.email, '');
      expect(inv.code, '');
      expect(inv.status, InvitationStatus.pending);
    });

    test('toMap uses millisecondsSinceEpoch', () {
      final map = testInvitation.toMap();
      expect(map['createdAt'], isA<int>());
      expect(map['expiresAt'], isA<int>());
      expect(map['acceptedAt'], isNull);
    });
  });

  group('copyWith', () {
    test('modifies specified fields', () {
      final modified = testInvitation.copyWith(
        status: InvitationStatus.accepted,
        acceptedByUserId: 'user-5',
        acceptedAt: now,
      );
      expect(modified.status, InvitationStatus.accepted);
      expect(modified.acceptedByUserId, 'user-5');
      expect(modified.acceptedAt, now);
      expect(modified.id, 'inv-1'); // unchanged
      expect(modified.email, 'artist@test.com'); // unchanged
    });
  });

  group('equality', () {
    test('same id are equal', () {
      final other = testInvitation.copyWith(email: 'other@test.com');
      expect(testInvitation, equals(other));
    });

    test('different id are not equal', () {
      final other = testInvitation.copyWith(id: 'inv-2');
      expect(testInvitation, isNot(equals(other)));
    });
  });
}
