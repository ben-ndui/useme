import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:useme/core/blocs/studio_room/studio_room_bloc.dart';
import 'package:useme/core/blocs/studio_room/studio_room_event.dart';
import 'package:useme/core/blocs/studio_room/studio_room_state.dart';
import 'package:useme/core/models/studio_room.dart';
import 'package:useme/core/models/subscription_tier_config.dart';

import '../../helpers/mock_services.dart';
// FakeStudioRoom from mock_services

void main() {
  late MockStudioRoomService mockRoomService;
  late MockSubscriptionConfigService mockSubscription;

  final now = DateTime(2026, 3, 9);

  final testRoom = StudioRoom(
    id: 'room-1',
    studioId: 'studio-1',
    name: 'Studio A',
    description: 'Main recording room',
    hourlyRate: 80.0,
    requiresEngineer: true,
    equipmentList: const ['Mic', 'Mixer'],
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );

  final selfServiceRoom = StudioRoom(
    id: 'room-2',
    studioId: 'studio-1',
    name: 'Booth B',
    requiresEngineer: false,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );

  setUpAll(() {
    registerFallbackValue(FakeStudioRoom());
  });

  setUp(() {
    mockRoomService = MockStudioRoomService();
    mockSubscription = MockSubscriptionConfigService();
  });

  StudioRoomBloc buildBloc() => StudioRoomBloc(
        roomService: mockRoomService,
        subscriptionService: mockSubscription,
      );

  group('LoadStudioRoomsEvent', () {
    blocTest<StudioRoomBloc, StudioRoomState>(
      'emits [loading, loaded] on success',
      build: () {
        when(() => mockRoomService.getRoomsByStudio('studio-1'))
            .thenAnswer((_) async => [testRoom, selfServiceRoom]);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadStudioRoomsEvent(studioId: 'studio-1')),
      expect: () => [
        isA<StudioRoomState>()
            .having((s) => s.status, 'loading', StudioRoomStatus.loading),
        isA<StudioRoomState>()
            .having((s) => s.status, 'loaded', StudioRoomStatus.loaded)
            .having((s) => s.rooms.length, 'count', 2),
      ],
    );

    blocTest<StudioRoomBloc, StudioRoomState>(
      'emits [loading, error] on failure',
      build: () {
        when(() => mockRoomService.getRoomsByStudio('studio-1'))
            .thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadStudioRoomsEvent(studioId: 'studio-1')),
      expect: () => [
        isA<StudioRoomState>()
            .having((s) => s.status, 'loading', StudioRoomStatus.loading),
        isA<StudioRoomState>()
            .having((s) => s.status, 'error', StudioRoomStatus.error),
      ],
    );
  });

  group('CreateRoomEvent', () {
    blocTest<StudioRoomBloc, StudioRoomState>(
      'adds room to list on success',
      build: () {
        when(() => mockRoomService.createRoom(any()))
            .thenAnswer((_) async => testRoom);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateRoomEvent(room: testRoom)),
      expect: () => [
        isA<StudioRoomState>()
            .having((s) => s.rooms.length, 'count', 1)
            .having((s) => s.rooms.first.name, 'name', 'Studio A'),
      ],
    );

    blocTest<StudioRoomBloc, StudioRoomState>(
      'emits limitReached when subscription limit hit',
      build: () {
        when(() => mockSubscription.canCreateRoom(
              tierId: 'free',
              currentRoomsCount: 3,
            )).thenAnswer((_) async => false);
        when(() => mockSubscription.getTier('free'))
            .thenAnswer((_) async => const SubscriptionTierConfig(
                  id: 'free',
                  name: 'Free',
                  maxRooms: 3,
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateRoomEvent(
        room: testRoom,
        subscriptionTierId: 'free',
        currentRoomCount: 3,
      )),
      expect: () => [
        isA<StudioRoomState>()
            .having((s) => s.status, 'limit', StudioRoomStatus.limitReached)
            .having((s) => s.currentCount, 'current', 3)
            .having((s) => s.maxAllowed, 'max', 3),
      ],
    );
  });

  group('UpdateRoomEvent', () {
    final updated = testRoom.copyWith(name: 'Studio A+');

    blocTest<StudioRoomBloc, StudioRoomState>(
      'updates room in list on success',
      build: () {
        when(() => mockRoomService.updateRoom(any()))
            .thenAnswer((_) async => true);
        return buildBloc();
      },
      seed: () => StudioRoomState(
        status: StudioRoomStatus.loaded,
        rooms: [testRoom],
      ),
      act: (bloc) => bloc.add(UpdateRoomEvent(room: updated)),
      expect: () => [
        isA<StudioRoomState>()
            .having((s) => s.rooms.first.name, 'name', 'Studio A+'),
      ],
    );
  });

  group('DeleteRoomEvent', () {
    blocTest<StudioRoomBloc, StudioRoomState>(
      'removes room from list on success',
      build: () {
        when(() => mockRoomService.deleteRoom('room-1'))
            .thenAnswer((_) async => true);
        return buildBloc();
      },
      seed: () => StudioRoomState(
        status: StudioRoomStatus.loaded,
        rooms: [testRoom, selfServiceRoom],
      ),
      act: (bloc) => bloc.add(const DeleteRoomEvent(roomId: 'room-1')),
      expect: () => [
        isA<StudioRoomState>()
            .having((s) => s.rooms.length, 'count', 1)
            .having((s) => s.rooms.first.id, 'remaining', 'room-2'),
      ],
    );
  });

  group('ToggleRoomStatusEvent', () {
    blocTest<StudioRoomBloc, StudioRoomState>(
      'deactivates room',
      build: () {
        when(() => mockRoomService.toggleRoomStatus('room-1', false))
            .thenAnswer((_) async => true);
        return buildBloc();
      },
      seed: () => StudioRoomState(
        status: StudioRoomStatus.loaded,
        rooms: [testRoom],
      ),
      act: (bloc) => bloc.add(const ToggleRoomStatusEvent(
        roomId: 'room-1',
        isActive: false,
      )),
      expect: () => [
        isA<StudioRoomState>()
            .having((s) => s.rooms.first.isActive, 'deactivated', false),
      ],
    );
  });

  group('ClearStudioRoomsEvent', () {
    blocTest<StudioRoomBloc, StudioRoomState>(
      'resets to initial state',
      build: buildBloc,
      seed: () => StudioRoomState(
        status: StudioRoomStatus.loaded,
        rooms: [testRoom],
      ),
      act: (bloc) => bloc.add(const ClearStudioRoomsEvent()),
      expect: () => [
        isA<StudioRoomState>()
            .having((s) => s.status, 'initial', StudioRoomStatus.initial)
            .having((s) => s.rooms, 'empty', isEmpty),
      ],
    );
  });

  group('StudioRoomState helpers', () {
    test('activeRooms filters inactive', () {
      final state = StudioRoomState(
        rooms: [testRoom, testRoom.copyWith(id: 'r2', isActive: false)],
      );
      expect(state.activeRooms.length, 1);
    });

    test('roomsWithEngineer filters correctly', () {
      final state = StudioRoomState(
        rooms: [testRoom, selfServiceRoom],
      );
      expect(state.roomsWithEngineer.length, 1);
      expect(state.roomsWithEngineer.first.id, 'room-1');
    });

    test('selfServiceRooms filters correctly', () {
      final state = StudioRoomState(
        rooms: [testRoom, selfServiceRoom],
      );
      expect(state.selfServiceRooms.length, 1);
      expect(state.selfServiceRooms.first.id, 'room-2');
    });
  });
}
