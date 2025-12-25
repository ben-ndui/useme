import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:useme/core/models/models_exports.dart';

/// Service pour gérer l'assistant IA dans le chat
class ChatAssistantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Singleton
  static final ChatAssistantService _instance = ChatAssistantService._internal();
  factory ChatAssistantService() => _instance;
  ChatAssistantService._internal();

  // =====================
  // AI Response Generation
  // =====================

  /// Génère une réponse IA pour un message
  Future<ChatAssistantResponse> generateResponse({
    required String message,
    required String conversationId,
    required String studioId,
    String? artistId,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'generateChatResponse',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );

      final result = await callable.call({
        'message': message,
        'conversationId': conversationId,
        'studioId': studioId,
        if (artistId != null) 'artistId': artistId,
      });

      return ChatAssistantResponse.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );
    } on FirebaseFunctionsException catch (e) {
      throw ChatAssistantException(
        'Erreur IA: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ChatAssistantException('Erreur de connexion: $e');
    }
  }

  /// Génère des suggestions de réponses rapides
  Future<List<String>> getSuggestedReplies({
    required String lastMessage,
    required String studioId,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'getSuggestedReplies',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 10)),
      );

      final result = await callable.call({
        'lastMessage': lastMessage,
        'studioId': studioId,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      return List<String>.from(data['suggestions'] ?? []);
    } catch (e) {
      // Fail silently - suggestions are optional
      return [];
    }
  }

  /// Détecte l'intention d'un message localement (sans appel API)
  ChatIntent detectIntentLocally(String message) {
    final lowerMessage = message.toLowerCase();

    // Salutations
    if (lowerMessage.matchesAny(['salut', 'bonjour', 'hello', 'hey', 'coucou', 'bonsoir'])) {
      return ChatIntent.greeting;
    }

    // Prix
    if (lowerMessage.matchesAny(['prix', 'combien', 'tarif', 'coût', '€', 'euro', 'cher'])) {
      return ChatIntent.pricing;
    }

    // Disponibilités
    if (lowerMessage.matchesAny(['dispo', 'disponible', 'créneau', 'quand', 'horaire', 'ouvert'])) {
      return ChatIntent.availability;
    }

    // Réservation
    if (lowerMessage.matchesAny(['réserv', 'book', 'session', 'rendez-vous', 'prendre'])) {
      return ChatIntent.booking;
    }

    // Équipements
    if (lowerMessage.matchesAny(['micro', 'matos', 'équipement', 'console', 'daw', 'matériel'])) {
      return ChatIntent.equipment;
    }

    // Localisation
    if (lowerMessage.matchesAny(['où', 'adresse', 'situé', 'venir', 'parking', 'accès'])) {
      return ChatIntent.location;
    }

    // Annulation
    if (lowerMessage.matchesAny(['annul', 'rembours', 'report', 'décaler'])) {
      return ChatIntent.cancellation;
    }

    // Négociation
    if (lowerMessage.matchesAny(['réduc', 'moins cher', 'négo', 'remise', 'promotion'])) {
      return ChatIntent.negotiation;
    }

    // Demande humain
    if (lowerMessage.matchesAny(['parler', 'humain', 'quelqu\'un', 'manager', 'responsable'])) {
      return ChatIntent.humanNeeded;
    }

    return ChatIntent.general;
  }

  // =====================
  // AI Settings Management
  // =====================

  /// Récupère les paramètres IA d'un studio
  Future<StudioAISettings> getSettings(String studioId) async {
    try {
      final doc = await _firestore.collection('ai_settings').doc(studioId).get();

      if (!doc.exists) {
        return StudioAISettings.empty(studioId);
      }

      return StudioAISettings.fromJson(doc.data()!, studioId);
    } catch (e) {
      return StudioAISettings.empty(studioId);
    }
  }

  /// Stream des paramètres IA d'un studio
  Stream<StudioAISettings> streamSettings(String studioId) {
    return _firestore
        .collection('ai_settings')
        .doc(studioId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return StudioAISettings.empty(studioId);
      }
      return StudioAISettings.fromJson(doc.data()!, studioId);
    });
  }

  /// Met à jour les paramètres IA d'un studio
  Future<void> updateSettings(StudioAISettings settings) async {
    await _firestore
        .collection('ai_settings')
        .doc(settings.studioId)
        .set(settings.toJson(), SetOptions(merge: true));
  }

  /// Active/désactive l'IA pour un studio
  Future<void> toggleAI(String studioId, bool enabled) async {
    await _firestore.collection('ai_settings').doc(studioId).set({
      'enabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Change le mode IA
  Future<void> setMode(String studioId, AIMode mode) async {
    await _firestore.collection('ai_settings').doc(studioId).set({
      'mode': mode.value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // =====================
  // FAQ Management
  // =====================

  /// Ajoute une FAQ personnalisée
  Future<void> addFAQ(String studioId, CustomFAQ faq) async {
    await _firestore.collection('ai_settings').doc(studioId).set({
      'customFAQs': FieldValue.arrayUnion([faq.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Supprime une FAQ
  Future<void> removeFAQ(String studioId, CustomFAQ faq) async {
    await _firestore.collection('ai_settings').doc(studioId).set({
      'customFAQs': FieldValue.arrayRemove([faq.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // =====================
  // AI Message Logging
  // =====================

  /// Log une réponse IA pour analytics
  Future<void> logAIResponse({
    required String conversationId,
    required String userMessage,
    required ChatAssistantResponse response,
    required bool wasUsed,
    bool wasEdited = false,
    int? responseTimeMs,
  }) async {
    await _firestore
        .collection('ai_conversations')
        .doc(conversationId)
        .collection('ai_messages')
        .add({
      'userMessage': userMessage,
      'aiResponse': response.content,
      'intent': response.intent.value,
      'confidence': response.confidence,
      'wasUsed': wasUsed,
      'wasEdited': wasEdited,
      'responseTimeMs': responseTimeMs,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

/// Exception pour le ChatAssistantService
class ChatAssistantException implements Exception {
  final String message;
  final String? code;

  ChatAssistantException(this.message, {this.code});

  @override
  String toString() => 'ChatAssistantException: $message';
}

/// Extension pour faciliter la recherche de patterns
extension _StringMatchExtension on String {
  bool matchesAny(List<String> patterns) {
    return patterns.any((pattern) => contains(pattern));
  }
}
