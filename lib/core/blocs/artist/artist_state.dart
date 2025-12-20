import 'package:equatable/equatable.dart';
import 'package:useme/core/models/models_exports.dart';

/// Base artist state
class ArtistState extends Equatable {
  final List<Artist> artists;
  final Artist? selectedArtist;
  final bool isLoading;
  final String? errorMessage;

  const ArtistState({
    this.artists = const [],
    this.selectedArtist,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [artists, selectedArtist, isLoading, errorMessage];

  ArtistState copyWith({
    List<Artist>? artists,
    Artist? selectedArtist,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ArtistState(
      artists: artists ?? this.artists,
      selectedArtist: selectedArtist ?? this.selectedArtist,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Initial state
class ArtistInitialState extends ArtistState {
  const ArtistInitialState() : super();
}

/// Loading state
class ArtistLoadingState extends ArtistState {
  const ArtistLoadingState({super.artists, super.selectedArtist})
      : super(isLoading: true);
}

/// Artists loaded successfully
class ArtistsLoadedState extends ArtistState {
  const ArtistsLoadedState({required super.artists}) : super(isLoading: false);
}

/// Single artist loaded
class ArtistDetailLoadedState extends ArtistState {
  const ArtistDetailLoadedState({
    required super.selectedArtist,
    super.artists,
  }) : super(isLoading: false);
}

/// Artist created successfully
class ArtistCreatedState extends ArtistState {
  final Artist createdArtist;

  const ArtistCreatedState({
    required this.createdArtist,
    required super.artists,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [createdArtist, artists, isLoading];
}

/// Artist updated successfully
class ArtistUpdatedState extends ArtistState {
  final Artist updatedArtist;

  const ArtistUpdatedState({
    required this.updatedArtist,
    required super.artists,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [updatedArtist, artists, isLoading];
}

/// Artist deleted successfully
class ArtistDeletedState extends ArtistState {
  final String deletedArtistId;

  const ArtistDeletedState({
    required this.deletedArtistId,
    required super.artists,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [deletedArtistId, artists, isLoading];
}

/// Error state
class ArtistErrorState extends ArtistState {
  const ArtistErrorState({
    required super.errorMessage,
    super.artists,
    super.selectedArtist,
  }) : super(isLoading: false);
}
