import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:useme/core/models/studio_claim.dart';
import 'package:useme/core/models/studio_profile.dart';

/// Service pour gérer les demandes de revendication de studio (workflow admin)
class StudioClaimApprovalService {
  static final StudioClaimApprovalService _instance =
      StudioClaimApprovalService._internal();
  factory StudioClaimApprovalService() => _instance;
  StudioClaimApprovalService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'studio_claims';

  /// Crée une demande de revendication (pour les non-superAdmin)
  Future<StudioClaim> createClaimRequest({
    required String userId,
    required String userEmail,
    required String userName,
    required StudioProfile studioProfile,
  }) async {
    final docRef = _firestore.collection(_collection).doc();
    final claim = StudioClaim(
      id: docRef.id,
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      studioProfile: studioProfile,
      status: ClaimStatus.pending,
      createdAt: DateTime.now(),
    );

    await docRef.set(claim.toMap());
    debugPrint('✅ Demande de revendication créée: ${claim.id}');
    return claim;
  }

  /// Stream des demandes en attente (pour super admin)
  Stream<List<StudioClaim>> streamPendingClaims() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => StudioClaim.fromMap(d.data(), d.id)).toList());
  }

  /// Récupère toutes les demandes (pour super admin)
  Stream<List<StudioClaim>> streamAllClaims() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => StudioClaim.fromMap(d.data(), d.id)).toList());
  }

  /// Vérifie si l'utilisateur a une demande en attente
  Future<StudioClaim?> getPendingClaimForUser(String userId) async {
    final query = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return StudioClaim.fromMap(query.docs.first.data(), query.docs.first.id);
  }

  /// Approuve une demande de revendication
  Future<void> approveClaim({
    required String claimId,
    required String reviewerId,
  }) async {
    final claimDoc = await _firestore.collection(_collection).doc(claimId).get();
    if (!claimDoc.exists) throw Exception('Demande non trouvée');

    final claim = StudioClaim.fromMap(claimDoc.data()!, claimId);

    // Vérifier le rôle actuel de l'utilisateur
    final userDoc = await _firestore.collection('users').doc(claim.userId).get();
    final currentRole = userDoc.data()?['role'] as String?;
    final isSuperAdmin = currentRole == 'superAdmin';

    // Mettre à jour l'utilisateur avec le profil studio
    final updateData = <String, dynamic>{
      'isPartner': true,
      'studioProfile': claim.studioProfile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!isSuperAdmin) {
      updateData['role'] = 'admin';
    }

    await _firestore.collection('users').doc(claim.userId).update(updateData);

    // Mettre à jour le statut de la demande
    await _firestore.collection(_collection).doc(claimId).update({
      'status': 'approved',
      'reviewedAt': DateTime.now().millisecondsSinceEpoch,
      'reviewedBy': reviewerId,
    });

    debugPrint('✅ Demande approuvée: $claimId');
  }

  /// Rejette une demande de revendication
  Future<void> rejectClaim({
    required String claimId,
    required String reviewerId,
    String? reason,
  }) async {
    await _firestore.collection(_collection).doc(claimId).update({
      'status': 'rejected',
      'reviewedAt': DateTime.now().millisecondsSinceEpoch,
      'reviewedBy': reviewerId,
      'rejectionReason': reason,
    });

    debugPrint('❌ Demande rejetée: $claimId');
  }

  /// Annule une demande (par l'utilisateur)
  Future<void> cancelClaim(String claimId) async {
    await _firestore.collection(_collection).doc(claimId).delete();
    debugPrint('🗑️ Demande annulée: $claimId');
  }

  /// Compte les demandes en attente
  Future<int> getPendingClaimsCount() async {
    final query = await _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return query.count ?? 0;
  }
}
