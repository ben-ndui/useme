import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzme/core/services/network_service.dart';

import 'network_event.dart';
import 'network_state.dart';

/// BLoC for managing the user's professional network.
class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NetworkService _networkService;
  StreamSubscription? _contactsSubscription;

  NetworkBloc({NetworkService? networkService})
      : _networkService = networkService ?? NetworkService(),
        super(const NetworkState()) {
    on<LoadContactsEvent>(_onLoadContacts);
    on<AddPlatformContactEvent>(_onAddPlatformContact);
    on<AddOffPlatformContactEvent>(_onAddOffPlatformContact);
    on<UpdateContactEvent>(_onUpdateContact);
    on<RemoveContactEvent>(_onRemoveContact);
    on<SearchUsersEvent>(_onSearchUsers);
    on<ContactsUpdatedEvent>(_onContactsUpdated);
    on<ClearNetworkEvent>(_onClear);
  }

  Future<void> _onLoadContacts(
    LoadContactsEvent event,
    Emitter<NetworkState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    await _contactsSubscription?.cancel();
    _contactsSubscription = _networkService
        .streamContacts(event.userId)
        .listen(
          (contacts) => add(ContactsUpdatedEvent(contacts: contacts)),
          onError: (e) => add(const ContactsUpdatedEvent(contacts: [])),
        );
  }

  void _onContactsUpdated(
    ContactsUpdatedEvent event,
    Emitter<NetworkState> emit,
  ) {
    emit(state.copyWith(contacts: event.contacts, isLoading: false));
  }

  Future<void> _onAddPlatformContact(
    AddPlatformContactEvent event,
    Emitter<NetworkState> emit,
  ) async {
    final result = await _networkService.addContact(
      ownerId: event.userId,
      user: event.contact,
      category: event.category,
      note: event.note,
      tags: event.tags,
    );

    if (result.isSuccess) {
      emit(state.copyWith(successMessage: 'Contact added'));
    } else {
      emit(state.copyWith(errorMessage: result.message));
    }
  }

  Future<void> _onAddOffPlatformContact(
    AddOffPlatformContactEvent event,
    Emitter<NetworkState> emit,
  ) async {
    final result = await _networkService.addOffPlatformContact(
      ownerId: event.userId,
      name: event.name,
      email: event.email,
      phone: event.phone,
      category: event.category,
      note: event.note,
      tags: event.tags,
    );

    if (result.isSuccess) {
      emit(state.copyWith(successMessage: 'Contact added'));
    } else {
      emit(state.copyWith(errorMessage: result.message));
    }
  }

  Future<void> _onUpdateContact(
    UpdateContactEvent event,
    Emitter<NetworkState> emit,
  ) async {
    final result = await _networkService.updateContact(event.contact);

    if (!result.isSuccess) {
      emit(state.copyWith(errorMessage: result.message));
    }
  }

  Future<void> _onRemoveContact(
    RemoveContactEvent event,
    Emitter<NetworkState> emit,
  ) async {
    final result = await _networkService.removeContact(event.contactId);

    if (result.isSuccess) {
      emit(state.copyWith(successMessage: 'Contact removed'));
    } else {
      emit(state.copyWith(errorMessage: result.message));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<NetworkState> emit,
  ) async {
    if (event.query.length < 2) {
      emit(state.copyWith(searchResults: [], isSearching: false));
      return;
    }

    emit(state.copyWith(isSearching: true));

    final results = await _networkService.searchUsers(event.query);
    emit(state.copyWith(searchResults: results, isSearching: false));
  }

  Future<void> _onClear(
    ClearNetworkEvent event,
    Emitter<NetworkState> emit,
  ) async {
    await _contactsSubscription?.cancel();
    _contactsSubscription = null;
    emit(const NetworkState());
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    return super.close();
  }
}
