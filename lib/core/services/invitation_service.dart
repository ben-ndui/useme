import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:useme/core/models/studio_invitation.dart';
import 'package:useme/core/models/artist.dart';
import 'package:useme/core/models/app_user.dart';

/// Service pour gérer les invitations studio → artiste
class InvitationService {
  final FirebaseFirestore _firestore;
  static const String _invitationsCollection = 'studio_invitations';
  static const String _usersCollection = 'users';
  static const String _artistsCollection = 'useme_artists';

  InvitationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ===========================================================================
  // RECHERCHE D'UTILISATEURS EXISTANTS
  // ===========================================================================

  /// Recherche des utilisateurs artistes par email
  Future<List<AppUser>> searchArtistsByEmail(String email) async {
    if (email.isEmpty || email.length < 3) return [];

    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isGreaterThanOrEqualTo: email.toLowerCase())
        .where('email', isLessThanOrEqualTo: '${email.toLowerCase()}\uf8ff')
        .where('role', isEqualTo: 'artist')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AppUser.fromMap(data);
    }).toList();
  }

  /// Recherche des utilisateurs artistes par nom
  Future<List<AppUser>> searchArtistsByName(String name) async {
    if (name.isEmpty || name.length < 2) return [];

    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('role', isEqualTo: 'artist')
        .limit(50)
        .get();

    final lowerName = name.toLowerCase();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return AppUser.fromMap(data);
        })
        .where((user) {
          final name = (user.displayName ?? user.email).toLowerCase();
          final email = user.email.toLowerCase();
          return name.contains(lowerName) || email.contains(lowerName);
        })
        .take(10)
        .toList();
  }

  /// Vérifie si un utilisateur est déjà lié à ce studio
  Future<bool> isUserLinkedToStudio(String userId, String studioId) async {
    final snapshot = await _firestore
        .collection(_artistsCollection)
        .where('linkedUserId', isEqualTo: userId)
        .where('studioIds', arrayContains: studioId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // ===========================================================================
  // GESTION DES INVITATIONS
  // ===========================================================================

  /// Crée une invitation pour un artiste
  Future<StudioInvitation> createInvitation({
    required String studioId,
    required String studioName,
    required String email,
    String? phone,
    String? artistId,
  }) async {
    // Vérifier s'il y a déjà une invitation pending pour cet email
    final existingInvite = await _findPendingInvitation(email, studioId);
    if (existingInvite != null) {
      return existingInvite;
    }

    final docRef = _firestore.collection(_invitationsCollection).doc();
    final invitation = StudioInvitation(
      id: docRef.id,
      studioId: studioId,
      studioName: studioName,
      artistId: artistId,
      email: email.toLowerCase().trim(),
      phone: phone,
      code: StudioInvitation.generateCode(),
      status: InvitationStatus.pending,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );

    await docRef.set(invitation.toMap());
    return invitation;
  }

  /// Trouve une invitation pending existante
  Future<StudioInvitation?> _findPendingInvitation(String email, String studioId) async {
    final snapshot = await _firestore
        .collection(_invitationsCollection)
        .where('email', isEqualTo: email.toLowerCase().trim())
        .where('studioId', isEqualTo: studioId)
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return StudioInvitation.fromMap(snapshot.docs.first.data());
  }

  /// Valide un code d'invitation
  Future<StudioInvitation?> validateCode(String code) async {
    final snapshot = await _firestore
        .collection(_invitationsCollection)
        .where('code', isEqualTo: code.toUpperCase().trim())
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final invitation = StudioInvitation.fromMap(snapshot.docs.first.data());
    if (invitation.isExpired) return null;

    return invitation;
  }

  /// Accepte une invitation et lie l'artiste au studio
  Future<void> acceptInvitation({
    required String invitationId,
    required String userId,
  }) async {
    final inviteDoc = await _firestore.collection(_invitationsCollection).doc(invitationId).get();
    if (!inviteDoc.exists) throw Exception('Invitation non trouvée');

    final invitation = StudioInvitation.fromMap(inviteDoc.data()!);

    // Mettre à jour l'invitation
    await _firestore.collection(_invitationsCollection).doc(invitationId).update({
      'status': InvitationStatus.accepted.name,
      'acceptedByUserId': userId,
      'acceptedAt': DateTime.now().millisecondsSinceEpoch,
    });

    // Lier l'artiste au studio
    await _linkUserToStudio(
      userId: userId,
      studioId: invitation.studioId,
      artistId: invitation.artistId,
    );
  }

  /// Lie un utilisateur à un studio (via fiche artiste)
  Future<void> _linkUserToStudio({
    required String userId,
    required String studioId,
    String? artistId,
  }) async {
    if (artistId != null) {
      // Mettre à jour la fiche artiste existante
      await _firestore.collection(_artistsCollection).doc(artistId).update({
        'linkedUserId': userId,
        'studioIds': FieldValue.arrayUnion([studioId]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      // Chercher si une fiche existe déjà pour cet utilisateur
      final existingArtist = await _findArtistByUserId(userId);

      if (existingArtist != null) {
        // Ajouter le studio à la fiche existante
        await _firestore.collection(_artistsCollection).doc(existingArtist.id).update({
          'studioIds': FieldValue.arrayUnion([studioId]),
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        // Créer une nouvelle fiche artiste liée
        final userDoc = await _firestore.collection(_usersCollection).doc(userId).get();
        final userData = userDoc.data() ?? {};

        final newArtist = Artist(
          id: '',
          studioIds: [studioId],
          name: userData['displayName']?.toString() ?? userData['email']?.toString() ?? 'Artiste',
          email: userData['email']?.toString(),
          phone: userData['phone']?.toString(),
          photoUrl: userData['photoUrl']?.toString(),
          linkedUserId: userId,
          createdAt: DateTime.now(),
        );

        await _firestore.collection(_artistsCollection).add(newArtist.toMap());
      }
    }
  }

  /// Trouve une fiche artiste par userId
  Future<Artist?> _findArtistByUserId(String userId) async {
    final snapshot = await _firestore
        .collection(_artistsCollection)
        .where('linkedUserId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    data['id'] = snapshot.docs.first.id;
    return Artist.fromMap(data);
  }

  /// Lie directement un utilisateur existant à un studio (sans invitation)
  Future<void> linkExistingUserToStudio({
    required String userId,
    required String studioId,
  }) async {
    await _linkUserToStudio(userId: userId, studioId: studioId);
  }

  // ===========================================================================
  // AUTO-LINK À L'INSCRIPTION
  // ===========================================================================

  /// Cherche des invitations pending pour un email (appelé à l'inscription)
  Future<List<StudioInvitation>> findPendingInvitationsForEmail(String email) async {
    final snapshot = await _firestore
        .collection(_invitationsCollection)
        .where('email', isEqualTo: email.toLowerCase().trim())
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .get();

    return snapshot.docs
        .map((doc) => StudioInvitation.fromMap(doc.data()))
        .where((inv) => !inv.isExpired)
        .toList();
  }

  /// Cherche des fiches artistes non liées avec le même email
  Future<List<Artist>> findUnlinkedArtistsWithEmail(String email) async {
    final snapshot = await _firestore
        .collection(_artistsCollection)
        .where('email', isEqualTo: email.toLowerCase().trim())
        .where('linkedUserId', isNull: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Artist.fromMap(data);
    }).toList();
  }

  /// Accepte automatiquement toutes les invitations pending pour un nouvel utilisateur
  Future<int> autoAcceptInvitationsForNewUser(String userId, String email) async {
    final invitations = await findPendingInvitationsForEmail(email);
    int accepted = 0;

    for (final invitation in invitations) {
      try {
        await acceptInvitation(invitationId: invitation.id, userId: userId);
        accepted++;
      } catch (e) {
        // Log l'erreur mais continue avec les autres invitations
        debugPrint('Erreur auto-accept invitation ${invitation.id}: $e');
      }
    }

    // Aussi lier les fiches artistes non liées avec le même email
    final unlinkedArtists = await findUnlinkedArtistsWithEmail(email);
    for (final artist in unlinkedArtists) {
      try {
        await _firestore.collection(_artistsCollection).doc(artist.id).update({
          'linkedUserId': userId,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      } catch (e) {
        debugPrint('Erreur auto-link artist ${artist.id}: $e');
      }
    }

    return accepted;
  }

  // ===========================================================================
  // STREAM & QUERIES
  // ===========================================================================

  /// Stream des invitations d'un studio
  Stream<List<StudioInvitation>> streamStudioInvitations(String studioId) {
    return _firestore
        .collection(_invitationsCollection)
        .where('studioId', isEqualTo: studioId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudioInvitation.fromMap(doc.data()))
            .toList());
  }

  /// Annule une invitation
  Future<void> cancelInvitation(String invitationId) async {
    await _firestore.collection(_invitationsCollection).doc(invitationId).update({
      'status': InvitationStatus.cancelled.name,
    });
  }

  /// Renvoie une invitation (nouveau code, nouvelle date d'expiration)
  Future<StudioInvitation> resendInvitation(String invitationId) async {
    final newCode = StudioInvitation.generateCode();
    final newExpiry = DateTime.now().add(const Duration(days: 30));

    await _firestore.collection(_invitationsCollection).doc(invitationId).update({
      'code': newCode,
      'expiresAt': newExpiry.millisecondsSinceEpoch,
      'status': InvitationStatus.pending.name,
    });

    final doc = await _firestore.collection(_invitationsCollection).doc(invitationId).get();
    return StudioInvitation.fromMap(doc.data()!);
  }
}
