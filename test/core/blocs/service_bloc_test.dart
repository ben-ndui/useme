import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/blocs/service/service_bloc.dart';
import 'package:useme/core/blocs/service/service_event.dart';
import 'package:useme/core/blocs/service/service_state.dart';
import 'package:useme/core/models/models_exports.dart';

import '../../helpers/mock_services.dart';

void main() {
  late MockServiceCatalogService mockServiceCatalog;
  late MockSubscriptionConfigService mockSubscription;

  final now = DateTime(2026, 3, 9);

  final testService = StudioService(
    id: 'svc-1',
    studioId: 'studio-1',
    name: 'Recording',
    hourlyRate: 50.0,
    createdAt: now,
  );
  final testServices = [testService];

  setUpAll(() {
    registerFallbackValue(FakeStudioService());
  });

  setUp(() {
    mockServiceCatalog = MockServiceCatalogService();
    mockSubscription = MockSubscriptionConfigService();
  });

  ServiceBloc buildBloc() => ServiceBloc(
        serviceCatalogService: mockServiceCatalog,
        subscriptionService: mockSubscription,
      );

  group('LoadServicesEvent', () {
    blocTest<ServiceBloc, ServiceState>(
      'emits [loading, loaded] on success',
      build: () {
        when(() => mockServiceCatalog.getServicesByStudioId('studio-1'))
            .thenAnswer((_) async => testServices);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadServicesEvent(studioId: 'studio-1')),
      expect: () => [
        isA<ServiceLoadingState>(),
        isA<ServicesLoadedState>()
            .having((s) => s.services.length, 'count', 1),
      ],
    );

    blocTest<ServiceBloc, ServiceState>(
      'emits [loading, error] on failure',
      build: () {
        when(() => mockServiceCatalog.getServicesByStudioId('studio-1'))
            .thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadServicesEvent(studioId: 'studio-1')),
      expect: () => [
        isA<ServiceLoadingState>(),
        isA<ServiceErrorState>(),
      ],
    );
  });

  group('SearchServicesEvent', () {
    blocTest<ServiceBloc, ServiceState>(
      'emits [loading, loaded] with results',
      build: () {
        when(() => mockServiceCatalog.searchServices('studio-1', 'Rec'))
            .thenAnswer((_) async => testServices);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SearchServicesEvent(
        studioId: 'studio-1',
        query: 'Rec',
      )),
      expect: () => [
        isA<ServiceLoadingState>(),
        isA<ServicesLoadedState>(),
      ],
    );
  });

  group('CreateServiceEvent', () {
    blocTest<ServiceBloc, ServiceState>(
      'emits [loading, created] on success without subscription check',
      build: () {
        when(() => mockServiceCatalog.createService('studio-1', any()))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        when(() => mockServiceCatalog.getServicesByStudioId('studio-1'))
            .thenAnswer((_) async => testServices);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateServiceEvent(service: testService)),
      expect: () => [
        isA<ServiceLoadingState>(),
        isA<ServiceCreatedState>()
            .having((s) => s.createdService.name, 'name', 'Recording')
            .having((s) => s.services.length, 'refetched', 1),
      ],
    );

    blocTest<ServiceBloc, ServiceState>(
      'emits [loading, error] on create failure (code 500)',
      build: () {
        when(() => mockServiceCatalog.createService('studio-1', any()))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 500, message: 'Duplicate', data: false));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateServiceEvent(service: testService)),
      expect: () => [
        isA<ServiceLoadingState>(),
        isA<ServiceErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Duplicate'),
      ],
    );

    blocTest<ServiceBloc, ServiceState>(
      'emits [loading, limitReached] when subscription limit hit',
      build: () {
        when(() => mockSubscription.canCreateService(
              tierId: 'free',
              currentServicesCount: 5,
            )).thenAnswer((_) async => false);
        when(() => mockSubscription.getTier('free'))
            .thenAnswer((_) async => const SubscriptionTierConfig(
                  id: 'free',
                  name: 'Free',
                  maxSessions: 10,
                  maxServices: 5,
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateServiceEvent(
        service: testService,
        subscriptionTierId: 'free',
        currentServiceCount: 5,
      )),
      expect: () => [
        isA<ServiceLoadingState>(),
        isA<ServiceLimitReachedState>()
            .having((s) => s.currentCount, 'current', 5)
            .having((s) => s.maxAllowed, 'max', 5),
      ],
    );
  });

  group('UpdateServiceEvent', () {
    final updated = testService.copyWith(name: 'Mixing');

    blocTest<ServiceBloc, ServiceState>(
      'emits [loading, updated] with modified list',
      build: () {
        when(() => mockServiceCatalog.updateService('svc-1', any()))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => ServicesLoadedState(services: testServices),
      act: (bloc) => bloc.add(UpdateServiceEvent(service: updated)),
      expect: () => [
        isA<ServiceLoadingState>(),
        isA<ServiceUpdatedState>()
            .having((s) => s.updatedService.name, 'name', 'Mixing')
            .having((s) => s.services.first.name, 'list', 'Mixing'),
      ],
    );
  });

  group('DeleteServiceEvent', () {
    blocTest<ServiceBloc, ServiceState>(
      'emits [loading, deleted] and removes from list',
      build: () {
        when(() => mockServiceCatalog.deleteService('svc-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => ServicesLoadedState(services: testServices),
      act: (bloc) =>
          bloc.add(const DeleteServiceEvent(serviceId: 'svc-1')),
      expect: () => [
        isA<ServiceLoadingState>(),
        isA<ServiceDeletedState>()
            .having((s) => s.services, 'empty', isEmpty),
      ],
    );

    blocTest<ServiceBloc, ServiceState>(
      'emits error on delete failure',
      build: () {
        when(() => mockServiceCatalog.deleteService('svc-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 500, message: 'Not found'));
        return buildBloc();
      },
      seed: () => ServicesLoadedState(services: testServices),
      act: (bloc) =>
          bloc.add(const DeleteServiceEvent(serviceId: 'svc-1')),
      expect: () => [
        isA<ServiceLoadingState>(),
        isA<ServiceErrorState>(),
      ],
    );
  });

  group('DeactivateServiceEvent', () {
    blocTest<ServiceBloc, ServiceState>(
      'sets isActive to false in list',
      build: () {
        when(() => mockServiceCatalog.deactivateService('svc-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => ServicesLoadedState(services: testServices),
      act: (bloc) =>
          bloc.add(const DeactivateServiceEvent(serviceId: 'svc-1')),
      expect: () => [
        isA<ServicesLoadedState>()
            .having((s) => s.services.first.isActive, 'deactivated', false),
      ],
    );
  });

  group('ReactivateServiceEvent', () {
    blocTest<ServiceBloc, ServiceState>(
      'sets isActive to true in list',
      build: () {
        when(() => mockServiceCatalog.reactivateService('svc-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => ServicesLoadedState(
        services: [testService.copyWith(isActive: false)],
      ),
      act: (bloc) =>
          bloc.add(const ReactivateServiceEvent(serviceId: 'svc-1')),
      expect: () => [
        isA<ServicesLoadedState>()
            .having((s) => s.services.first.isActive, 'reactivated', true),
      ],
    );
  });

  group('ClearServicesEvent', () {
    blocTest<ServiceBloc, ServiceState>(
      'resets to initial state',
      build: buildBloc,
      seed: () => ServicesLoadedState(services: testServices),
      act: (bloc) => bloc.add(const ClearServicesEvent()),
      expect: () => [isA<ServiceInitialState>()],
    );
  });
}
