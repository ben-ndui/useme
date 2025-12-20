import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/core/services/payment_config_service.dart';

/// Service pour gérer l'acceptation des réservations
class BookingAcceptanceService {
  final FirebaseFirestore _firestore;
  final PaymentConfigService _paymentService;

  BookingAcceptanceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _paymentService = PaymentConfigService();

  /// Accepte une réservation et envoie les infos de paiement
  ///
  /// 1. Met à jour le statut de la session
  /// 2. Crée ou récupère une conversation avec l'artiste
  /// 3. Envoie un message avec les détails de paiement
  /// 4. Envoie une notification push à l'artiste
  Future<SmoothResponse<String>> acceptBooking({
    required Session session,
    required AppUser studio,
    required String artistId,
    required PaymentMethod paymentMethod,
    required double totalAmount,
    required double depositAmount,
    String? customMessage,
  }) async {
    try {
      // 1. Mettre à jour la session
      await _updateSessionStatus(session.id, 'confirmed');

      // 2. Créer ou récupérer la conversation
      final conversationId = await _getOrCreateConversation(
        studioId: studio.uid,
        studioName: studio.studioProfile?.name ?? studio.displayName ?? 'Studio',
        studioPhoto: studio.photoURL,
        artistId: artistId,
      );

      // 3. Générer et envoyer le message de paiement
      final sessionTitle = '${session.type.label} - ${session.artistNames.join(", ")}';
      final paymentMessage = _paymentService.generatePaymentMessage(
        sessionTitle: sessionTitle,
        sessionDate: session.scheduledStart,
        totalAmount: totalAmount,
        depositAmount: depositAmount,
        paymentMethod: paymentMethod,
        studioName: studio.studioProfile?.name,
      );

      // Ajouter le message personnalisé s'il existe
      final fullMessage = customMessage != null && customMessage.isNotEmpty
          ? '$paymentMessage\n---\n$customMessage'
          : paymentMessage;

      await _sendMessage(
        conversationId: conversationId,
        senderId: studio.uid,
        senderName: studio.studioProfile?.name ?? studio.displayName ?? 'Studio',
        message: fullMessage,
      );

      // 4. Envoyer une notification push à l'artiste
      await _sendNotification(
        userId: artistId,
        title: 'Réservation acceptée ! 🎉',
        body: 'Votre session "$sessionTitle" a été confirmée. Vérifiez les infos de paiement.',
        data: {
          'type': 'booking_accepted',
          'sessionId': session.id,
          'conversationId': conversationId,
        },
      );

      return SmoothResponse(
        code: 200,
        message: 'Réservation acceptée',
        data: conversationId,
      );
    } catch (e) {
      debugPrint('Erreur acceptBooking: $e');
      return SmoothResponse(
        code: 500,
        message: 'Erreur: $e',
        data: null,
      );
    }
  }

  Future<void> _updateSessionStatus(String sessionId, String status) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _getOrCreateConversation({
    required String studioId,
    required String studioName,
    String? studioPhoto,
    required String artistId,
  }) async {
    // Chercher une conversation existante
    final existingQuery = await _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: studioId)
        .where('type', isEqualTo: 'private')
        .get();

    for (final doc in existingQuery.docs) {
      final participantIds = List<String>.from(doc.data()['participantIds'] ?? []);
      if (participantIds.contains(artistId)) {
        return doc.id;
      }
    }

    // Récupérer les infos de l'artiste
    final artistDoc = await _firestore.collection('users').doc(artistId).get();
    final artistData = artistDoc.data();
    final artistName = artistData?['displayName'] ?? artistData?['name'] ?? 'Artiste';
    final artistPhoto = artistData?['photoURL'];

    // Créer une nouvelle conversation
    final conversationRef = _firestore.collection('conversations').doc();
    await conversationRef.set({
      'type': 'private',
      'participantIds': [studioId, artistId],
      'participantInfo': {
        studioId: {
          'name': studioName,
          'avatarUrl': studioPhoto,
          'role': 'Studio',
        },
        artistId: {
          'name': artistName,
          'avatarUrl': artistPhoto,
          'role': 'Artiste',
        },
      },
      'lastMessage': null,
      'lastMessageAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'archivedBy': [],
    });

    return conversationRef.id;
  }

  Future<void> _sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'senderId': senderId,
      'senderName': senderName,
      'content': message,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [senderId],
    });

    // Mettre à jour la conversation
    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': message.length > 100 ? '${message.substring(0, 100)}...' : message,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Récupérer le FCM token de l'utilisateur
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final fcmToken = userDoc.data()?['fcmToken'];

    if (fcmToken == null) {
      debugPrint('No FCM token for user $userId');
      return;
    }

    // Créer la notification dans Firestore (sera traitée par Cloud Function)
    await _firestore.collection('notifications').add({
      'userId': userId,
      'fcmToken': fcmToken,
      'title': title,
      'body': body,
      'data': data,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
