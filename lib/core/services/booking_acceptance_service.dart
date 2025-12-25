import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/payment_method.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/core/services/engineer_proposal_service.dart';
import 'package:useme/core/services/payment_config_service.dart';

/// Service pour gérer l'acceptation des réservations
class BookingAcceptanceService {
  final FirebaseFirestore _firestore;
  final PaymentConfigService _paymentService;
  final EngineerProposalService _proposalService;

  BookingAcceptanceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _paymentService = PaymentConfigService(),
        _proposalService = EngineerProposalService();

  /// Accepte une réservation et envoie les infos de paiement
  ///
  /// 1. Met à jour le statut de la session
  /// 2. Si des ingénieurs sont proposés, leur envoie des notifications
  /// 3. Crée ou récupère une conversation avec l'artiste
  /// 4. Envoie un message avec les détails de paiement
  /// 5. Envoie une notification push à l'artiste
  Future<SmoothResponse<String>> acceptBooking({
    required Session session,
    required AppUser studio,
    required String artistId,
    required PaymentMethod paymentMethod,
    required double totalAmount,
    required double depositAmount,
    String? customMessage,
    List<AppUser> selectedEngineers = const [],
    bool proposeToEngineers = false,
    @Deprecated('Use selectedEngineers instead') AppUser? assignedEngineer,
  }) async {
    try {
      // Rétro-compatibilité: si assignedEngineer est fourni, l'utiliser
      final engineers = assignedEngineer != null ? [assignedEngineer] : selectedEngineers;
      final shouldPropose = proposeToEngineers || (assignedEngineer == null && engineers.isNotEmpty);

      // 1. Mettre à jour la session
      await _updateSessionStatus(session.id, 'confirmed');

      // 2. Si mode proposition avec ingénieurs sélectionnés
      if (shouldPropose && engineers.isNotEmpty) {
        await _proposalService.proposeToEngineers(
          sessionId: session.id,
          engineers: engineers,
          studioName: studio.studioProfile?.name ?? studio.displayName ?? 'Studio',
          session: session,
        );
      } else if (engineers.length == 1 && !shouldPropose) {
        // Assignation directe d'un seul ingénieur (ancien comportement)
        await _updateSessionWithEngineer(
          sessionId: session.id,
          engineer: engineers.first,
        );
        await _sendEngineerNotification(
          engineer: engineers.first,
          session: session,
          studioName: studio.studioProfile?.name ?? studio.displayName ?? 'Studio',
        );
      }

      // 2. Créer ou récupérer la conversation
      final conversationId = await _getOrCreateConversation(
        studioId: studio.uid,
        studioName: studio.studioProfile?.name ?? studio.displayName ?? 'Studio',
        studioPhoto: studio.photoURL,
        artistId: artistId,
      );

      // 3. Générer et envoyer le message de paiement
      final sessionTitle = '${session.typeLabel} - ${session.artistNames.join(", ")}';
      final paymentMessage = _paymentService.generatePaymentMessageLocal(
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
        recipientId: artistId,
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
    await _firestore.collection('useme_sessions').doc(sessionId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Session $sessionId status=$status');
  }

  Future<void> _updateSessionWithEngineer({
    required String sessionId,
    required AppUser engineer,
  }) async {
    await _firestore.collection('useme_sessions').doc(sessionId).update({
      'engineerId': engineer.uid,
      'engineerName': engineer.displayName ?? engineer.email,
      'engineerIds': FieldValue.arrayUnion([engineer.uid]),
      'engineerNames': FieldValue.arrayUnion([engineer.displayName ?? engineer.email]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Ingénieur ${engineer.uid} assigné à session $sessionId');
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

    // Créer une nouvelle conversation (format compatible avec BaseConversation)
    final conversationRef = _firestore.collection('conversations').doc();
    final now = DateTime.now().toIso8601String();
    await conversationRef.set({
      'type': 'private',
      'participantIds': [studioId, artistId],
      'participantDetails': {
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
      'createdAt': now,
      'updatedAt': now,
      'createdByUserId': studioId,
      'unreadCounts': {studioId: 0, artistId: 0},
      'isArchived': {studioId: false, artistId: false},
    });

    return conversationRef.id;
  }

  Future<void> _sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String message,
    required String recipientId,
  }) async {
    final now = DateTime.now().toIso8601String();
    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    // Format compatible avec BaseMessage
    await messageRef.set({
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'text': message,
      'type': 'text',
      'sentAt': now,
      'readBy': {senderId: now},
      'isDeleted': false,
    });

    // Mettre à jour la conversation avec lastMessage au format LastMessageSummary
    final previewText = message.length > 100 ? '${message.substring(0, 100)}...' : message;
    await _firestore.collection('conversations').doc(conversationId).update({
      'updatedAt': now,
      'lastMessage': {
        'text': previewText,
        'senderId': senderId,
        'senderName': senderName,
        'sentAt': now,
        'type': 'text',
      },
      'unreadCounts.$recipientId': FieldValue.increment(1),
    });

    debugPrint('✅ Message envoyé dans conversation $conversationId');
  }

  Future<void> _sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Créer la notification dans user_notifications
    // (Cloud Function envoie le push automatiquement)
    final notifRef = _firestore.collection('user_notifications').doc();
    await notifRef.set({
      'id': notifRef.id,
      'userId': userId,
      'type': data?['type'] ?? 'booking_accepted',
      'title': title,
      'body': body,
      'data': data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Notification créée pour $userId');
  }

  /// Envoie une notification à l'ingénieur assigné
  Future<void> _sendEngineerNotification({
    required AppUser engineer,
    required Session session,
    required String studioName,
  }) async {
    final sessionTitle = '${session.typeLabel} - ${session.artistNames.join(", ")}';
    final dateStr = _formatDate(session.scheduledStart);
    final timeStr = _formatTime(session.scheduledStart, session.scheduledEnd);

    await _sendNotification(
      userId: engineer.uid,
      title: 'Nouvelle session assignée 🎧',
      body: 'Vous êtes assigné à "$sessionTitle" le $dateStr de $timeStr',
      data: {
        'type': 'engineer_assigned',
        'sessionId': session.id,
        'studioName': studioName,
        'sessionDate': session.scheduledStart.toIso8601String(),
      },
    );
    debugPrint('✅ Notification envoyée à l\'ingénieur ${engineer.uid}');
  }

  String _formatDate(DateTime date) {
    const days = ['lun', 'mar', 'mer', 'jeu', 'ven', 'sam', 'dim'];
    const months = ['jan', 'fév', 'mars', 'avr', 'mai', 'juin', 'juil', 'août', 'sept', 'oct', 'nov', 'déc'];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime start, DateTime end) {
    String fmt(DateTime d) => '${d.hour.toString().padLeft(2, '0')}h${d.minute.toString().padLeft(2, '0')}';
    return '${fmt(start)} à ${fmt(end)}';
  }
}
