import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/availability_service.dart';
import 'package:useme/core/services/engineer_availability_service.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockSessionService mockSessionService;
  late MockUnavailabilityService mockUnavailabilityService;
  late MockEngineerAvailabilityService mockEngineerService;
  late MockTeamService mockTeamService;
  late AvailabilityService service;

  // Fixed date: Monday March 9, 2026
  final testDate = DateTime(2026, 3, 9);

  setUp(() {
    mockSessionService = MockSessionService();
    mockUnavailabilityService = MockUnavailabilityService();
    mockEngineerService = MockEngineerAvailabilityService();
    mockTeamService = MockTeamService();

    service = AvailabilityService(
      sessionService: mockSessionService,
      unavailabilityService: mockUnavailabilityService,
      engineerService: mockEngineerService,
      teamService: mockTeamService,
    );
  });

  /// Helper: stub no sessions and no unavailabilities
  void stubEmpty(String studioId) {
    when(() => mockSessionService.getSessions(studioId))
        .thenAnswer((_) async => []);
    when(() => mockUnavailabilityService.getByDate(studioId, any()))
        .thenAnswer((_) async => []);
  }

  group('getAvailableSlots', () {
    test('generates 13 slots for default 9h-22h with 60min', () async {
      stubEmpty('studio-1');

      final slots = await service.getAvailableSlots(
        studioId: 'studio-1',
        date: testDate,
      );

      // 9h-22h = 13 hours = 13 x 60min slots
      expect(slots.length, 13);
      expect(slots.first.start.hour, 9);
      expect(slots.last.end.hour, 22);
      expect(slots.every((s) => s.isAvailable), isTrue);
    });

    test('generates correct slots for custom hours', () async {
      stubEmpty('studio-1');

      final slots = await service.getAvailableSlots(
        studioId: 'studio-1',
        date: testDate,
        openingHour: 10,
        closingHour: 14,
      );

      expect(slots.length, 4); // 10-11, 11-12, 12-13, 13-14
      expect(slots.first.start.hour, 10);
      expect(slots.last.end.hour, 14);
    });

    test('generates 30-min slots', () async {
      stubEmpty('studio-1');

      final slots = await service.getAvailableSlots(
        studioId: 'studio-1',
        date: testDate,
        openingHour: 10,
        closingHour: 12,
        slotDurationMinutes: 30,
      );

      expect(slots.length, 4); // 10:00, 10:30, 11:00, 11:30
      expect(slots.first.durationMinutes, 30);
    });

    test('marks slot as unavailable when session overlaps', () async {
      // Session from 10:00 to 11:00
      final session = SessionFactory.create(
        status: SessionStatus.confirmed,
        scheduledStart: DateTime(2026, 3, 9, 10, 0),
        scheduledEnd: DateTime(2026, 3, 9, 11, 0),
      );

      when(() => mockSessionService.getSessions('studio-1'))
          .thenAnswer((_) async => [session]);
      when(() => mockUnavailabilityService.getByDate('studio-1', any()))
          .thenAnswer((_) async => []);

      final slots = await service.getAvailableSlots(
        studioId: 'studio-1',
        date: testDate,
        openingHour: 9,
        closingHour: 13,
      );

      // 9-10: available, 10-11: blocked, 11-12: available, 12-13: available
      expect(slots.length, 4);
      expect(slots[0].isAvailable, isTrue); // 9-10
      expect(slots[1].isAvailable, isFalse); // 10-11
      expect(slots[2].isAvailable, isTrue); // 11-12
      expect(slots[3].isAvailable, isTrue); // 12-13
    });

    test('marks slot as unavailable when unavailability overlaps', () async {
      final unavailability = Unavailability(
        id: 'u-1',
        entityId: 'studio-1',
        start: DateTime(2026, 3, 9, 14, 0),
        end: DateTime(2026, 3, 9, 16, 0),
        source: UnavailabilitySource.manual,
        createdAt: DateTime.now(),
      );

      when(() => mockSessionService.getSessions('studio-1'))
          .thenAnswer((_) async => []);
      when(() => mockUnavailabilityService.getByDate('studio-1', any()))
          .thenAnswer((_) async => [unavailability]);

      final slots = await service.getAvailableSlots(
        studioId: 'studio-1',
        date: testDate,
        openingHour: 13,
        closingHour: 17,
      );

      expect(slots[0].isAvailable, isTrue); // 13-14
      expect(slots[1].isAvailable, isFalse); // 14-15
      expect(slots[2].isAvailable, isFalse); // 15-16
      expect(slots[3].isAvailable, isTrue); // 16-17
    });

    test('only considers confirmed and inProgress sessions', () async {
      final pendingSession = SessionFactory.create(
        status: SessionStatus.pending,
        scheduledStart: DateTime(2026, 3, 9, 10, 0),
        scheduledEnd: DateTime(2026, 3, 9, 11, 0),
      );
      final cancelledSession = SessionFactory.create(
        id: 'session-2',
        status: SessionStatus.cancelled,
        scheduledStart: DateTime(2026, 3, 9, 11, 0),
        scheduledEnd: DateTime(2026, 3, 9, 12, 0),
      );

      when(() => mockSessionService.getSessions('studio-1'))
          .thenAnswer((_) async => [pendingSession, cancelledSession]);
      when(() => mockUnavailabilityService.getByDate('studio-1', any()))
          .thenAnswer((_) async => []);

      final slots = await service.getAvailableSlots(
        studioId: 'studio-1',
        date: testDate,
        openingHour: 9,
        closingHour: 13,
      );

      // All available because pending/cancelled are filtered out
      expect(slots.every((s) => s.isAvailable), isTrue);
    });

    test('returns empty when studio is closed (working hours)', () async {
      stubEmpty('studio-1');

      // Sunday is closed (defaultSchedule has sunday disabled)
      final sunday = DateTime(2026, 3, 8); // Sunday
      final workingHours = WorkingHours.defaultSchedule();

      final slots = await service.getAvailableSlots(
        studioId: 'studio-1',
        date: sunday,
        workingHours: workingHours,
      );

      expect(slots, isEmpty);
    });

    test('uses working hours for opening/closing', () async {
      stubEmpty('studio-1');

      // Monday 10:00 - 16:00
      final workingHours = WorkingHours.defaultSchedule().copyWithDay(
        1, // Monday
        const DaySchedule(start: '10:00', end: '16:00', enabled: true),
      );

      final slots = await service.getAvailableSlots(
        studioId: 'studio-1',
        date: testDate, // Monday
        workingHours: workingHours,
      );

      // 10-16 = 6 slots
      expect(slots.length, 6);
      expect(slots.first.start.hour, 10);
      expect(slots.last.end.hour, 16);
    });
  });

  group('isSlotAvailable', () {
    test('returns true when no conflicts', () async {
      when(() => mockSessionService.getSessions('studio-1'))
          .thenAnswer((_) async => []);
      when(() => mockUnavailabilityService.hasConflict(
            'studio-1', any(), any()))
          .thenAnswer((_) async => false);

      final result = await service.isSlotAvailable(
        studioId: 'studio-1',
        start: DateTime(2026, 3, 9, 10, 0),
        end: DateTime(2026, 3, 9, 11, 0),
      );

      expect(result, isTrue);
    });

    test('returns false when session conflicts', () async {
      final session = SessionFactory.create(
        status: SessionStatus.confirmed,
        scheduledStart: DateTime(2026, 3, 9, 10, 0),
        scheduledEnd: DateTime(2026, 3, 9, 11, 0),
      );

      when(() => mockSessionService.getSessions('studio-1'))
          .thenAnswer((_) async => [session]);

      final result = await service.isSlotAvailable(
        studioId: 'studio-1',
        start: DateTime(2026, 3, 9, 10, 30),
        end: DateTime(2026, 3, 9, 11, 30),
      );

      expect(result, isFalse);
    });

    test('returns false when unavailability conflicts', () async {
      when(() => mockSessionService.getSessions('studio-1'))
          .thenAnswer((_) async => []);
      when(() => mockUnavailabilityService.hasConflict(
            'studio-1', any(), any()))
          .thenAnswer((_) async => true);

      final result = await service.isSlotAvailable(
        studioId: 'studio-1',
        start: DateTime(2026, 3, 9, 14, 0),
        end: DateTime(2026, 3, 9, 15, 0),
      );

      expect(result, isFalse);
    });
  });

  group('TimeSlot', () {
    test('durationMinutes', () {
      final slot = TimeSlot(
        start: DateTime(2026, 3, 9, 10, 0),
        end: DateTime(2026, 3, 9, 11, 30),
      );
      expect(slot.durationMinutes, 90);
    });

    test('toString format', () {
      final slot = TimeSlot(
        start: DateTime(2026, 3, 9, 9, 0),
        end: DateTime(2026, 3, 9, 10, 0),
      );
      expect(slot.toString(), '9:00 - 10:00');
    });
  });

  group('EnhancedTimeSlot.availabilityLevel', () {
    EnhancedTimeSlot makeSlot({
      required bool isAvailable,
      required int availableCount,
      required int total,
    }) {
      return EnhancedTimeSlot(
        start: DateTime(2026, 3, 9, 10, 0),
        end: DateTime(2026, 3, 9, 11, 0),
        isAvailable: isAvailable,
        totalEngineers: total,
        availableEngineers: List.generate(
          availableCount,
          (i) => AvailableEngineer(
            user: AppUser(
              uid: 'eng-$i',
              email: 'e$i@test.com',
              displayName: 'Eng $i',
            ),
            isAvailable: true,
          ),
        ),
      );
    }

    test('unavailable when slot not available', () {
      final slot = makeSlot(isAvailable: false, availableCount: 0, total: 3);
      expect(slot.availabilityLevel, AvailabilityLevel.unavailable);
    });

    test('noEngineer when available but 0 engineers', () {
      final slot = makeSlot(isAvailable: true, availableCount: 0, total: 3);
      expect(slot.availabilityLevel, AvailabilityLevel.noEngineer);
    });

    test('limited when only 1 engineer', () {
      final slot = makeSlot(isAvailable: true, availableCount: 1, total: 3);
      expect(slot.availabilityLevel, AvailabilityLevel.limited);
    });

    test('partial when some engineers', () {
      final slot = makeSlot(isAvailable: true, availableCount: 2, total: 3);
      expect(slot.availabilityLevel, AvailabilityLevel.partial);
    });

    test('full when all engineers available', () {
      final slot = makeSlot(isAvailable: true, availableCount: 3, total: 3);
      expect(slot.availabilityLevel, AvailabilityLevel.full);
    });

    test('hasAvailableEngineer', () {
      expect(
        makeSlot(isAvailable: true, availableCount: 0, total: 3)
            .hasAvailableEngineer,
        isFalse,
      );
      expect(
        makeSlot(isAvailable: true, availableCount: 1, total: 3)
            .hasAvailableEngineer,
        isTrue,
      );
    });
  });
}
