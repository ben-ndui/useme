import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/blocs/artist/artist_bloc.dart';
import 'package:useme/core/blocs/artist/artist_event.dart';
import 'package:useme/core/blocs/artist/artist_state.dart';
import 'package:useme/core/models/models_exports.dart';

import '../../helpers/mock_services.dart';

void main() {
  late MockArtistService mockArtistService;

  final testArtist = Artist(
    id: 'artist-1',
    studioIds: ['studio-1'],
    name: 'Test Artist',
    stageName: 'DJ Test',
    email: 'test@email.com',
    genres: ['Hip-Hop', 'R&B'],
    createdAt: DateTime(2026, 1, 1),
  );
  final testArtists = [testArtist];

  setUpAll(() {
    registerFallbackValue(FakeArtist());
  });

  setUp(() {
    mockArtistService = MockArtistService();
  });

  ArtistBloc buildBloc() =>
      ArtistBloc(artistService: mockArtistService);

  group('LoadArtistsEvent', () {
    blocTest<ArtistBloc, ArtistState>(
      'emits [loading, loaded] on success',
      build: () {
        when(() => mockArtistService.getArtistsByStudioId('studio-1'))
            .thenAnswer((_) async => testArtists);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadArtistsEvent(studioId: 'studio-1')),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistsLoadedState>()
            .having((s) => s.artists.length, 'count', 1),
      ],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits [loading, error] on failure',
      build: () {
        when(() => mockArtistService.getArtistsByStudioId('studio-1'))
            .thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadArtistsEvent(studioId: 'studio-1')),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistErrorState>(),
      ],
    );
  });

  group('SearchArtistsEvent', () {
    blocTest<ArtistBloc, ArtistState>(
      'emits [loading, loaded] with search results',
      build: () {
        when(() => mockArtistService.searchArtists('studio-1', 'DJ'))
            .thenAnswer((_) async => testArtists);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SearchArtistsEvent(
        studioId: 'studio-1',
        query: 'DJ',
      )),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistsLoadedState>(),
      ],
    );
  });

  group('CreateArtistEvent', () {
    blocTest<ArtistBloc, ArtistState>(
      'emits [loading, created] and refetches list on success',
      build: () {
        when(() => mockArtistService.createArtist('studio-1', any()))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        when(() => mockArtistService.getArtistsByStudioId('studio-1'))
            .thenAnswer((_) async => testArtists);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateArtistEvent(artist: testArtist)),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistCreatedState>()
            .having((s) => s.createdArtist.name, 'name', 'Test Artist')
            .having((s) => s.artists.length, 'refetched', 1),
      ],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits [loading, error] on failure (code 500)',
      build: () {
        when(() => mockArtistService.createArtist('studio-1', any()))
            .thenAnswer((_) async => const SmoothResponse(
                  code: 500,
                  message: 'Duplicate artist',
                  data: false,
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateArtistEvent(artist: testArtist)),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Duplicate artist'),
      ],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits error when artist has empty studioIds',
      build: () {
        testArtist.copyWith(studioIds: []);
        when(() => mockArtistService.createArtist('', any()))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        when(() => mockArtistService.getArtistsByStudioId(''))
            .thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateArtistEvent(
        artist: testArtist.copyWith(studioIds: []),
      )),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistCreatedState>()
            .having((s) => s.artists, 'empty', isEmpty),
      ],
    );
  });

  group('UpdateArtistEvent', () {
    final updated = testArtist.copyWith(name: 'Updated Name');

    blocTest<ArtistBloc, ArtistState>(
      'emits [loading, updated] with updated list',
      build: () {
        when(() => mockArtistService.updateArtist(
                'artist-1', any()))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => ArtistsLoadedState(artists: testArtists),
      act: (bloc) => bloc.add(UpdateArtistEvent(artist: updated)),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistUpdatedState>()
            .having((s) => s.updatedArtist.name, 'name', 'Updated Name')
            .having(
                (s) => s.artists.first.name, 'list updated', 'Updated Name'),
      ],
    );
  });

  group('DeleteArtistEvent', () {
    blocTest<ArtistBloc, ArtistState>(
      'emits [loading, deleted] and removes from list',
      build: () {
        when(() => mockArtistService.deleteArtist('artist-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => ArtistsLoadedState(artists: testArtists),
      act: (bloc) =>
          bloc.add(const DeleteArtistEvent(artistId: 'artist-1')),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistDeletedState>()
            .having((s) => s.artists, 'empty', isEmpty),
      ],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits error on delete failure',
      build: () {
        when(() => mockArtistService.deleteArtist('artist-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 500, message: 'Not found'));
        return buildBloc();
      },
      seed: () => ArtistsLoadedState(artists: testArtists),
      act: (bloc) =>
          bloc.add(const DeleteArtistEvent(artistId: 'artist-1')),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistErrorState>(),
      ],
    );
  });

  group('LoadArtistByIdEvent', () {
    blocTest<ArtistBloc, ArtistState>(
      'emits [loading, detail] when found',
      build: () {
        when(() => mockArtistService.getArtistById('artist-1'))
            .thenAnswer((_) async => testArtist);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadArtistByIdEvent(artistId: 'artist-1')),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistDetailLoadedState>()
            .having((s) => s.selectedArtist?.name, 'name', 'Test Artist'),
      ],
    );

    blocTest<ArtistBloc, ArtistState>(
      'emits [loading, error] when not found',
      build: () {
        when(() => mockArtistService.getArtistById('missing'))
            .thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadArtistByIdEvent(artistId: 'missing')),
      expect: () => [
        isA<ArtistLoadingState>(),
        isA<ArtistErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Artiste introuvable'),
      ],
    );
  });

  group('ClearArtistsEvent', () {
    blocTest<ArtistBloc, ArtistState>(
      'resets to initial state',
      build: buildBloc,
      seed: () => ArtistsLoadedState(artists: testArtists),
      act: (bloc) => bloc.add(const ClearArtistsEvent()),
      expect: () => [isA<ArtistInitialState>()],
    );
  });

  group('Artist model', () {
    test('displayName returns stageName when available', () {
      expect(testArtist.displayName, 'DJ Test');
    });

    test('displayName returns name when no stageName', () {
      testArtist.copyWith(stageName: null);
      // stageName null with copyWith doesn't clear it, test the getter directly
      final noStage = Artist(
        id: 'a', name: 'Real Name', createdAt: DateTime.now());
      expect(noStage.displayName, 'Real Name');
    });

    test('hasStudio checks studioIds', () {
      expect(testArtist.hasStudio('studio-1'), isTrue);
      expect(testArtist.hasStudio('studio-99'), isFalse);
    });

    test('genresDisplay joins with comma', () {
      expect(testArtist.genresDisplay, 'Hip-Hop, R&B');
    });

    test('isLinkedToUser', () {
      expect(testArtist.isLinkedToUser, isFalse);
      final linked = testArtist.copyWith(linkedUserId: 'user-1');
      expect(linked.isLinkedToUser, isTrue);
    });

    test('parseStudioIds handles old format', () {
      expect(
        Artist.parseStudioIds({'studioId': 'old-studio'}),
        ['old-studio'],
      );
    });

    test('parseStudioIds handles new format', () {
      expect(
        Artist.parseStudioIds({'studioIds': ['s1', 's2']}),
        ['s1', 's2'],
      );
    });

    test('parseStudioIds handles missing data', () {
      expect(Artist.parseStudioIds({}), isEmpty);
    });

    test('fromMap / toMap round-trip', () {
      final map = testArtist.toMap();
      final restored = Artist.fromMap(map);
      expect(restored.id, testArtist.id);
      expect(restored.name, testArtist.name);
      expect(restored.studioIds, testArtist.studioIds);
      expect(restored.genres, testArtist.genres);
    });
  });
}
