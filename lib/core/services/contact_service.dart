import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:useme/core/models/app_user.dart';

/// Service pour récupérer les contacts disponibles pour la messagerie.
class ContactService {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  ContactService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Récupère les contacts selon le rôle de l'utilisateur.
  Future<List<AppUser>> getContacts(AppUser currentUser) async {
    debugPrint('🔍 ContactService.getContacts - role: ${currentUser.role}, uid: ${currentUser.uid}');
    debugPrint('🔍 isStudio: ${currentUser.isStudio}, isEngineer: ${currentUser.isEngineer}, isArtist: ${currentUser.isArtist}');

    List<AppUser> contacts;
    if (currentUser.isStudio) {
      contacts = await _getStudioContacts(currentUser);
    } else if (currentUser.isEngineer) {
      contacts = await _getEngineerContacts(currentUser);
    } else if (currentUser.isArtist) {
      contacts = await _getArtistContacts(currentUser);
    } else {
      debugPrint('⚠️ Unknown role, returning empty contacts');
      contacts = [];
    }

    debugPrint('✅ Found ${contacts.length} contacts');
    return contacts;
  }

  /// Contacts pour un Studio: ses ingénieurs + artistes liés.
  Future<List<AppUser>> _getStudioContacts(AppUser studio) async {
    try {
      final contacts = <AppUser>[];

      // 1. Récupérer les ingénieurs de l'équipe
      final engineersSnapshot = await _firestore
          .collection(_usersCollection)
          .where('studioId', isEqualTo: studio.uid)
          .where('role', isEqualTo: 'worker')
          .get()
          .timeout(const Duration(seconds: 10));

      for (final doc in engineersSnapshot.docs) {
        final data = doc.data();
        data['uid'] = doc.id;
        contacts.add(AppUser.fromMap(data));
      }

      // 2. Récupérer les artistes liés au studio
      final artistsSnapshot = await _firestore
          .collection(_usersCollection)
          .where('studioIds', arrayContains: studio.uid)
          .where('role', isEqualTo: 'client')
          .get()
          .timeout(const Duration(seconds: 10));

      for (final doc in artistsSnapshot.docs) {
        final data = doc.data();
        data['uid'] = doc.id;
        contacts.add(AppUser.fromMap(data));
      }

      return contacts;
    } catch (e) {
      debugPrint('❌ ContactService._getStudioContacts error: $e');
      return [];
    }
  }

  /// Contacts pour un Ingénieur: son studio + artistes des sessions.
  Future<List<AppUser>> _getEngineerContacts(AppUser engineer) async {
    try {
      final contacts = <AppUser>[];

      if (engineer.studioId != null) {
        // 1. Récupérer le studio
        final studioDoc = await _firestore
            .collection(_usersCollection)
            .doc(engineer.studioId)
            .get()
            .timeout(const Duration(seconds: 10));

        if (studioDoc.exists) {
          final data = studioDoc.data()!;
          data['uid'] = studioDoc.id;
          contacts.add(AppUser.fromMap(data));
        }

        // 2. Récupérer les artistes liés au même studio
        final artistsSnapshot = await _firestore
            .collection(_usersCollection)
            .where('studioIds', arrayContains: engineer.studioId)
            .where('role', isEqualTo: 'client')
            .get()
            .timeout(const Duration(seconds: 10));

        for (final doc in artistsSnapshot.docs) {
          final data = doc.data();
          data['uid'] = doc.id;
          contacts.add(AppUser.fromMap(data));
        }
      }

      return contacts;
    } catch (e) {
      debugPrint('❌ ContactService._getEngineerContacts error: $e');
      return [];
    }
  }

  /// Contacts pour un Artiste: ses studios.
  Future<List<AppUser>> _getArtistContacts(AppUser artist) async {
    try {
      final contacts = <AppUser>[];

      if (artist.studioIds.isEmpty) return contacts;

      // Récupérer les studios liés
      for (final studioId in artist.studioIds) {
        final studioDoc = await _firestore
            .collection(_usersCollection)
            .doc(studioId)
            .get()
            .timeout(const Duration(seconds: 10));

        if (studioDoc.exists) {
          final data = studioDoc.data()!;
          data['uid'] = studioDoc.id;
          contacts.add(AppUser.fromMap(data));
        }
      }

      return contacts;
    } catch (e) {
      debugPrint('❌ ContactService._getArtistContacts error: $e');
      return [];
    }
  }

  /// Recherche dans les contacts.
  List<AppUser> searchContacts(List<AppUser> contacts, String query) {
    if (query.isEmpty) return contacts;
    final searchLower = query.toLowerCase();
    return contacts.where((user) {
      final name = user.displayName?.toLowerCase() ?? '';
      final stageName = user.stageName?.toLowerCase() ?? '';
      final email = user.email.toLowerCase();
      return name.contains(searchLower) ||
          stageName.contains(searchLower) ||
          email.contains(searchLower);
    }).toList();
  }

  /// Recherche globale d'utilisateurs par nom/email.
  Future<List<AppUser>> searchAllUsers(String query, String currentUserId) async {
    if (query.length < 2) return [];

    try {
      final queryLower = query.toLowerCase();

      // Recherche par displayName
      final byNameSnapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('displayName')
          .startAt([queryLower])
          .endAt(['$queryLower\uf8ff'])
          .limit(20)
          .get()
          .timeout(const Duration(seconds: 10));

      final results = <String, AppUser>{};

      for (final doc in byNameSnapshot.docs) {
        if (doc.id != currentUserId) {
          final data = doc.data();
          data['uid'] = doc.id;
          results[doc.id] = AppUser.fromMap(data);
        }
      }

      // Recherche par email
      final byEmailSnapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('email')
          .startAt([queryLower])
          .endAt(['$queryLower\uf8ff'])
          .limit(20)
          .get()
          .timeout(const Duration(seconds: 10));

      for (final doc in byEmailSnapshot.docs) {
        if (doc.id != currentUserId && !results.containsKey(doc.id)) {
          final data = doc.data();
          data['uid'] = doc.id;
          results[doc.id] = AppUser.fromMap(data);
        }
      }

      debugPrint('🔍 searchAllUsers("$query") found ${results.length} users');
      return results.values.toList();
    } catch (e) {
      debugPrint('❌ searchAllUsers error: $e');
      return [];
    }
  }
}
