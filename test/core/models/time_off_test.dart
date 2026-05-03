import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/time_off.dart';

void main() {
  final baseTimeOff = TimeOff(
    id: 'to-1',
    engineerId: 'eng-1',
    start: DateTime(2026, 3, 10, 9, 0),
    end: DateTime(2026, 3, 12, 18, 0),
    reason: 'Vacances',
    createdAt: DateTime(2026, 3, 1),
  );

  group('overlapsWith', () {
    test('returns true when period overlaps start', () {
      expect(
        baseTimeOff.overlapsWith(
          DateTime(2026, 3, 9, 12, 0),
          DateTime(2026, 3, 10, 12, 0),
        ),
        isTrue,
      );
    });

    test('returns true when period overlaps end', () {
      expect(
        baseTimeOff.overlapsWith(
          DateTime(2026, 3, 12, 12, 0),
          DateTime(2026, 3, 13, 12, 0),
        ),
        isTrue,
      );
    });

    test('returns true when period is inside', () {
      expect(
        baseTimeOff.overlapsWith(
          DateTime(2026, 3, 11, 0, 0),
          DateTime(2026, 3, 11, 23, 0),
        ),
        isTrue,
      );
    });

    test('returns true when period contains time-off', () {
      expect(
        baseTimeOff.overlapsWith(
          DateTime(2026, 3, 8),
          DateTime(2026, 3, 15),
        ),
        isTrue,
      );
    });

    test('returns false when period is before', () {
      expect(
        baseTimeOff.overlapsWith(
          DateTime(2026, 3, 8),
          DateTime(2026, 3, 9),
        ),
        isFalse,
      );
    });

    test('returns false when period is after', () {
      expect(
        baseTimeOff.overlapsWith(
          DateTime(2026, 3, 13),
          DateTime(2026, 3, 14),
        ),
        isFalse,
      );
    });

    test('returns false when period ends exactly at start', () {
      expect(
        baseTimeOff.overlapsWith(
          DateTime(2026, 3, 9),
          DateTime(2026, 3, 10, 9, 0),
        ),
        isFalse,
      );
    });
  });

  group('containsDate', () {
    test('returns true for date inside range', () {
      expect(baseTimeOff.containsDate(DateTime(2026, 3, 11)), isTrue);
    });

    test('returns true for start date', () {
      expect(baseTimeOff.containsDate(DateTime(2026, 3, 10)), isTrue);
    });

    test('returns true for end date', () {
      expect(baseTimeOff.containsDate(DateTime(2026, 3, 12)), isTrue);
    });

    test('returns false for date before', () {
      expect(baseTimeOff.containsDate(DateTime(2026, 3, 9)), isFalse);
    });

    test('returns false for date after', () {
      expect(baseTimeOff.containsDate(DateTime(2026, 3, 13)), isFalse);
    });
  });

  group('durationDays', () {
    test('calculates inclusive days', () {
      // March 10 to March 12 = 3 days inclusive
      expect(baseTimeOff.durationDays, 3);
    });

    test('single day is 1', () {
      final singleDay = baseTimeOff.copyWith(
        start: DateTime(2026, 3, 10),
        end: DateTime(2026, 3, 10, 23, 59),
      );
      expect(singleDay.durationDays, 1);
    });
  });

  group('copyWith', () {
    test('creates modified copy', () {
      final modified = baseTimeOff.copyWith(
        reason: 'Maladie',
        engineerId: 'eng-2',
      );
      expect(modified.reason, 'Maladie');
      expect(modified.engineerId, 'eng-2');
      expect(modified.id, 'to-1'); // unchanged
      expect(modified.start, baseTimeOff.start); // unchanged
    });
  });

  group('commonReasons', () {
    test('contains expected reasons', () {
      expect(TimeOff.commonReasons, contains('Vacances'));
      expect(TimeOff.commonReasons, contains('Maladie'));
      expect(TimeOff.commonReasons.length, greaterThanOrEqualTo(5));
    });
  });

  group('equality', () {
    test('same values are equal', () {
      final a = baseTimeOff;
      final b = baseTimeOff.copyWith();
      expect(a, equals(b));
    });

    test('different values are not equal', () {
      final b = baseTimeOff.copyWith(id: 'to-2');
      expect(baseTimeOff, isNot(equals(b)));
    });
  });
}
