import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/session.dart';

/// Service pour gérer les propositions de sessions aux ingénieurs
class EngineerProposalService {
  final FirebaseFirestore _firestore;

  EngineerProposalService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Propose une session à plusieurs ingénieurs
  /// Chaque ingénieur reçoit une notification et peut accepter/refuser
  Future<void> proposeToEngineers({
    required String sessionId,
    required List<AppUser> engineers,
    required String studioName,
    required Session session,
  }) async {
    final batch = _firestore.batch();
    final sessionRef = _firestore.collection('useme_sessions').doc(sessionId);
    final engineerIds = engineers.map((e) => e.uid).toList();

    // 1. Mettre à jour la session avec les ingénieurs proposés
    batch.update(sessionRef, {
      'proposedEngineerIds': FieldValue.arrayUnion(engineerIds),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Envoyer une notification à chaque ingénieur
    final sessionTitle = '${session.typeLabel} - ${session.artistNames.join(", ")}';
    final dateStr = _formatDate(session.scheduledStart);
    final timeStr = _formatTime(session.scheduledStart, session.scheduledEnd);

    for (final engineer in engineers) {
      final notifRef = _firestore.collection('user_notifications').doc();
      batch.set(notifRef, {
        'id': notifRef.id,
        'userId': engineer.uid,
        'type': 'session_proposed',
        'title': 'Session proposée 🎧',
        'body': '$studioName vous propose "$sessionTitle" le $dateStr de $timeStr',
        'data': {
          'sessionId': sessionId,
          'studioName': studioName,
          'sessionDate': session.scheduledStart.toIso8601String(),
          'action': 'accept_decline',
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    debugPrint('✅ Session proposée à ${engineers.length} ingénieurs');
  }

  /// Un ingénieur accepte une proposition de session
  /// Il devient le premier ingénieur assigné, les autres sont notifiés
  Future<void> acceptProposal({
    required String sessionId,
    required AppUser engineer,
    required Session session,
    required String studioName,
  }) async {
    final batch = _firestore.batch();
    final sessionRef = _firestore.collection('useme_sessions').doc(sessionId);

    // 1. Ajouter l'ingénieur aux assignés et le retirer des proposés
    batch.update(sessionRef, {
      'engineerIds': FieldValue.arrayUnion([engineer.uid]),
      'engineerNames': FieldValue.arrayUnion([engineer.displayName ?? engineer.email]),
      'proposedEngineerIds': FieldValue.arrayRemove([engineer.uid]),
      // Rétro-compat: mettre aussi engineerId/engineerName si c'est le premier
      'engineerId': engineer.uid,
      'engineerName': engineer.displayName ?? engineer.email,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Notifier le studio
    final studioNotifRef = _firestore.collection('user_notifications').doc();
    final sessionTitle = '${session.typeLabel} - ${session.artistNames.join(", ")}';
    batch.set(studioNotifRef, {
      'id': studioNotifRef.id,
      'userId': session.studioId,
      'type': 'engineer_accepted',
      'title': 'Ingénieur confirmé ✅',
      'body': '${engineer.displayName} a accepté la session "$sessionTitle"',
      'data': {'sessionId': sessionId, 'engineerId': engineer.uid},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3. Notifier les autres ingénieurs proposés que la session est prise
    final otherProposed = session.proposedEngineerIds.where((id) => id != engineer.uid);
    for (final otherId in otherProposed) {
      final otherNotifRef = _firestore.collection('user_notifications').doc();
      batch.set(otherNotifRef, {
        'id': otherNotifRef.id,
        'userId': otherId,
        'type': 'session_taken',
        'title': 'Session attribuée',
        'body': '"$sessionTitle" a été prise par ${engineer.displayName}. Vous pouvez demander à rejoindre.',
        'data': {
          'sessionId': sessionId,
          'assignedEngineerId': engineer.uid,
          'action': 'join_request',
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    debugPrint('✅ ${engineer.uid} a accepté la session $sessionId');
  }

  /// Un ingénieur refuse une proposition
  Future<void> declineProposal({
    required String sessionId,
    required String engineerId,
  }) async {
    await _firestore.collection('useme_sessions').doc(sessionId).update({
      'proposedEngineerIds': FieldValue.arrayRemove([engineerId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ $engineerId a refusé la session $sessionId');
  }

  /// Un ingénieur demande à rejoindre une session déjà attribuée (co-ingénieur)
  /// Auto-ajout avec droit de regard du studio
  Future<void> joinAsCoEngineer({
    required String sessionId,
    required AppUser engineer,
    required Session session,
  }) async {
    final batch = _firestore.batch();
    final sessionRef = _firestore.collection('useme_sessions').doc(sessionId);

    // 1. Ajouter l'ingénieur comme co-ingénieur
    batch.update(sessionRef, {
      'engineerIds': FieldValue.arrayUnion([engineer.uid]),
      'engineerNames': FieldValue.arrayUnion([engineer.displayName ?? engineer.email]),
      'proposedEngineerIds': FieldValue.arrayRemove([engineer.uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Notifier le studio (droit de regard)
    final studioNotifRef = _firestore.collection('user_notifications').doc();
    final sessionTitle = '${session.typeLabel} - ${session.artistNames.join(", ")}';
    batch.set(studioNotifRef, {
      'id': studioNotifRef.id,
      'userId': session.studioId,
      'type': 'coEngineer_joined',
      'title': 'Co-ingénieur ajouté 👥',
      'body': '${engineer.displayName} a rejoint "$sessionTitle" comme co-ingénieur',
      'data': {
        'sessionId': sessionId,
        'engineerId': engineer.uid,
        'action': 'can_remove',
      },
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3. Notifier l'ingénieur principal
    if (session.engineerId != null && session.engineerId != engineer.uid) {
      final mainEngNotifRef = _firestore.collection('user_notifications').doc();
      batch.set(mainEngNotifRef, {
        'id': mainEngNotifRef.id,
        'userId': session.engineerId,
        'type': 'coEngineer_joined',
        'title': 'Co-ingénieur sur ta session 👥',
        'body': '${engineer.displayName} rejoint "$sessionTitle"',
        'data': {'sessionId': sessionId, 'coEngineerId': engineer.uid},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    debugPrint('✅ ${engineer.uid} a rejoint comme co-ingénieur sur $sessionId');
  }

  /// Le studio retire un ingénieur de la session
  Future<void> removeEngineer({
    required String sessionId,
    required String engineerId,
    required String engineerName,
    required Session session,
  }) async {
    final batch = _firestore.batch();
    final sessionRef = _firestore.collection('useme_sessions').doc(sessionId);

    final updateData = <String, dynamic>{
      'engineerIds': FieldValue.arrayRemove([engineerId]),
      'engineerNames': FieldValue.arrayRemove([engineerName]),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Si c'était l'ingénieur principal, le retirer aussi
    if (session.engineerId == engineerId) {
      updateData['engineerId'] = null;
      updateData['engineerName'] = null;
    }

    batch.update(sessionRef, updateData);

    // Notifier l'ingénieur retiré
    final notifRef = _firestore.collection('user_notifications').doc();
    final sessionTitle = '${session.typeLabel} - ${session.artistNames.join(", ")}';
    batch.set(notifRef, {
      'id': notifRef.id,
      'userId': engineerId,
      'type': 'removed_from_session',
      'title': 'Retrait de session',
      'body': 'Vous avez été retiré de "$sessionTitle"',
      'data': {'sessionId': sessionId},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    debugPrint('✅ $engineerId retiré de la session $sessionId');
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
