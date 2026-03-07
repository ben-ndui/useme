import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/blocs/engineer_availability/engineer_availability_bloc.dart';
import 'package:useme/core/blocs/engineer_availability/engineer_availability_event.dart';
import 'package:useme/core/blocs/engineer_availability/engineer_availability_state.dart';
import 'package:useme/core/models/models_exports.dart';

import '../../helpers/mock_services.dart';

void main() {
  late MockEngineerAvailabilityService mockService;

  final defaultHours = WorkingHours.defaultSchedule();

  final testTimeOff = TimeOff(
    id: 'to-1',
    engineerId: 'eng-1',
    start: DateTime(2026, 3, 15, 9, 0),
    end: DateTime(2026, 3, 15, 18, 0),
    reason: 'Vacances',
    createdAt: DateTime(2026, 3, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeTimeOff());
    registerFallbackValue(WorkingHours.defaultSchedule());
  });

  setUp(() {
    mockService = MockEngineerAvailabilityService();
  });

  EngineerAvailabilityBloc buildBloc() =>
      EngineerAvailabilityBloc(service: mockService);

  group('LoadEngineerAvailabilityEvent', () {
    blocTest<EngineerAvailabilityBloc, EngineerAvailabilityState>(
      'emits [loading, loaded] on success',
      build: () {
        when(() => mockService.getWorkingHours('eng-1'))
            .thenAnswer((_) async => defaultHours);
        when(() => mockService.streamFutureTimeOffs('eng-1'))
            .thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoadEngineerAvailabilityEvent(engineerId: 'eng-1'),
      ),
      expect: () => [
        isA<EngineerAvailabilityLoadingState>()
            .having((s) => s.engineerId, 'engineerId', 'eng-1'),
        isA<EngineerAvailabilityLoadedState>()
            .having((s) => s.engineerId, 'engineerId', 'eng-1')
            .having((s) => s.workingHours, 'hours', isNotNull),
      ],
    );

    blocTest<EngineerAvailabilityBloc, EngineerAvailabilityState>(
      'emits [loading, error] on failure',
      build: () {
        when(() => mockService.getWorkingHours('eng-1'))
            .thenThrow(Exception('network'));
        when(() => mockService.streamFutureTimeOffs('eng-1'))
            .thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoadEngineerAvailabilityEvent(engineerId: 'eng-1'),
      ),
      expect: () => [
        isA<EngineerAvailabilityLoadingState>(),
        isA<EngineerAvailabilityErrorState>(),
      ],
    );
  });

  group('UpdateWorkingHoursEvent', () {
    final newHours = defaultHours.copyWithDay(
      1,
      const DaySchedule(start: '10:00', end: '18:00', enabled: true),
    );

    blocTest<EngineerAvailabilityBloc, EngineerAvailabilityState>(
      'emits WorkingHoursUpdatedState on success',
      build: () {
        when(() => mockService.setWorkingHours('eng-1', any()))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => EngineerAvailabilityLoadedState(
        engineerId: 'eng-1',
        workingHours: defaultHours,
        timeOffs: const [],
      ),
      act: (bloc) => bloc.add(UpdateWorkingHoursEvent(
        engineerId: 'eng-1',
        workingHours: newHours,
      )),
      expect: () => [
        isA<WorkingHoursUpdatedState>()
            .having((s) => s.engineerId, 'engineerId', 'eng-1')
            .having((s) => s.successMessage, 'msg', 'Horaires mis à jour'),
      ],
    );

    blocTest<EngineerAvailabilityBloc, EngineerAvailabilityState>(
      'emits error on failure (code 500)',
      build: () {
        when(() => mockService.setWorkingHours('eng-1', any()))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 500, message: 'Fail', data: false));
        return buildBloc();
      },
      seed: () => EngineerAvailabilityLoadedState(
        engineerId: 'eng-1',
        workingHours: defaultHours,
        timeOffs: const [],
      ),
      act: (bloc) => bloc.add(UpdateWorkingHoursEvent(
        engineerId: 'eng-1',
        workingHours: newHours,
      )),
      expect: () => [
        isA<EngineerAvailabilityErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Fail'),
      ],
    );
  });

  group('UpdateDayScheduleEvent', () {
    blocTest<EngineerAvailabilityBloc, EngineerAvailabilityState>(
      'updates specific day and emits WorkingHoursUpdatedState',
      build: () {
        when(() => mockService.setWorkingHours('eng-1', any()))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => EngineerAvailabilityLoadedState(
        engineerId: 'eng-1',
        workingHours: defaultHours,
        timeOffs: const [],
      ),
      act: (bloc) => bloc.add(const UpdateDayScheduleEvent(
        engineerId: 'eng-1',
        weekday: 6, // Saturday
        schedule: DaySchedule(start: '11:00', end: '17:00', enabled: true),
      )),
      expect: () => [
        isA<WorkingHoursUpdatedState>()
            .having((s) => s.engineerId, 'id', 'eng-1'),
      ],
    );

    blocTest<EngineerAvailabilityBloc, EngineerAvailabilityState>(
      'does nothing when workingHours is null',
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateDayScheduleEvent(
        engineerId: 'eng-1',
        weekday: 1,
        schedule: DaySchedule(start: '09:00', end: '17:00', enabled: true),
      )),
      expect: () => [],
    );
  });

  group('AddTimeOffEvent', () {
    blocTest<EngineerAvailabilityBloc, EngineerAvailabilityState>(
      'emits TimeOffAddedState on success (code 201)',
      build: () {
        when(() => mockService.addTimeOff(any()))
            .thenAnswer((_) async => SmoothResponse(
                  code: 201,
                  message: 'OK',
                  data: testTimeOff,
                ));
        return buildBloc();
      },
      seed: () => EngineerAvailabilityLoadedState(
        engineerId: 'eng-1',
        workingHours: defaultHours,
        timeOffs: const [],
      ),
      act: (bloc) => bloc.add(AddTimeOffEvent(timeOff: testTimeOff)),
      expect: () => [
        isA<TimeOffAddedState>()
            .having((s) => s.addedTimeOff.id, 'id', 'to-1')
            .having((s) => s.timeOffs.length, 'count', 1)
            .having((s) => s.successMessage, 'msg', 'Indisponibilité ajoutée'),
      ],
    );

    blocTest<EngineerAvailabilityBloc, EngineerAvailabilityState>(
      'emits error on failure',
      build: () {
        when(() => mockService.addTimeOff(any()))
            .thenAnswer((_) async => const SmoothResponse(
                  code: 500,
                  message: 'Erreur serveur',
                  data: null,
                ));
        return buildBloc();
      },
      seed: () => EngineerAvailabilityLoadedState(
        engineerId: 'eng-1',
        workingHours: defaultHours,
        timeOffs: const [],
      ),
      act: (bloc) => bloc.add(AddTimeOffEvent(timeOff: testTimeOff)),
      expect: () => [
        isA<EngineerAvailabilityErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Erreur serveur'),
      ],
    );
  });

  group('DeleteTimeOffEvent', () {
    blocTest<EngineerAvailabilityBloc, EngineerAvailabilityState>(
      'emits TimeOffDeletedState and removes from list',
      build: () {
        when(() => mockService.deleteTimeOff('to-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => EngineerAvailabilityLoadedState(
        engineerId: 'eng-1',
        workingHours: defaultHours,
        timeOffs: [testTimeOff],
      ),
      act: (bloc) =>
          bloc.add(const DeleteTimeOffEvent(timeOffId: 'to-1')),
      expect: () => [
        isA<TimeOffDeletedState>()
            .having((s) => s.deletedTimeOffId, 'id', 'to-1')
            .having((s) => s.timeOffs, 'empty', isEmpty)
            .having(
                (s) => s.successMessage, 'msg', 'Indisponibilité supprimée'),
      ],
    );

    blocTest<EngineerAvailabilityBloc, EngineerAvailabilityState>(
      'emits error on delete failure',
      build: () {
        when(() => mockService.deleteTimeOff('to-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 500, message: 'Not found', data: false));
        return buildBloc();
      },
      seed: () => EngineerAvailabilityLoadedState(
        engineerId: 'eng-1',
        workingHours: defaultHours,
        timeOffs: [testTimeOff],
      ),
      act: (bloc) =>
          bloc.add(const DeleteTimeOffEvent(timeOffId: 'to-1')),
      expect: () => [
        isA<EngineerAvailabilityErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Not found'),
      ],
    );
  });
}
