import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/session.dart';

import '../../helpers/test_factories.dart';

void main() {
  group('Session.displayStatus', () {
    test('confirmed future session => confirmed', () {
      final session = SessionFactory.future(status: SessionStatus.confirmed);
      expect(session.displayStatus, SessionStatus.confirmed);
    });

    test('confirmed session currently happening => inProgress', () {
      final session = SessionFactory.happening(status: SessionStatus.confirmed);
      expect(session.displayStatus, SessionStatus.inProgress);
    });

    test('confirmed past session => completed', () {
      final session = SessionFactory.past(status: SessionStatus.confirmed);
      expect(session.displayStatus, SessionStatus.completed);
    });

    test('pending past session => completed', () {
      final session = SessionFactory.past(status: SessionStatus.pending);
      expect(session.displayStatus, SessionStatus.completed);
    });

    test('pending future session => pending', () {
      final session = SessionFactory.future(status: SessionStatus.pending);
      expect(session.displayStatus, SessionStatus.pending);
    });

    test('completed session stays completed regardless of time', () {
      final session = SessionFactory.future(status: SessionStatus.completed);
      expect(session.displayStatus, SessionStatus.completed);
    });

    test('cancelled session stays cancelled regardless of time', () {
      final session = SessionFactory.future(status: SessionStatus.cancelled);
      expect(session.displayStatus, SessionStatus.cancelled);
    });

    test('noShow session stays noShow regardless of time', () {
      final session = SessionFactory.future(status: SessionStatus.noShow);
      expect(session.displayStatus, SessionStatus.noShow);
    });

    test('cancelled past session stays cancelled', () {
      final session = SessionFactory.past(status: SessionStatus.cancelled);
      expect(session.displayStatus, SessionStatus.cancelled);
    });

    test('inProgress status on future session => inProgress', () {
      final session = SessionFactory.future(status: SessionStatus.inProgress);
      expect(session.displayStatus, SessionStatus.inProgress);
    });
  });

  group('Session.canBeCancelled', () {
    test('confirmed future session => can be cancelled', () {
      final session = SessionFactory.future(status: SessionStatus.confirmed);
      expect(session.canBeCancelled, isTrue);
    });

    test('pending future session => can be cancelled', () {
      final session = SessionFactory.future(status: SessionStatus.pending);
      expect(session.canBeCancelled, isTrue);
    });

    test('confirmed session currently happening => cannot cancel', () {
      final session = SessionFactory.happening(status: SessionStatus.confirmed);
      expect(session.canBeCancelled, isFalse);
    });

    test('confirmed past session => cannot cancel', () {
      final session = SessionFactory.past(status: SessionStatus.confirmed);
      expect(session.canBeCancelled, isFalse);
    });

    test('completed session => cannot cancel', () {
      final session = SessionFactory.future(status: SessionStatus.completed);
      expect(session.canBeCancelled, isFalse);
    });

    test('cancelled session => cannot cancel again', () {
      final session = SessionFactory.future(status: SessionStatus.cancelled);
      expect(session.canBeCancelled, isFalse);
    });

    test('noShow session => cannot cancel', () {
      final session = SessionFactory.future(status: SessionStatus.noShow);
      expect(session.canBeCancelled, isFalse);
    });

    test('pending past session => cannot cancel', () {
      final session = SessionFactory.past(status: SessionStatus.pending);
      expect(session.canBeCancelled, isFalse);
    });
  });

  group('Session.isPast & isCurrentlyHappening', () {
    test('future session is not past', () {
      final session = SessionFactory.future();
      expect(session.isPast, isFalse);
      expect(session.isCurrentlyHappening, isFalse);
    });

    test('past session is past', () {
      final session = SessionFactory.past();
      expect(session.isPast, isTrue);
      expect(session.isCurrentlyHappening, isFalse);
    });

    test('happening session is currently happening', () {
      final session = SessionFactory.happening();
      expect(session.isCurrentlyHappening, isTrue);
      expect(session.isPast, isFalse);
    });
  });

  group('Session helper getters', () {
    test('hasEngineer with single engineerId', () {
      final session = SessionFactory.future(engineerId: 'eng-1');
      expect(session.hasEngineer, isTrue);
    });

    test('hasEngineer with engineerIds list', () {
      final session = SessionFactory.future(
        engineerIds: ['eng-1', 'eng-2'],
      );
      expect(session.hasEngineer, isTrue);
    });

    test('hasEngineer false when no engineer', () {
      final session = SessionFactory.future();
      expect(session.hasEngineer, isFalse);
    });

    test('hasPendingProposals', () {
      final session = SessionFactory.create(
        scheduledStart: DateTime.now().add(const Duration(days: 1)),
        scheduledEnd: DateTime.now().add(const Duration(days: 1, hours: 2)),
        proposedEngineerIds: ['eng-1'],
      );
      expect(session.hasPendingProposals, isTrue);
    });

    test('hasMultipleEngineers', () {
      final session = SessionFactory.future(
        engineerIds: ['eng-1', 'eng-2'],
      );
      expect(session.hasMultipleEngineers, isTrue);
    });

    test('engineerCount with engineerIds', () {
      final session = SessionFactory.future(
        engineerIds: ['eng-1', 'eng-2', 'eng-3'],
      );
      expect(session.engineerCount, 3);
    });

    test('engineerCount with single engineerId', () {
      final session = SessionFactory.future(engineerId: 'eng-1');
      expect(session.engineerCount, 1);
    });

    test('engineerCount zero', () {
      final session = SessionFactory.future();
      expect(session.engineerCount, 0);
    });

    test('durationHours', () {
      final session = SessionFactory.future();
      expect(session.durationHours, 2.0);
    });
  });

  group('Session.artistName display', () {
    test('single artist shows name', () {
      final session = SessionFactory.create(
        artistNames: ['Alice'],
        scheduledStart: DateTime.now(),
        scheduledEnd: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(session.artistName, 'Alice');
    });

    test('two artists joined with &', () {
      final session = SessionFactory.create(
        artistIds: ['a1', 'a2'],
        artistNames: ['Alice', 'Bob'],
        scheduledStart: DateTime.now(),
        scheduledEnd: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(session.artistName, 'Alice & Bob');
    });

    test('three artists with comma and &', () {
      final session = SessionFactory.create(
        artistIds: ['a1', 'a2', 'a3'],
        artistNames: ['Alice', 'Bob', 'Charlie'],
        scheduledStart: DateTime.now(),
        scheduledEnd: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(session.artistName, 'Alice, Bob & Charlie');
    });

    test('no artists shows fallback', () {
      final session = SessionFactory.create(
        artistIds: [],
        artistNames: [],
        scheduledStart: DateTime.now(),
        scheduledEnd: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(session.artistName, 'Artiste inconnu');
    });
  });

  group('Session.typeLabel', () {
    test('single type', () {
      final session = SessionFactory.future(
        types: [SessionType.recording],
      );
      expect(session.typeLabel, 'Enregistrement');
    });

    test('multiple types sorted by order', () {
      final session = SessionFactory.future(
        types: [SessionType.mastering, SessionType.recording],
      );
      expect(session.typeLabel, 'Enregistrement + Mastering');
    });

    test('default type when none provided', () {
      final session = SessionFactory.future(types: null);
      expect(session.typeLabel, 'Autre');
    });
  });

  group('Session.fromMap / toMap', () {
    test('round-trip serialization', () {
      final session = SessionFactory.future(
        types: [SessionType.recording, SessionType.mixing],
      );
      final map = session.toMap();
      final restored = Session.fromMap(map);

      expect(restored.id, session.id);
      expect(restored.studioId, session.studioId);
      expect(restored.status, session.status);
      expect(restored.types.length, session.types.length);
      expect(restored.artistIds, session.artistIds);
      expect(restored.durationMinutes, session.durationMinutes);
    });

    test('fromMap with old single artistId format', () {
      final map = {
        'id': 'old-session',
        'studioId': 'studio-1',
        'artistId': 'artist-old',
        'artistName': 'Old Artist',
        'status': 'confirmed',
        'type': 'recording',
        'scheduledStart': DateTime.now().millisecondsSinceEpoch,
        'scheduledEnd':
            DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
        'durationMinutes': 60,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };
      final session = Session.fromMap(map);
      expect(session.artistIds, ['artist-old']);
      expect(session.artistNames, ['Old Artist']);
    });

    test('fromMap with old single type format', () {
      final map = {
        'id': 'old-session',
        'studioId': 'studio-1',
        'status': 'pending',
        'type': 'mastering',
        'scheduledStart': DateTime.now().millisecondsSinceEpoch,
        'scheduledEnd':
            DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
        'durationMinutes': 60,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };
      final session = Session.fromMap(map);
      expect(session.types, [SessionType.mastering]);
    });

    test('fromMap with no artists', () {
      final map = {
        'id': 'no-artist',
        'studioId': 'studio-1',
        'status': 'pending',
        'scheduledStart': DateTime.now().millisecondsSinceEpoch,
        'scheduledEnd':
            DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
        'durationMinutes': 60,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };
      final session = Session.fromMap(map);
      expect(session.artistIds, isEmpty);
      expect(session.artistNames, isEmpty);
    });
  });

  group('Session.isOnDate', () {
    test('session is on its scheduled date', () {
      final date = DateTime(2026, 3, 10);
      final session = SessionFactory.create(
        scheduledStart: DateTime(2026, 3, 10, 14, 0),
        scheduledEnd: DateTime(2026, 3, 10, 16, 0),
      );
      expect(session.isOnDate(date), isTrue);
    });

    test('session is not on a different date', () {
      final session = SessionFactory.create(
        scheduledStart: DateTime(2026, 3, 10, 14, 0),
        scheduledEnd: DateTime(2026, 3, 10, 16, 0),
      );
      expect(session.isOnDate(DateTime(2026, 3, 11)), isFalse);
    });
  });

  group('Session.isEngineerAssigned / isEngineerProposed', () {
    test('engineer assigned via single engineerId', () {
      final session = SessionFactory.future(engineerId: 'eng-1');
      expect(session.isEngineerAssigned('eng-1'), isTrue);
      expect(session.isEngineerAssigned('eng-2'), isFalse);
    });

    test('engineer assigned via engineerIds list', () {
      final session = SessionFactory.future(
        engineerIds: ['eng-1', 'eng-2'],
      );
      expect(session.isEngineerAssigned('eng-1'), isTrue);
      expect(session.isEngineerAssigned('eng-2'), isTrue);
      expect(session.isEngineerAssigned('eng-3'), isFalse);
    });

    test('engineer proposed', () {
      final session = SessionFactory.create(
        scheduledStart: DateTime.now().add(const Duration(days: 1)),
        scheduledEnd: DateTime.now().add(const Duration(days: 1, hours: 2)),
        proposedEngineerIds: ['eng-1'],
      );
      expect(session.isEngineerProposed('eng-1'), isTrue);
      expect(session.isEngineerProposed('eng-2'), isFalse);
    });
  });

  group('SessionType', () {
    test('fromString parses known types', () {
      expect(SessionTypeExtension.fromString('recording'), SessionType.recording);
      expect(SessionTypeExtension.fromString('mix'), SessionType.mix);
      expect(SessionTypeExtension.fromString('mastering'), SessionType.mastering);
      expect(SessionTypeExtension.fromString('mixing'), SessionType.mixing);
      expect(SessionTypeExtension.fromString('editing'), SessionType.editing);
    });

    test('fromString defaults to other for unknown', () {
      expect(SessionTypeExtension.fromString('unknown'), SessionType.other);
      expect(SessionTypeExtension.fromString(null), SessionType.other);
    });

    test('listFromStrings sorts by sortOrder', () {
      final types =
          SessionTypeExtension.listFromStrings(['mastering', 'recording']);
      expect(types, [SessionType.recording, SessionType.mastering]);
    });

    test('listFromStrings empty/null', () {
      expect(SessionTypeExtension.listFromStrings(null), isEmpty);
      expect(SessionTypeExtension.listFromStrings([]), isEmpty);
    });

    test('combinedLabel joins with +', () {
      final label = SessionTypeExtension.combinedLabel(
        [SessionType.recording, SessionType.mastering],
      );
      expect(label, 'Enregistrement + Mastering');
    });

    test('combinedLabel empty returns Autre', () {
      expect(SessionTypeExtension.combinedLabel([]), 'Autre');
    });
  });

  group('SessionStatus', () {
    test('fromString parses known statuses', () {
      expect(SessionStatusExtension.fromString('confirmed'), SessionStatus.confirmed);
      expect(SessionStatusExtension.fromString('inProgress'), SessionStatus.inProgress);
      expect(SessionStatusExtension.fromString('completed'), SessionStatus.completed);
      expect(SessionStatusExtension.fromString('cancelled'), SessionStatus.cancelled);
      expect(SessionStatusExtension.fromString('noShow'), SessionStatus.noShow);
    });

    test('fromString defaults to pending', () {
      expect(SessionStatusExtension.fromString('unknown'), SessionStatus.pending);
      expect(SessionStatusExtension.fromString(null), SessionStatus.pending);
    });
  });

  group('SessionIntervention', () {
    test('default values', () {
      const intervention = SessionIntervention();
      expect(intervention.hasCheckedIn, isFalse);
      expect(intervention.hasCheckedOut, isFalse);
      expect(intervention.photos, isEmpty);
      expect(intervention.notes, isNull);
    });

    test('round-trip serialization', () {
      final intervention = SessionIntervention(
        checkinTime: DateTime(2026, 3, 10, 14, 0),
        checkoutTime: DateTime(2026, 3, 10, 16, 0),
        photos: ['photo1.jpg'],
        notes: 'Good session',
      );
      final map = intervention.toMap();
      final restored = SessionIntervention.fromMap(map);
      expect(restored.hasCheckedIn, isTrue);
      expect(restored.hasCheckedOut, isTrue);
      expect(restored.photos, ['photo1.jpg']);
      expect(restored.notes, 'Good session');
    });

    test('fromMap with null returns defaults', () {
      final intervention = SessionIntervention.fromMap(null);
      expect(intervention.hasCheckedIn, isFalse);
    });

    test('copyWith', () {
      const original = SessionIntervention();
      final updated = original.copyWith(
        checkinTime: DateTime(2026, 3, 10),
      );
      expect(updated.hasCheckedIn, isTrue);
      expect(updated.hasCheckedOut, isFalse);
    });
  });
}
