import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:useme/core/blocs/artist/artist_event.dart';
import 'package:useme/core/blocs/artist/artist_state.dart';
import 'package:useme/core/services/services_exports.dart';

/// Artist BLoC - Manages artist state
class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final ArtistService _artistService = ArtistService();

  ArtistBloc() : super(const ArtistInitialState()) {
    on<LoadArtistsEvent>(_onLoadArtists);
    on<SearchArtistsEvent>(_onSearchArtists);
    on<CreateArtistEvent>(_onCreateArtist);
    on<UpdateArtistEvent>(_onUpdateArtist);
    on<DeleteArtistEvent>(_onDeleteArtist);
    on<LoadArtistByIdEvent>(_onLoadArtistById);
    on<ClearArtistsEvent>(_onClearArtists);
  }

  void _onClearArtists(ClearArtistsEvent event, Emitter<ArtistState> emit) {
    emit(const ArtistInitialState());
  }

  Future<void> _onLoadArtists(
      LoadArtistsEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoadingState(artists: state.artists));
    try {
      final artists = await _artistService.getArtistsByStudioId(event.studioId);
      emit(ArtistsLoadedState(artists: artists));
    } catch (e) {
      emit(ArtistErrorState(
        errorMessage: 'Erreur lors du chargement: $e',
        artists: state.artists,
      ));
    }
  }

  Future<void> _onSearchArtists(
      SearchArtistsEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoadingState(artists: state.artists));
    try {
      final artists =
          await _artistService.searchArtists(event.studioId, event.query);
      emit(ArtistsLoadedState(artists: artists));
    } catch (e) {
      emit(ArtistErrorState(
        errorMessage: 'Erreur lors de la recherche: $e',
        artists: state.artists,
      ));
    }
  }

  Future<void> _onCreateArtist(
      CreateArtistEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoadingState(artists: state.artists));
    try {
      final artist = event.artist;
      final studioId = artist.studioIds.isNotEmpty ? artist.studioIds.first : '';
      final response = await _artistService.createArtist(studioId, artist);
      if (response.code == 200) {
        final artists = await _artistService.getArtistsByStudioId(studioId);
        emit(ArtistCreatedState(createdArtist: artist, artists: artists));
      } else {
        emit(ArtistErrorState(
          errorMessage: response.message,
          artists: state.artists,
        ));
      }
    } catch (e) {
      emit(ArtistErrorState(
        errorMessage: 'Erreur lors de la création: $e',
        artists: state.artists,
      ));
    }
  }

  Future<void> _onUpdateArtist(
      UpdateArtistEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoadingState(artists: state.artists));
    try {
      final artist = event.artist;
      await _artistService.updateArtist(artist.id, artist.toMap());
      final updatedArtists = state.artists.map((a) {
        return a.id == artist.id ? artist : a;
      }).toList();
      emit(ArtistUpdatedState(
        updatedArtist: artist,
        artists: updatedArtists,
      ));
    } catch (e) {
      emit(ArtistErrorState(
        errorMessage: 'Erreur lors de la mise à jour: $e',
        artists: state.artists,
      ));
    }
  }

  Future<void> _onDeleteArtist(
      DeleteArtistEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoadingState(artists: state.artists));
    try {
      final response = await _artistService.deleteArtist(event.artistId);
      if (response.code == 200) {
        final updatedArtists =
            state.artists.where((a) => a.id != event.artistId).toList();
        emit(ArtistDeletedState(
          deletedArtistId: event.artistId,
          artists: updatedArtists,
        ));
      } else {
        emit(ArtistErrorState(
          errorMessage: response.message,
          artists: state.artists,
        ));
      }
    } catch (e) {
      emit(ArtistErrorState(
        errorMessage: 'Erreur lors de la suppression: $e',
        artists: state.artists,
      ));
    }
  }

  Future<void> _onLoadArtistById(
      LoadArtistByIdEvent event, Emitter<ArtistState> emit) async {
    emit(ArtistLoadingState(artists: state.artists));
    try {
      final artist = await _artistService.getArtistById(event.artistId);
      if (artist != null) {
        emit(ArtistDetailLoadedState(
          selectedArtist: artist,
          artists: state.artists,
        ));
      } else {
        emit(ArtistErrorState(
          errorMessage: 'Artiste introuvable',
          artists: state.artists,
        ));
      }
    } catch (e) {
      emit(ArtistErrorState(
        errorMessage: 'Erreur lors du chargement: $e',
        artists: state.artists,
      ));
    }
  }
}
