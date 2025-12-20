import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // Éviter les rechargements inutiles
    if (_currentUserId == event.userId && state is FavoritesLoadedState) {
      return;
    }

    _currentUserId = event.userId;
    emit(FavoriteLoadingState(favorites: state.favorites));

    await _favoritesSubscription?.cancel();
    _favoritesSubscription = _favoriteService
        .streamFavorites(event.userId)
        .listen(
          (favorites) => add(FavoritesUpdatedEvent(favorites: favorites)),
          onError: (e) => add(const FavoritesUpdatedEvent(favorites: [])),
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
    emit(FavoritesLoadedState(favorites: event.favorites));
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    final result = await _favoriteService.toggleFavorite(
      userId: event.userId,
      targetId: event.targetId,
      type: event.type,
      targetName: event.targetName,
      targetPhotoUrl: event.targetPhotoUrl,
      targetAddress: event.targetAddress,
    );

    if (result.isSuccess && result.data != null) {
      emit(FavoriteToggledState(
        targetId: event.targetId,
        isNowFavorite: result.data!,
        favorites: state.favorites,
      ));
    } else {
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

  void _onClear(
    ClearFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) {
    _favoritesSubscription?.cancel();
    _currentUserId = null;
    emit(const FavoriteInitialState());
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
