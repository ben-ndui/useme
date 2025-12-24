import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:useme/core/models/favorite.dart';
import 'package:useme/core/services/favorite_service.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

/// BLoC pour la gestion des favoris.
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteService _favoriteService;
  StreamSubscription? _favoritesSubscription;
  String? _currentUserId;

  FavoriteBloc({FavoriteService? favoriteService})
      : _favoriteService = favoriteService ?? FavoriteService(),
        super(const FavoriteInitialState()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<LoadFavoritesByTypeEvent>(_onLoadFavoritesByType);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<RemoveFavoriteEvent>(_onRemoveFavorite);
    on<FavoritesUpdatedEvent>(_onFavoritesUpdated);
    on<ClearFavoritesEvent>(_onClear);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    debugPrint('❤️ FavoriteBloc._onLoadFavorites called for userId: ${event.userId}');
    debugPrint('❤️ Current userId: $_currentUserId, state: ${state.runtimeType}');

    // Éviter les rechargements inutiles seulement si vraiment déjà chargé
    if (_currentUserId == event.userId && state is FavoritesLoadedState && state.favorites.isNotEmpty) {
      debugPrint('❤️ Skipping reload - already loaded with ${state.favorites.length} favorites');
      return;
    }

    _currentUserId = event.userId;
    emit(FavoriteLoadingState(favorites: state.favorites));

    await _favoritesSubscription?.cancel();
    _favoritesSubscription = _favoriteService
        .streamFavorites(event.userId)
        .listen(
          (favorites) {
            debugPrint('❤️ Stream emitted ${favorites.length} favorites');
            add(FavoritesUpdatedEvent(favorites: favorites));
          },
          onError: (e) {
            debugPrint('❤️ Stream error: $e');
            add(const FavoritesUpdatedEvent(favorites: []));
          },
        );
  }

  Future<void> _onLoadFavoritesByType(
    LoadFavoritesByTypeEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(FavoriteLoadingState(favorites: state.favorites));

    await _favoritesSubscription?.cancel();
    _favoritesSubscription = _favoriteService
        .streamFavoritesByType(event.userId, event.type)
        .listen(
          (favorites) => add(FavoritesUpdatedEvent(favorites: favorites)),
          onError: (e) => add(const FavoritesUpdatedEvent(favorites: [])),
        );
  }

  void _onFavoritesUpdated(
    FavoritesUpdatedEvent event,
    Emitter<FavoriteState> emit,
  ) {
    debugPrint('❤️ FavoriteBloc._onFavoritesUpdated with ${event.favorites.length} favorites');
    emit(FavoritesLoadedState(favorites: event.favorites));
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    debugPrint('❤️ FavoriteBloc._onToggleFavorite called');
    debugPrint('❤️ userId: ${event.userId}, targetId: ${event.targetId}, type: ${event.type}');

    final result = await _favoriteService.toggleFavorite(
      userId: event.userId,
      targetId: event.targetId,
      type: event.type,
      targetName: event.targetName,
      targetPhotoUrl: event.targetPhotoUrl,
      targetAddress: event.targetAddress,
    );

    debugPrint('❤️ Toggle result: isSuccess=${result.isSuccess}, data=${result.data}, message=${result.message}');

    if (result.isSuccess && result.data != null) {
      final isNowFavorite = result.data!;
      debugPrint('❤️ Emitting FavoriteToggledState - isNowFavorite: $isNowFavorite');

      // Mettre à jour la liste localement en attendant le stream
      List<Favorite> updatedFavorites;
      if (isNowFavorite) {
        // Ajouter à la liste locale
        final newFavorite = Favorite(
          id: '', // L'ID sera mis à jour par le stream
          userId: event.userId,
          targetId: event.targetId,
          type: event.type,
          createdAt: DateTime.now(),
          targetName: event.targetName,
          targetPhotoUrl: event.targetPhotoUrl,
          targetAddress: event.targetAddress,
        );
        updatedFavorites = [...state.favorites, newFavorite];
      } else {
        // Retirer de la liste locale
        updatedFavorites = state.favorites.where((f) => f.targetId != event.targetId).toList();
      }

      emit(FavoriteToggledState(
        targetId: event.targetId,
        isNowFavorite: isNowFavorite,
        favorites: updatedFavorites,
      ));
    } else {
      debugPrint('❤️ Emitting FavoriteErrorState - message: ${result.message}');
      emit(FavoriteErrorState(
        errorMessage: result.message,
        favorites: state.favorites,
      ));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    final result = await _favoriteService.removeFavorite(event.favoriteId);

    if (!result.isSuccess) {
      emit(FavoriteErrorState(
        errorMessage: result.message,
        favorites: state.favorites,
      ));
    }
  }

  Future<void> _onClear(
    ClearFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    debugPrint('❤️ FavoriteBloc._onClear called');
    await _favoritesSubscription?.cancel();
    _favoritesSubscription = null;
    _currentUserId = null;
    emit(const FavoriteInitialState());
    debugPrint('❤️ Favorites cleared, state reset to FavoriteInitialState');
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
