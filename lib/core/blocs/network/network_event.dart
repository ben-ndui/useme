import 'package:equatable/equatable.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/user_contact.dart';

abstract class NetworkEvent extends Equatable {
  const NetworkEvent();

  @override
  List<Object?> get props => [];
}

/// Load all contacts for the current user.
class LoadContactsEvent extends NetworkEvent {
  final String userId;

  const LoadContactsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Add a platform user to the network.
class AddPlatformContactEvent extends NetworkEvent {
  final String userId;
  final AppUser contact;
  final ContactCategory category;
  final String? note;
  final List<String> tags;

  const AddPlatformContactEvent({
    required this.userId,
    required this.contact,
    required this.category,
    this.note,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [userId, contact, category];
}

/// Add an off-platform contact manually.
class AddOffPlatformContactEvent extends NetworkEvent {
  final String userId;
  final String name;
  final String? email;
  final String? phone;
  final ContactCategory category;
  final String? note;
  final List<String> tags;

  const AddOffPlatformContactEvent({
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    required this.category,
    this.note,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [userId, name, category];
}

/// Update a contact's details.
class UpdateContactEvent extends NetworkEvent {
  final UserContact contact;

  const UpdateContactEvent({required this.contact});

  @override
  List<Object?> get props => [contact];
}

/// Remove a contact from the network.
class RemoveContactEvent extends NetworkEvent {
  final String contactId;

  const RemoveContactEvent({required this.contactId});

  @override
  List<Object?> get props => [contactId];
}

/// Search users on the platform.
class SearchUsersEvent extends NetworkEvent {
  final String query;

  const SearchUsersEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Internal event when contacts stream updates.
class ContactsUpdatedEvent extends NetworkEvent {
  final List<UserContact> contacts;

  const ContactsUpdatedEvent({required this.contacts});

  @override
  List<Object?> get props => [contacts];
}

/// Clear network state (logout).
class ClearNetworkEvent extends NetworkEvent {
  const ClearNetworkEvent();
}
