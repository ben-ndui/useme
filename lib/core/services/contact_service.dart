import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:useme/core/models/app_user.dart';

/// Service pour récupérer les contacts disponibles pour la messagerie.
class ContactService {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  ContactService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Récupère les contacts selon le rôle de l'utilisateur.
  Future<List<AppUser>> getContacts(AppUser currentUser) async {
    if (currentUser.isStudio) {
      return _getStudioContacts(currentUser);
    } else if (currentUser.isEngineer) {
      return _getEngineerContacts(currentUser);
    } else if (currentUser.isArtist) {
      return _getArtistContacts(currentUser);
    }
    return [];
  }

  /// Contacts pour un Studio: ses ingénieurs + artistes liés.
  Future<List<AppUser>> _getStudioContacts(AppUser studio) async {
    final contacts = <AppUser>[];

    // 1. Récupérer les ingénieurs de l'équipe
    final engineersSnapshot = await _firestore
        .collection(_usersCollection)
        .where('studioId', isEqualTo: studio.uid)
        .where('role', isEqualTo: 'worker')
        .get();

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
        .get();

    for (final doc in artistsSnapshot.docs) {
      final data = doc.data();
      data['uid'] = doc.id;
      contacts.add(AppUser.fromMap(data));
    }

    return contacts;
  }

  /// Contacts pour un Ingénieur: son studio + artistes des sessions.
  Future<List<AppUser>> _getEngineerContacts(AppUser engineer) async {
    final contacts = <AppUser>[];

    if (engineer.studioId != null) {
      // 1. Récupérer le studio
      final studioDoc = await _firestore
          .collection(_usersCollection)
          .doc(engineer.studioId)
          .get();

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
          .get();

      for (final doc in artistsSnapshot.docs) {
        final data = doc.data();
        data['uid'] = doc.id;
        contacts.add(AppUser.fromMap(data));
      }
    }

    return contacts;
  }

  /// Contacts pour un Artiste: ses studios.
  Future<List<AppUser>> _getArtistContacts(AppUser artist) async {
    final contacts = <AppUser>[];

    if (artist.studioIds.isEmpty) return contacts;

    // Récupérer les studios liés
    for (final studioId in artist.studioIds) {
      final studioDoc = await _firestore
          .collection(_usersCollection)
          .doc(studioId)
          .get();

      if (studioDoc.exists) {
        final data = studioDoc.data()!;
        data['uid'] = studioDoc.id;
        contacts.add(AppUser.fromMap(data));
      }
    }

    return contacts;
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
}
