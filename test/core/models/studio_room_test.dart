import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/studio_room.dart';

void main() {
  final now = DateTime(2026, 3, 9);

  final testRoom = StudioRoom(
    id: 'room-1',
    studioId: 'studio-1',
    name: 'Studio A',
    description: 'Main recording room',
    hourlyRate: 80.0,
    requiresEngineer: true,
    photoUrls: const ['url1', 'url2'],
    equipmentList: const ['Neumann U87', 'SSL Console'],
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );

  group('accessTypeLabel', () {
    test('returns "Avec ingénieur" when requiresEngineer', () {
      expect(testRoom.accessTypeLabel, 'Avec ingénieur');
    });

    test('returns "Libre accès" when self-service', () {
      final selfService = testRoom.copyWith(requiresEngineer: false);
      expect(selfService.accessTypeLabel, 'Libre accès');
    });
  });

  group('copyWith', () {
    test('creates modified copy', () {
      final modified = testRoom.copyWith(
        name: 'Studio B',
        hourlyRate: 100.0,
        isActive: false,
      );
      expect(modified.name, 'Studio B');
      expect(modified.hourlyRate, 100.0);
      expect(modified.isActive, isFalse);
      expect(modified.id, 'room-1'); // unchanged
      expect(modified.studioId, 'studio-1'); // unchanged
      expect(modified.equipmentList, ['Neumann U87', 'SSL Console']);
    });

    test('preserves all fields when no changes', () {
      final copy = testRoom.copyWith();
      expect(copy.id, testRoom.id);
      expect(copy.name, testRoom.name);
      expect(copy.description, testRoom.description);
      expect(copy.hourlyRate, testRoom.hourlyRate);
      expect(copy.requiresEngineer, testRoom.requiresEngineer);
      expect(copy.photoUrls, testRoom.photoUrls);
      expect(copy.equipmentList, testRoom.equipmentList);
      expect(copy.isActive, testRoom.isActive);
    });
  });

  group('defaults', () {
    test('requiresEngineer defaults to true', () {
      final room = StudioRoom(
        id: 'r',
        studioId: 's',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
      );
      expect(room.requiresEngineer, isTrue);
    });

    test('isActive defaults to true', () {
      final room = StudioRoom(
        id: 'r',
        studioId: 's',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
      );
      expect(room.isActive, isTrue);
    });

    test('photoUrls and equipmentList default to empty', () {
      final room = StudioRoom(
        id: 'r',
        studioId: 's',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
      );
      expect(room.photoUrls, isEmpty);
      expect(room.equipmentList, isEmpty);
    });
  });
}
