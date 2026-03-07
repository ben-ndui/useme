import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/user_contact.dart';

/// Service for managing the user's professional network.
class NetworkService {
  final FirebaseFirestore _firestore;
  static const String _contactsCollection = 'user_contacts';
  static const String _invitationsCollection = 'user_invitations';
  static const String _usersCollection = 'users';

  NetworkService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream all contacts for a user.
  Stream<List<UserContact>> streamContacts(String ownerId) {
    return _firestore
        .collection(_contactsCollection)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((s) {
      final contacts =
          s.docs.map((d) => UserContact.fromMap(d.data(), d.id)).toList();
      contacts.sort((a, b) => a.contactName.compareTo(b.contactName));
      return contacts;
    });
  }

  /// Add a platform user as a contact.
  Future<SmoothResponse<UserContact>> addContact({
    required String ownerId,
    required AppUser user,
    required ContactCategory category,
    String? note,
    List<String> tags = const [],
  }) async {
    try {
      final existing = await _firestore
          .collection(_contactsCollection)
          .where('ownerId', isEqualTo: ownerId)
          .where('contactUserId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return SmoothResponse.error(message: 'Contact already in network');
      }

      final data = UserContact(
        id: '',
        ownerId: ownerId,
        contactUserId: user.uid,
        contactName: user.displayName ?? user.name ?? user.email,
        contactEmail: user.email,
        contactPhone: user.phoneNumber,
        contactPhotoUrl: user.photoURL,
        category: category,
        note: note,
        tags: tags,
        isOnPlatform: true,
        createdAt: DateTime.now(),
      ).toMap();

      final docRef =
          await _firestore.collection(_contactsCollection).add(data);
      return SmoothResponse.success(
        data: UserContact.fromMap(data, docRef.id),
      );
    } catch (e) {
      return SmoothResponse.error(message: 'Error adding contact: $e');
    }
  }

  /// Add an off-platform contact (manual entry).
  Future<SmoothResponse<UserContact>> addOffPlatformContact({
    required String ownerId,
    required String name,
    String? email,
    String? phone,
    required ContactCategory category,
    String? note,
    List<String> tags = const [],
  }) async {
    try {
      final data = UserContact(
        id: '',
        ownerId: ownerId,
        contactName: name,
        contactEmail: email,
        contactPhone: phone,
        category: category,
        note: note,
        tags: tags,
        isOnPlatform: false,
        createdAt: DateTime.now(),
      ).toMap();

      final docRef =
          await _firestore.collection(_contactsCollection).add(data);
      return SmoothResponse.success(
        data: UserContact.fromMap(data, docRef.id),
      );
    } catch (e) {
      return SmoothResponse.error(message: 'Error adding contact: $e');
    }
  }

  /// Update a contact's details.
  Future<SmoothResponse<void>> updateContact(UserContact contact) async {
    try {
      await _firestore
          .collection(_contactsCollection)
          .doc(contact.id)
          .update(contact.toMap());
      return SmoothResponse.success();
    } catch (e) {
      return SmoothResponse.error(message: 'Error updating contact: $e');
    }
  }

  /// Remove a contact.
  Future<SmoothResponse<void>> removeContact(String contactId) async {
    try {
      await _firestore
          .collection(_contactsCollection)
          .doc(contactId)
          .delete();
      return SmoothResponse.success();
    } catch (e) {
      return SmoothResponse.error(message: 'Error removing contact: $e');
    }
  }

  /// Search platform users by name or email.
  Future<List<AppUser>> searchUsers(String query) async {
    if (query.length < 2) return [];

    try {
      if (query.contains('@')) {
        return _searchByEmail(query);
      }
      return _searchByName(query);
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  Future<List<AppUser>> _searchByEmail(String email) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isGreaterThanOrEqualTo: email.toLowerCase())
        .where('email', isLessThanOrEqualTo: '${email.toLowerCase()}\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AppUser.fromMap(data, doc.id);
    }).toList();
  }

  Future<List<AppUser>> _searchByName(String name) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .limit(50)
        .get();

    final lowerName = name.toLowerCase();
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .where((user) {
      final userName =
          (user.displayName ?? user.name ?? user.email).toLowerCase();
      return userName.contains(lowerName);
    })
        .take(10)
        .toList();
  }

  /// Track an invitation sent to an off-platform user.
  Future<SmoothResponse<void>> trackInvitation({
    required String senderId,
    required String contactId,
    required String method,
    String? email,
    String? phone,
  }) async {
    try {
      await _firestore.collection(_invitationsCollection).add({
        'senderId': senderId,
        'contactId': contactId,
        'method': method,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'sentAt': DateTime.now().toIso8601String(),
      });
      return SmoothResponse.success();
    } catch (e) {
      return SmoothResponse.error(message: 'Error tracking invitation: $e');
    }
  }
}
