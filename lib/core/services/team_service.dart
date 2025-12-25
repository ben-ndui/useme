import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/subscription_config_service.dart';

/// Service pour gérer l'équipe (ingénieurs) d'un studio
class TeamService {
  final FirebaseFirestore _firestore;
  final SubscriptionConfigService _subscriptionService;
  static const String _usersCollection = 'users';
  static const String _invitationsCollection = 'team_invitations';

  TeamService({
    FirebaseFirestore? firestore,
    SubscriptionConfigService? subscriptionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _subscriptionService = subscriptionService ?? SubscriptionConfigService();

  /// Stream des membres de l'équipe d'un studio
  Stream<List<AppUser>> streamTeamMembers(String studioId) {
    return _firestore
        .collection(_usersCollection)
        .where('studioId', isEqualTo: studioId)
        .where('role', isEqualTo: 'worker')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['uid'] = doc.id;
              return AppUser.fromMap(data);
            }).toList());
  }

  /// Récupérer les membres de l'équipe (one-time)
  Future<List<AppUser>> getTeamMembers(String studioId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('studioId', isEqualTo: studioId)
          .where('role', isEqualTo: 'worker')
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return AppUser.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('❌ TeamService.getTeamMembers error: $e');
      return [];
    }
  }

  /// Rechercher un utilisateur par email (pour l'ajouter à l'équipe)
  Future<AppUser?> findUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    data['uid'] = snapshot.docs.first.id;
    return AppUser.fromMap(data);
  }

  /// Ajouter un utilisateur existant à l'équipe du studio
  /// Si subscriptionTierId et currentEngineerCount sont fournis, vérifie les limites
  Future<SmoothResponse<bool>> addToTeam({
    required String userId,
    required String studioId,
    String? subscriptionTierId,
    int? currentEngineerCount,
  }) async {
    try {
      // Check subscription limits if tier info is provided
      if (subscriptionTierId != null && currentEngineerCount != null) {
        final canAdd = await _subscriptionService.canAddEngineer(
          tierId: subscriptionTierId,
          currentEngineersCount: currentEngineerCount,
        );

        if (!canAdd) {
          final tier = await _subscriptionService.getTier(subscriptionTierId);
          return SmoothResponse(
            code: 403,
            message:
                'Limite atteinte: ${tier?.maxEngineers ?? 0} ingénieurs max pour votre abonnement',
            data: false,
          );
        }
      }

      // Vérifier que l'utilisateur existe et n'est pas déjà dans une équipe
      final userDoc =
          await _firestore.collection(_usersCollection).doc(userId).get();
      if (!userDoc.exists) {
        return SmoothResponse(
            code: 404, message: 'Utilisateur non trouvé', data: false);
      }

      final userData = userDoc.data()!;
      if (userData['studioId'] != null && userData['studioId'] != studioId) {
        return SmoothResponse(
          code: 409,
          message: 'Cet utilisateur fait déjà partie d\'une autre équipe',
          data: false,
        );
      }

      // Mettre à jour le rôle et le studioId
      await _firestore.collection(_usersCollection).doc(userId).update({
        'studioId': studioId,
        'role': 'worker',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return SmoothResponse(code: 200, message: 'Membre ajouté', data: true);
    } catch (e) {
      debugPrint('Erreur addToTeam: $e');
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Retirer un membre de l'équipe
  Future<SmoothResponse<bool>> removeFromTeam(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'studioId': FieldValue.delete(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return SmoothResponse(code: 200, message: 'Membre retiré', data: true);
    } catch (e) {
      debugPrint('Erreur removeFromTeam: $e');
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Créer une invitation pour un nouvel ingénieur
  /// Si subscriptionTierId et currentEngineerCount sont fournis, vérifie les limites
  Future<SmoothResponse<TeamInvitation>> createInvitation({
    required String studioId,
    required String studioName,
    required String email,
    String? name,
    String? subscriptionTierId,
    int? currentEngineerCount,
  }) async {
    try {
      // Check subscription limits if tier info is provided
      if (subscriptionTierId != null && currentEngineerCount != null) {
        final canAdd = await _subscriptionService.canAddEngineer(
          tierId: subscriptionTierId,
          currentEngineersCount: currentEngineerCount,
        );

        if (!canAdd) {
          final tier = await _subscriptionService.getTier(subscriptionTierId);
          return SmoothResponse(
            code: 403,
            message:
                'Limite atteinte: ${tier?.maxEngineers ?? 0} ingénieurs max',
            data: null,
          );
        }
      }

      // Vérifier si une invitation pending existe déjà
      final existing = await _findPendingInvitation(email, studioId);
      if (existing != null) {
        return SmoothResponse(
            code: 200, message: 'Invitation existante', data: existing);
      }

      final docRef = _firestore.collection(_invitationsCollection).doc();
      final invitation = TeamInvitation(
        id: docRef.id,
        studioId: studioId,
        studioName: studioName,
        email: email.toLowerCase().trim(),
        name: name,
        code: _generateCode(),
        status: InvitationStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      await docRef.set(invitation.toMap());
      return SmoothResponse(
          code: 201, message: 'Invitation créée', data: invitation);
    } catch (e) {
      debugPrint('Erreur createInvitation: $e');
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: null);
    }
  }

  Future<TeamInvitation?> _findPendingInvitation(String email, String studioId) async {
    final snapshot = await _firestore
        .collection(_invitationsCollection)
        .where('email', isEqualTo: email.toLowerCase().trim())
        .where('studioId', isEqualTo: studioId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return TeamInvitation.fromMap(snapshot.docs.first.data());
  }

  /// Valider un code d'invitation
  Future<TeamInvitation?> validateCode(String code) async {
    final snapshot = await _firestore
        .collection(_invitationsCollection)
        .where('code', isEqualTo: code.toUpperCase().trim())
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final invitation = TeamInvitation.fromMap(snapshot.docs.first.data());
    if (invitation.isExpired) return null;

    return invitation;
  }

  /// Accepter une invitation (appelé quand l'ingénieur rejoint)
  Future<SmoothResponse<bool>> acceptInvitation({
    required String invitationId,
    required String userId,
  }) async {
    try {
      final inviteDoc =
          await _firestore.collection(_invitationsCollection).doc(invitationId).get();
      if (!inviteDoc.exists) {
        return SmoothResponse(code: 404, message: 'Invitation non trouvée', data: false);
      }

      final invitation = TeamInvitation.fromMap(inviteDoc.data()!);

      // Mettre à jour l'invitation
      await _firestore.collection(_invitationsCollection).doc(invitationId).update({
        'status': 'accepted',
        'acceptedByUserId': userId,
        'acceptedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Ajouter l'utilisateur à l'équipe
      await addToTeam(userId: userId, studioId: invitation.studioId);

      return SmoothResponse(code: 200, message: 'Invitation acceptée', data: true);
    } catch (e) {
      debugPrint('Erreur acceptInvitation: $e');
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Stream des invitations pending pour un studio
  Stream<List<TeamInvitation>> streamPendingInvitations(String studioId) {
    return _firestore
        .collection(_invitationsCollection)
        .where('studioId', isEqualTo: studioId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => TeamInvitation.fromMap(d.data())).toList());
  }

  /// Stream des invitations pending pour un ingénieur (par email)
  Stream<List<TeamInvitation>> streamMyPendingInvitations(String email) {
    return _firestore
        .collection(_invitationsCollection)
        .where('email', isEqualTo: email.toLowerCase().trim())
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TeamInvitation.fromMap(doc.data()))
            .where((inv) => !inv.isExpired)
            .toList());
  }

  /// Récupère les invitations pending pour un ingénieur (one-time)
  Future<List<TeamInvitation>> getMyPendingInvitations(String email) async {
    try {
      final snapshot = await _firestore
          .collection(_invitationsCollection)
          .where('email', isEqualTo: email.toLowerCase().trim())
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs
          .map((doc) => TeamInvitation.fromMap(doc.data()))
          .where((inv) => !inv.isExpired)
          .toList();
    } catch (e) {
      debugPrint('❌ TeamService.getMyPendingInvitations error: $e');
      return [];
    }
  }

  /// Refuser une invitation
  Future<SmoothResponse<bool>> declineInvitation(String invitationId) async {
    try {
      await _firestore.collection(_invitationsCollection).doc(invitationId).update({
        'status': 'declined',
        'declinedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Invitation refusée', data: true);
    } catch (e) {
      debugPrint('❌ TeamService.declineInvitation error: $e');
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Annuler une invitation
  Future<void> cancelInvitation(String invitationId) async {
    await _firestore.collection(_invitationsCollection).doc(invitationId).update({
      'status': 'cancelled',
    });
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var code = '';
    for (var i = 0; i < 6; i++) {
      code += chars[(random + i * 7) % chars.length];
    }
    return 'TEAM-$code';
  }
}

/// Status d'une invitation
enum InvitationStatus { pending, accepted, cancelled, expired }

/// Modèle d'invitation d'équipe
class TeamInvitation {
  final String id;
  final String studioId;
  final String studioName;
  final String email;
  final String? name;
  final String code;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? acceptedByUserId;
  final DateTime? acceptedAt;

  const TeamInvitation({
    required this.id,
    required this.studioId,
    required this.studioName,
    required this.email,
    this.name,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedByUserId,
    this.acceptedAt,
  });

  factory TeamInvitation.fromMap(Map<String, dynamic> map) {
    return TeamInvitation(
      id: map['id'] ?? '',
      studioId: map['studioId'] ?? '',
      studioName: map['studioName'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      code: map['code'] ?? '',
      status: _parseStatus(map['status']),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      expiresAt: _parseDateTime(map['expiresAt']) ?? DateTime.now(),
      acceptedByUserId: map['acceptedByUserId'],
      acceptedAt: _parseDateTime(map['acceptedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'studioId': studioId,
        'studioName': studioName,
        'email': email,
        'name': name,
        'code': code,
        'status': status.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'expiresAt': expiresAt.millisecondsSinceEpoch,
        'acceptedByUserId': acceptedByUserId,
        'acceptedAt': acceptedAt?.millisecondsSinceEpoch,
      };

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == InvitationStatus.pending && !isExpired;

  static InvitationStatus _parseStatus(String? value) {
    switch (value) {
      case 'accepted':
        return InvitationStatus.accepted;
      case 'cancelled':
        return InvitationStatus.cancelled;
      case 'expired':
        return InvitationStatus.expired;
      default:
        return InvitationStatus.pending;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
