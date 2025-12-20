import 'package:equatable/equatable.dart';
import 'package:useme/core/models/models_exports.dart';

/// Base artist event
abstract class ArtistEvent extends Equatable {
  const ArtistEvent();

  @override
  List<Object?> get props => [];
}

/// Load all artists for a studio
class LoadArtistsEvent extends ArtistEvent {
  final String studioId;

  const LoadArtistsEvent({required this.studioId});

  @override
  List<Object?> get props => [studioId];
}

/// Search artists
class SearchArtistsEvent extends ArtistEvent {
  final String studioId;
  final String query;

  const SearchArtistsEvent({required this.studioId, required this.query});

  @override
  List<Object?> get props => [studioId, query];
}

/// Create new artist
class CreateArtistEvent extends ArtistEvent {
  final Artist artist;

  const CreateArtistEvent({required this.artist});

  @override
  List<Object?> get props => [artist];
}

/// Update existing artist
class UpdateArtistEvent extends ArtistEvent {
  final Artist artist;

  const UpdateArtistEvent({required this.artist});

  @override
  List<Object?> get props => [artist];
}

/// Delete artist
class DeleteArtistEvent extends ArtistEvent {
  final String artistId;

  const DeleteArtistEvent({required this.artistId});

  @override
  List<Object?> get props => [artistId];
}

/// Load single artist by ID
class LoadArtistByIdEvent extends ArtistEvent {
  final String artistId;

  const LoadArtistByIdEvent({required this.artistId});

  @override
  List<Object?> get props => [artistId];
}
