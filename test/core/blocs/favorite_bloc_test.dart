import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:uzme/core/blocs/favorite/favorite_bloc.dart';
import 'package:uzme/core/blocs/favorite/favorite_event.dart';
import 'package:uzme/core/blocs/favorite/favorite_state.dart';
import 'package:uzme/core/models/favorite.dart';

import '../../helpers/mock_services.dart';

void main() {
  late MockFavoriteService mockFavoriteService;

  final testFavorite = Favorite(
    id: 'fav-1',
    userId: 'user-1',
    targetId: 'studio-1',
    type: FavoriteType.studio,
    createdAt: DateTime(2026, 3, 1),
    targetName: 'Cool Studio',
  );

  setUp(() {
    mockFavoriteService = MockFavoriteService();
  });

  FavoriteBloc buildBloc() =>
      FavoriteBloc(favoriteService: mockFavoriteService);

  group('LoadFavoritesEvent', () {
    blocTest<FavoriteBloc, FavoriteState>(
      'emits [loading] then receives stream updates',
      build: () {
        when(() => mockFavoriteService.streamFavorites('user-1'))
            .thenAnswer((_) => Stream.value([testFavorite]));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadFavoritesEvent(userId: 'user-1')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<FavoriteLoadingState>(),
        isA<FavoritesLoadedState>()
            .having((s) => s.favorites.length, 'count', 1)
            .having((s) => s.favorites.first.targetId, 'id', 'studio-1'),
      ],
    );

    blocTest<FavoriteBloc, FavoriteState>(
      'skips reload if same user already loaded',
      build: () {
        when(() => mockFavoriteService.streamFavorites('user-1'))
            .thenAnswer((_) => Stream.value([testFavorite]));
        return buildBloc();
      },
      seed: () => FavoritesLoadedState(favorites: [testFavorite]),
      act: (bloc) {
        // Simulate that _currentUserId is already set by loading first
        bloc.add(const LoadFavoritesEvent(userId: 'user-1'));
        // Wait for stream, then try to reload
        Future.delayed(const Duration(milliseconds: 50), () {
          bloc.add(const LoadFavoritesEvent(userId: 'user-1'));
        });
      },
      wait: const Duration(milliseconds: 200),
      expect: () => [
        // First load triggers loading + loaded
        isA<FavoriteLoadingState>(),
        isA<FavoritesLoadedState>(),
        // Second load is skipped (already loaded for same user)
      ],
    );
  });

  group('ToggleFavoriteEvent', () {
    blocTest<FavoriteBloc, FavoriteState>(
      'emits toggled state when adding favorite',
      build: () {
        when(() => mockFavoriteService.toggleFavorite(
              userId: 'user-1',
              targetId: 'studio-2',
              type: FavoriteType.studio,
              targetName: 'New Studio',
              targetPhotoUrl: null,
              targetAddress: null,
            )).thenAnswer((_) async => const SmoothResponse(
              code: 200,
              message: 'OK',
              data: true,
            ));
        return buildBloc();
      },
      seed: () => FavoritesLoadedState(favorites: [testFavorite]),
      act: (bloc) => bloc.add(const ToggleFavoriteEvent(
        userId: 'user-1',
        targetId: 'studio-2',
        type: FavoriteType.studio,
        targetName: 'New Studio',
      )),
      expect: () => [
        isA<FavoriteToggledState>()
            .having((s) => s.isNowFavorite, 'added', isTrue)
            .having((s) => s.favorites.length, 'count', 2),
      ],
    );

    blocTest<FavoriteBloc, FavoriteState>(
      'emits toggled state when removing favorite',
      build: () {
        when(() => mockFavoriteService.toggleFavorite(
              userId: 'user-1',
              targetId: 'studio-1',
              type: FavoriteType.studio,
              targetName: 'Cool Studio',
              targetPhotoUrl: null,
              targetAddress: null,
            )).thenAnswer((_) async => const SmoothResponse(
              code: 200,
              message: 'OK',
              data: false,
            ));
        return buildBloc();
      },
      seed: () => FavoritesLoadedState(favorites: [testFavorite]),
      act: (bloc) => bloc.add(const ToggleFavoriteEvent(
        userId: 'user-1',
        targetId: 'studio-1',
        type: FavoriteType.studio,
        targetName: 'Cool Studio',
      )),
      expect: () => [
        isA<FavoriteToggledState>()
            .having((s) => s.isNowFavorite, 'removed', isFalse)
            .having((s) => s.favorites, 'empty', isEmpty),
      ],
    );

    blocTest<FavoriteBloc, FavoriteState>(
      'emits error when toggle fails',
      build: () {
        when(() => mockFavoriteService.toggleFavorite(
              userId: 'user-1',
              targetId: 'studio-1',
              type: FavoriteType.studio,
              targetName: null,
              targetPhotoUrl: null,
              targetAddress: null,
            )).thenAnswer((_) async => const SmoothResponse(
              code: 500,
              message: 'Error',
            ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ToggleFavoriteEvent(
        userId: 'user-1',
        targetId: 'studio-1',
        type: FavoriteType.studio,
      )),
      expect: () => [
        isA<FavoriteErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Error'),
      ],
    );
  });

  group('RemoveFavoriteEvent', () {
    blocTest<FavoriteBloc, FavoriteState>(
      'emits error when remove fails',
      build: () {
        when(() => mockFavoriteService.removeFavorite('fav-1'))
            .thenAnswer((_) async => const SmoothResponse(
                  code: 500,
                  message: 'Delete failed',
                ));
        return buildBloc();
      },
      seed: () => FavoritesLoadedState(favorites: [testFavorite]),
      act: (bloc) =>
          bloc.add(const RemoveFavoriteEvent(favoriteId: 'fav-1')),
      expect: () => [
        isA<FavoriteErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Delete failed'),
      ],
    );
  });

  group('ClearFavoritesEvent', () {
    blocTest<FavoriteBloc, FavoriteState>(
      'resets to initial state',
      build: buildBloc,
      seed: () => FavoritesLoadedState(favorites: [testFavorite]),
      act: (bloc) => bloc.add(const ClearFavoritesEvent()),
      expect: () => [isA<FavoriteInitialState>()],
    );
  });

  group('FavoriteState helpers', () {
    test('isFavorite checks targetId', () {
      final state = FavoritesLoadedState(favorites: [testFavorite]);
      expect(state.isFavorite('studio-1'), isTrue);
      expect(state.isFavorite('studio-999'), isFalse);
    });

    test('getFavoritesByType filters correctly', () {
      final engineerFav = Favorite(
        id: 'fav-2',
        userId: 'user-1',
        targetId: 'eng-1',
        type: FavoriteType.engineer,
        createdAt: DateTime(2026, 3, 1),
      );
      final state = FavoritesLoadedState(
        favorites: [testFavorite, engineerFav],
      );
      expect(state.getFavoritesByType(FavoriteType.studio).length, 1);
      expect(state.getFavoritesByType(FavoriteType.engineer).length, 1);
      expect(state.studioCount, 1);
      expect(state.engineerCount, 1);
    });
  });
}
