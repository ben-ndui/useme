import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/booking.dart';

import '../../helpers/test_factories.dart';

void main() {
  group('Booking status getters', () {
    test('draft booking', () {
      final booking = BookingFactory.create(status: BookingStatus.draft);
      expect(booking.isDraft, isTrue);
      expect(booking.isConfirmed, isFalse);
      expect(booking.isCompleted, isFalse);
      expect(booking.isCancelled, isFalse);
    });

    test('confirmed booking', () {
      final booking = BookingFactory.create(
        status: BookingStatus.confirmed,
        confirmedAt: DateTime.now(),
      );
      expect(booking.isDraft, isFalse);
      expect(booking.isConfirmed, isTrue);
    });

    test('completed booking', () {
      final booking = BookingFactory.create(
        status: BookingStatus.completed,
        completedAt: DateTime.now(),
      );
      expect(booking.isCompleted, isTrue);
    });

    test('cancelled booking', () {
      final booking = BookingFactory.create(
        status: BookingStatus.cancelled,
        cancelledAt: DateTime.now(),
        cancellationReason: 'Artist unavailable',
      );
      expect(booking.isCancelled, isTrue);
      expect(booking.cancellationReason, 'Artist unavailable');
    });
  });

  group('Booking.hasSession', () {
    test('with sessionId', () {
      final booking = BookingFactory.create(sessionId: 'session-1');
      expect(booking.hasSession, isTrue);
    });

    test('without sessionId', () {
      final booking = BookingFactory.create();
      expect(booking.hasSession, isFalse);
    });
  });

  group('Booking.getFormattedAmount', () {
    test('formats with 2 decimals and euro sign', () {
      final booking = BookingFactory.create(totalAmount: 150.0);
      expect(booking.getFormattedAmount(), '150.00 \u20AC');
    });

    test('formats zero amount', () {
      final booking = BookingFactory.create(totalAmount: 0.0);
      expect(booking.getFormattedAmount(), '0.00 \u20AC');
    });

    test('formats decimal amount', () {
      final booking = BookingFactory.create(totalAmount: 99.99);
      expect(booking.getFormattedAmount(), '99.99 \u20AC');
    });
  });

  group('Booking.fromMap / toMap', () {
    test('round-trip serialization', () {
      final booking = BookingFactory.create(
        id: 'b-1',
        studioId: 'studio-1',
        artistId: 'artist-1',
        artistName: 'Alice',
        sessionId: 'session-1',
        status: BookingStatus.confirmed,
        totalAmount: 200.0,
        confirmedAt: DateTime(2026, 3, 10),
        notes: 'Test notes',
      );
      final map = booking.toMap();
      final restored = Booking.fromMap(map);

      expect(restored.id, 'b-1');
      expect(restored.studioId, 'studio-1');
      expect(restored.artistId, 'artist-1');
      expect(restored.artistName, 'Alice');
      expect(restored.sessionId, 'session-1');
      expect(restored.status, BookingStatus.confirmed);
      expect(restored.totalAmount, 200.0);
      expect(restored.notes, 'Test notes');
    });

    test('fromMap defaults to draft for unknown status', () {
      final map = {
        'id': 'b-1',
        'studioId': 'studio-1',
        'artistId': 'artist-1',
        'artistName': 'Alice',
        'status': 'unknown',
        'totalAmount': 100,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };
      final booking = Booking.fromMap(map);
      expect(booking.status, BookingStatus.draft);
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'id': 'b-1',
        'studioId': 'studio-1',
        'artistId': 'artist-1',
        'artistName': 'Alice',
        'totalAmount': 50,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };
      final booking = Booking.fromMap(map);
      expect(booking.sessionId, isNull);
      expect(booking.confirmedAt, isNull);
      expect(booking.completedAt, isNull);
      expect(booking.cancelledAt, isNull);
      expect(booking.notes, isNull);
      expect(booking.cancellationReason, isNull);
    });
  });

  group('Booking.copyWith', () {
    test('updates status', () {
      final booking = BookingFactory.create(status: BookingStatus.draft);
      final confirmed = booking.copyWith(
        status: BookingStatus.confirmed,
        confirmedAt: DateTime(2026, 3, 10),
      );
      expect(confirmed.isConfirmed, isTrue);
      expect(confirmed.confirmedAt, isNotNull);
      expect(confirmed.id, booking.id);
    });

    test('cancel with reason', () {
      final booking = BookingFactory.create(status: BookingStatus.confirmed);
      final cancelled = booking.copyWith(
        status: BookingStatus.cancelled,
        cancelledAt: DateTime(2026, 3, 10),
        cancellationReason: 'Changed plans',
      );
      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.cancellationReason, 'Changed plans');
    });
  });

  group('BookingStatus', () {
    test('fromString parses known statuses', () {
      expect(BookingStatusExtension.fromString('confirmed'), BookingStatus.confirmed);
      expect(BookingStatusExtension.fromString('completed'), BookingStatus.completed);
      expect(BookingStatusExtension.fromString('cancelled'), BookingStatus.cancelled);
    });

    test('fromString defaults to draft', () {
      expect(BookingStatusExtension.fromString('unknown'), BookingStatus.draft);
      expect(BookingStatusExtension.fromString(null), BookingStatus.draft);
    });

    test('labels are in French', () {
      expect(BookingStatus.draft.label, 'Brouillon');
      expect(BookingStatus.confirmed.label, 'Confirmée');
      expect(BookingStatus.completed.label, 'Terminée');
      expect(BookingStatus.cancelled.label, 'Annulée');
    });
  });
}
