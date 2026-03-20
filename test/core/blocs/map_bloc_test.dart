import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/blocs/map/map_event.dart';
import 'package:useme/core/blocs/map/map_state.dart';
import 'package:useme/core/models/discovered_studio.dart';

import '../../helpers/mock_services.dart';

void main() {
  late MockLocationService mockLocationService;
  late MockStudioDiscoveryService mockStudioService;

  const parisPosition = LatLng(48.8566, 2.3522);
  const lyonPosition = LatLng(45.7640, 4.8357);

  final testStudio = DiscoveredStudio(
    id: 'studio-1',
    name: 'Cool Studio',
    address: '1 rue de la Musique',
    position: parisPosition,
    isPartner: true,
    services: ['Recording', 'Mixing'],
    distanceMeters: 500,
  );

  final nonPartnerStudio = DiscoveredStudio(
    id: 'studio-2',
    name: 'Indie Studio',
    address: '2 rue du Son',
    position: parisPosition,
    isPartner: false,
    services: ['Mastering'],
    distanceMeters: 1000,
  );

  setUpAll(() {
    registerFallbackValue(parisPosition);
  });

  setUp(() {
    mockLocationService = MockLocationService();
    mockStudioService = MockStudioDiscoveryService();
  });

  MapBloc buildBloc() => MapBloc(
        locationService: mockLocationService,
        studioService: mockStudioService,
      );

  group('InitMapEvent', () {
    blocTest<MapBloc, MapState>(
      'gets location and loads nearby studios',
      build: () {
        when(() => mockLocationService.getCurrentLatLng())
            .thenAnswer((_) async => parisPosition);
        when(() => mockLocationService.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(() => mockStudioService.findNearbyStudios(
              any(),
              radius: any(named: 'radius'),
            )).thenAnswer((_) async => [testStudio]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const InitMapEvent()),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        // First: loading with location
        isA<MapState>().having((s) => s.isLoading, 'loading', true),
        // Then: location set
        isA<MapState>()
            .having((s) => s.userLocation, 'location', parisPosition)
            .having((s) => s.hasLocationPermission, 'permission', true),
        // Then: studios loading
        isA<MapState>().having((s) => s.isLoading, 'loading', true),
        // Then: studios loaded
        isA<MapState>()
            .having((s) => s.nearbyStudios.length, 'studios', 1)
            .having((s) => s.isLoading, 'done', false),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits error when location fails',
      build: () {
        when(() => mockLocationService.getCurrentLatLng())
            .thenThrow(Exception('GPS disabled'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const InitMapEvent()),
      expect: () => [
        isA<MapState>().having((s) => s.isLoading, 'loading', true),
        isA<MapState>().having((s) => s.hasError, 'has error', true),
      ],
    );
  });

  group('SearchByAddressEvent', () {
    blocTest<MapBloc, MapState>(
      'geocodes address and loads studios',
      build: () {
        when(() => mockStudioService.geocodeAddress('Lyon'))
            .thenAnswer((_) async => lyonPosition);
        when(() => mockStudioService.findNearbyStudios(
              any(),
              radius: any(named: 'radius'),
            )).thenAnswer((_) async => [testStudio]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SearchByAddressEvent(address: 'Lyon')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        // Searching
        isA<MapState>()
            .having((s) => s.isSearchingAddress, 'searching', true)
            .having((s) => s.searchQuery, 'query', 'Lyon'),
        // Address found
        isA<MapState>()
            .having((s) => s.isSearchingAddress, 'done', false)
            .having((s) => s.searchCenter, 'center', lyonPosition),
        // Loading studios in area
        isA<MapState>().having((s) => s.isLoading, 'loading', true),
        // Studios loaded
        isA<MapState>()
            .having((s) => s.nearbyStudios.length, 'studios', 1)
            .having((s) => s.isLoading, 'done', false),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits error when address not found',
      build: () {
        when(() => mockStudioService.geocodeAddress('zzzzz'))
            .thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const SearchByAddressEvent(address: 'zzzzz')),
      expect: () => [
        isA<MapState>().having((s) => s.isSearchingAddress, 'searching', true),
        isA<MapState>()
            .having((s) => s.error, 'error', 'Adresse non trouvée'),
      ],
    );
  });

  group('SearchByAddressEvent - studio name match', () {
    blocTest<MapBloc, MapState>(
      'matches exact studio name without geocoding',
      build: buildBloc,
      seed: () => MapState(nearbyStudios: [testStudio, nonPartnerStudio]),
      act: (bloc) =>
          bloc.add(const SearchByAddressEvent(address: 'Cool Studio')),
      expect: () => [
        // Searching
        isA<MapState>()
            .having((s) => s.isSearchingAddress, 'searching', true)
            .having((s) => s.searchQuery, 'query', 'Cool Studio'),
        // Matched studio directly — no geocoding needed
        isA<MapState>()
            .having((s) => s.isSearchingAddress, 'done', false)
            .having((s) => s.selectedStudio?.id, 'selected', 'studio-1')
            .having(
                (s) => s.searchCenter, 'center', testStudio.position),
      ],
      verify: (_) {
        // geocodeAddress should NOT have been called
        verifyNever(() => mockStudioService.geocodeAddress(any()));
      },
    );

    blocTest<MapBloc, MapState>(
      'matches studio name with partial/contains query',
      build: buildBloc,
      seed: () => MapState(nearbyStudios: [testStudio, nonPartnerStudio]),
      act: (bloc) =>
          bloc.add(const SearchByAddressEvent(address: 'Cool')),
      expect: () => [
        isA<MapState>().having((s) => s.isSearchingAddress, 'searching', true),
        isA<MapState>()
            .having((s) => s.isSearchingAddress, 'done', false)
            .having((s) => s.selectedStudio?.id, 'selected', 'studio-1'),
      ],
      verify: (_) {
        verifyNever(() => mockStudioService.geocodeAddress(any()));
      },
    );

    blocTest<MapBloc, MapState>(
      'falls back to geocoding when no studio name matches',
      build: () {
        when(() => mockStudioService.geocodeAddress('Marseille'))
            .thenAnswer((_) async => lyonPosition);
        when(() => mockStudioService.findNearbyStudios(
              any(),
              radius: any(named: 'radius'),
            )).thenAnswer((_) async => [testStudio]);
        return buildBloc();
      },
      seed: () => MapState(nearbyStudios: [testStudio]),
      act: (bloc) =>
          bloc.add(const SearchByAddressEvent(address: 'Marseille')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<MapState>().having((s) => s.isSearchingAddress, 'searching', true),
        // Geocoded result (not a name match)
        isA<MapState>()
            .having((s) => s.isSearchingAddress, 'done', false)
            .having((s) => s.searchCenter, 'center', lyonPosition),
        isA<MapState>().having((s) => s.isLoading, 'loading', true),
        isA<MapState>().having((s) => s.isLoading, 'done', false),
      ],
      verify: (_) {
        verify(() => mockStudioService.geocodeAddress('Marseille')).called(1);
      },
    );

    blocTest<MapBloc, MapState>(
      'name match is case-insensitive',
      build: buildBloc,
      seed: () => MapState(nearbyStudios: [testStudio]),
      act: (bloc) =>
          bloc.add(const SearchByAddressEvent(address: 'cool studio')),
      expect: () => [
        isA<MapState>().having((s) => s.isSearchingAddress, 'searching', true),
        isA<MapState>()
            .having((s) => s.selectedStudio?.id, 'selected', 'studio-1'),
      ],
    );
  });

  group('UpdateSearchCenterEvent', () {
    blocTest<MapBloc, MapState>(
      'detects camera moved when position changes',
      build: buildBloc,
      seed: () => const MapState(searchCenter: parisPosition),
      act: (bloc) => bloc.add(
        const UpdateSearchCenterEvent(center: lyonPosition),
      ),
      expect: () => [
        isA<MapState>()
            .having((s) => s.searchCenter, 'center', lyonPosition)
            .having((s) => s.hasCameraMoved, 'moved', true),
      ],
    );

    blocTest<MapBloc, MapState>(
      'does not flag moved when position unchanged',
      build: buildBloc,
      seed: () => const MapState(searchCenter: parisPosition),
      act: (bloc) => bloc.add(
        const UpdateSearchCenterEvent(center: parisPosition),
      ),
      expect: () => [
        isA<MapState>()
            .having((s) => s.hasCameraMoved, 'not moved', false),
      ],
    );
  });

  group('SelectStudio / DeselectStudio', () {
    blocTest<MapBloc, MapState>(
      'selects and deselects studio',
      build: buildBloc,
      act: (bloc) {
        bloc.add(SelectStudioEvent(studio: testStudio));
        bloc.add(const DeselectStudioEvent());
      },
      expect: () => [
        isA<MapState>()
            .having((s) => s.selectedStudio?.id, 'selected', 'studio-1'),
        isA<MapState>()
            .having((s) => s.selectedStudio, 'deselected', isNull),
      ],
    );
  });

  group('UpdateFiltersEvent / ClearFiltersEvent', () {
    blocTest<MapBloc, MapState>(
      'applies service and partner filters',
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateFiltersEvent(
        serviceFilters: {'Recording'},
        partnerOnly: true,
      )),
      expect: () => [
        isA<MapState>()
            .having((s) => s.serviceFilters, 'filters', {'Recording'})
            .having((s) => s.partnerOnly, 'partner', true)
            .having((s) => s.hasActiveFilters, 'active', true),
      ],
    );

    blocTest<MapBloc, MapState>(
      'clears all filters',
      build: buildBloc,
      seed: () => const MapState(
        serviceFilters: {'Recording'},
        partnerOnly: true,
      ),
      act: (bloc) => bloc.add(const ClearFiltersEvent()),
      expect: () => [
        isA<MapState>()
            .having((s) => s.serviceFilters, 'empty', isEmpty)
            .having((s) => s.partnerOnly, 'false', false)
            .having((s) => s.hasActiveFilters, 'inactive', false),
      ],
    );
  });

  group('MapState.filteredStudios', () {
    final proStudio = DiscoveredStudio(
      id: 'pro_user-1',
      name: 'DJ Pro',
      position: parisPosition,
      isPro: true,
      services: const ['Musicien'],
      distanceMeters: 800,
    );

    test('returns all studios when no filters', () {
      final state = MapState(nearbyStudios: [testStudio, nonPartnerStudio]);
      expect(state.filteredStudios.length, 2);
    });

    test('filters partner only', () {
      final state = MapState(
        nearbyStudios: [testStudio, nonPartnerStudio],
        partnerOnly: true,
      );
      expect(state.filteredStudios.length, 1);
      expect(state.filteredStudios.first.isPartner, true);
    });

    test('filters by service', () {
      final state = MapState(
        nearbyStudios: [testStudio, nonPartnerStudio],
        serviceFilters: const {'mastering'},
      );
      expect(state.filteredStudios.length, 1);
      expect(state.filteredStudios.first.id, 'studio-2');
    });

    test('combines partner + service filter', () {
      final state = MapState(
        nearbyStudios: [testStudio, nonPartnerStudio],
        serviceFilters: const {'recording'},
        partnerOnly: true,
      );
      expect(state.filteredStudios.length, 1);
      expect(state.filteredStudios.first.id, 'studio-1');
    });

    test('pros always pass filters', () {
      final state = MapState(
        nearbyStudios: [testStudio, nonPartnerStudio, proStudio],
        partnerOnly: true,
        serviceFilters: const {'recording'},
      );
      // Only partner studio with Recording + pro (always passes)
      expect(state.filteredStudios.length, 2);
      expect(state.filteredStudios.any((s) => s.isPro), true);
      expect(state.filteredStudios.any((s) => s.id == 'studio-1'), true);
    });

    test('hasStudios and hasError helpers', () {
      expect(const MapState().hasStudios, false);
      expect(const MapState().hasError, false);
      expect(
        MapState(nearbyStudios: [testStudio]).hasStudios,
        true,
      );
      expect(
        const MapState(error: 'oops').hasError,
        true,
      );
    });
  });

  group('DiscoveredStudio.isPro', () {
    test('isPro defaults to false', () {
      expect(testStudio.isPro, false);
    });

    test('proUserId extracts user id from pro marker', () {
      const pro = DiscoveredStudio(
        id: 'pro_user-123',
        name: 'DJ',
        position: parisPosition,
        isPro: true,
      );
      expect(pro.proUserId, 'user-123');
    });

    test('proUserId is null for non-pro', () {
      expect(testStudio.proUserId, isNull);
    });

    test('copyWithDistance preserves isPro', () {
      const pro = DiscoveredStudio(
        id: 'pro_1',
        name: 'Pro',
        position: parisPosition,
        isPro: true,
      );
      final copy = pro.copyWithDistance(500);
      expect(copy.isPro, true);
      expect(copy.distanceMeters, 500);
    });

    test('pro marker appears in markers set', () {
      const pro = DiscoveredStudio(
        id: 'pro_1',
        name: 'Pro',
        position: parisPosition,
        isPro: true,
      );
      final state = MapState(nearbyStudios: [pro]);
      expect(state.markers.length, 1);
      expect(state.markers.first.markerId.value, 'pro_1');
    });
  });
}
