import 'package:equatable/equatable.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/pro_profile.dart';

class ProProfileState extends Equatable {
  final ProProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<AppUser> searchResults;
  final bool isSearching;

  const ProProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.searchResults = const [],
    this.isSearching = false,
  });

  bool get hasProfile => profile != null;
  bool get isActive => profile?.isAvailable ?? false;

  ProProfileState copyWith({
    ProProfile? profile,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<AppUser>? searchResults,
    bool? isSearching,
    bool clearProfile = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProProfileState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        searchResults,
        isSearching,
      ];
}
