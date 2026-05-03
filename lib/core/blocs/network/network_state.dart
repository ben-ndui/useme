import 'package:equatable/equatable.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/user_contact.dart';

class NetworkState extends Equatable {
  final List<UserContact> contacts;
  final List<AppUser> searchResults;
  final bool isLoading;
  final bool isSearching;
  final String? errorMessage;
  final String? successMessage;

  const NetworkState({
    this.contacts = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.errorMessage,
    this.successMessage,
  });

  List<UserContact> getByCategory(ContactCategory category) {
    return contacts.where((c) => c.category == category).toList();
  }

  List<UserContact> get onPlatform =>
      contacts.where((c) => c.isOnPlatform).toList();

  List<UserContact> get offPlatform =>
      contacts.where((c) => !c.isOnPlatform).toList();

  NetworkState copyWith({
    List<UserContact>? contacts,
    List<AppUser>? searchResults,
    bool? isLoading,
    bool? isSearching,
    String? errorMessage,
    String? successMessage,
  }) {
    return NetworkState(
      contacts: contacts ?? this.contacts,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        contacts,
        searchResults,
        isLoading,
        isSearching,
        errorMessage,
        successMessage,
      ];
}
