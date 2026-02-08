import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/services_exports.dart';
import 'package:useme/widgets/chat/chat_widgets_exports.dart';

/// Écran de conversation avec l'assistant IA personnel
class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatAssistantService _aiService = ChatAssistantService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final bool _isLoading = false;
  bool _isTyping = false;
  List<AIMessage> _messages = [];
  String? _conversationId;
  BaseUserRole? _userRole;

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  bool get _isStudio => _userRole == BaseUserRole.admin ||
                        _userRole == BaseUserRole.superAdmin;
  bool get _isEngineer => _userRole == BaseUserRole.worker;

  Future<void> _initConversation() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Détecter le rôle de l'utilisateur
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      _userRole = authState.user.role;
    }

    // Récupérer ou créer la conversation IA
    _conversationId = 'ai_assistant_$userId';

    // Charger les messages existants
    await _loadMessages();

    // Si aucun message, afficher le message de bienvenue
    if (_messages.isEmpty) {
      setState(() {
        _messages = [
          AIMessage(
            id: 'welcome',
            content: _getWelcomeMessage(),
            isFromAI: true,
            timestamp: DateTime.now(),
            suggestions: _getInitialSuggestions(),
          ),
        ];
      });
    }

    // Scroll vers le bas après le chargement initial (sans animation)
    _scrollToBottom(animate: false);
  }

  String _getWelcomeMessage() {
    if (_isStudio) {
      return '''Salut ! 👋 Je suis ton assistant UZME.

Je peux t'aider à :
• 📊 Gérer tes réservations et demandes
• 💬 Rédiger des réponses aux artistes
• 📅 Optimiser tes disponibilités
• 💡 Améliorer ta visibilité
• ❓ Répondre à toutes tes questions

Comment puis-je t'aider aujourd'hui ?''';
    } else if (_isEngineer) {
      return '''Salut ! 👋 Je suis ton assistant UZME.

Je peux t'aider à :
• 📅 Gérer tes disponibilités
• 🎚️ Préparer tes sessions
• 💬 Communiquer avec les artistes
• 📊 Suivre ton activité
• ❓ Répondre à toutes tes questions

Qu'est-ce que je peux faire pour toi ?''';
    }

    // Artiste (par défaut)
    return '''Salut ! 👋 Je suis ton assistant UZME.

Je peux t'aider à :
• 🎵 Trouver le studio parfait pour ton projet
• 💰 Comparer les prix et services
• 📅 Vérifier les disponibilités
• 🎤 Recommander des ingénieurs son
• ❓ Répondre à toutes tes questions

Qu'est-ce que tu cherches aujourd'hui ?''';
  }

  List<String> _getInitialSuggestions() {
    if (_isStudio) {
      return [
        'Comment répondre à une demande ?',
        'Améliorer ma visibilité',
        'Configurer mes services',
      ];
    } else if (_isEngineer) {
      return [
        'Gérer mes disponibilités',
        'Préparer une session',
        'Contacter un artiste',
      ];
    }

    // Artiste (par défaut)
    return [
      'Trouve-moi un studio de rap',
      'Quels sont les studios près de moi ?',
      'Combien coûte une session de mix ?',
    ];
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) return;

    try {
      final snapshot = await _firestore
          .collection('ai_conversations')
          .doc(_conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .limit(50)
          .get();

      setState(() {
        _messages = snapshot.docs.map((doc) {
          final data = doc.data();
          return AIMessage(
            id: doc.id,
            content: data['content'] ?? '',
            isFromAI: data['isFromAI'] ?? false,
            timestamp: (data['timestamp'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            suggestions: List<String>.from(data['suggestions'] ?? []),
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _messageController.clear();

    // Ajouter le message utilisateur
    final userMessage = AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isFromAI: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _scrollToBottom();

    // Sauvegarder le message
    await _saveMessage(userMessage);

    try {
      // Générer la réponse IA via Cloud Function
      final response = await _generateAIResponse(text, userId);

      // Utiliser les suggestions de la Cloud Function ou fallback local
      final suggestions = response.suggestions.isNotEmpty
          ? response.suggestions
          : _generateFollowUpSuggestions(response.intent);

      final aiMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response.content,
        isFromAI: true,
        timestamp: DateTime.now(),
        suggestions: suggestions,
        actions: response.actions,
      );

      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
      });

      // Sauvegarder la réponse
      await _saveMessage(aiMessage);

      _scrollToBottom();
    } catch (e) {
      setState(() => _isTyping = false);

      // Message d'erreur
      final errorMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Désolé, je n\'ai pas pu traiter ta demande. '
            'Réessaie dans quelques instants ! 🙏',
        isFromAI: true,
        timestamp: DateTime.now(),
      );

      setState(() => _messages.add(errorMessage));
    }
  }

  Future<ChatAssistantResponse> _generateAIResponse(
    String message,
    String userId,
  ) async {
    try {
      // Appeler la Cloud Function generatePersonalAssistantResponse
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable(
        'generatePersonalAssistantResponse',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );

      // Préparer l'historique de conversation (5 derniers messages)
      final history = _messages.reversed.take(5).toList().reversed.map((m) => {
        'content': m.content,
        'isFromAI': m.isFromAI,
      }).toList();

      final result = await callable.call({
        'message': message,
        'conversationHistory': history,
      });

      final data = Map<String, dynamic>.from(result.data as Map);

      // Parser la réponse
      final intentStr = data['intent'] as String? ?? 'general';
      final intent = ChatIntent.values.firstWhere(
        (e) => e.value == intentStr,
        orElse: () => ChatIntent.general,
      );

      final suggestions = List<String>.from(data['suggestions'] ?? []);

      return ChatAssistantResponse(
        content: data['content'] as String? ?? '',
        intent: intent,
        actions: [],
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.8,
        suggestions: suggestions,
      );
    } catch (e) {
      debugPrint('Cloud Function error: $e');
      // Fallback vers la logique locale si la Cloud Function échoue
      return _generateLocalResponse(message);
    }
  }

  /// Génère une réponse locale (fallback si Cloud Function échoue)
  ChatAssistantResponse _generateLocalResponse(String message) {
    final intent = _aiService.detectIntentLocally(message);

    String response;
    List<SuggestedAction> actions = [];

    switch (intent) {
      case ChatIntent.pricing:
        response = _getPricingResponse();
        actions = [
          const SuggestedAction(
            label: 'Voir les studios',
            type: ActionType.viewServices,
          ),
        ];
        break;

      case ChatIntent.availability:
        response = _getAvailabilityResponse();
        actions = [
          const SuggestedAction(
            label: 'Explorer les studios',
            type: ActionType.viewAvailability,
          ),
        ];
        break;

      case ChatIntent.booking:
        response = _getBookingResponse();
        actions = [
          const SuggestedAction(
            label: 'Réserver',
            type: ActionType.booking,
          ),
        ];
        break;

      case ChatIntent.equipment:
        response = _getEquipmentResponse();
        break;

      case ChatIntent.greeting:
        response = _getGreetingResponse();
        break;

      default:
        response = _getDefaultResponse(message);
    }

    return ChatAssistantResponse(
      content: response,
      intent: intent,
      actions: actions,
      confidence: 0.85,
    );
  }

  String _getPricingResponse() {
    if (_isStudio) {
      return '''Pour définir tes tarifs, voici quelques conseils :

💡 **Analyse la concurrence** : Regarde les prix des studios similaires
📊 **Calcule tes coûts** : Loyer, équipement, charges...
🎯 **Positionne-toi** : Premium, milieu de gamme, ou accessible

Tu peux configurer tes services et tarifs dans Réglages > Services.

Tu veux des conseils pour optimiser tes prix ?''';
    }

    return '''Les tarifs varient selon les studios, mais voici une idée générale :

💰 **Enregistrement** : 25-50€/h
🎚️ **Mix** : 40-80€/h
🎧 **Mastering** : 50-100€/titre

Les studios Pro sur UZME offrent souvent des packs avantageux pour les projets complets (EP, Album).

Tu veux que je te montre les studios dans ton budget ?''';
  }

  String _getAvailabilityResponse() {
    if (_isStudio) {
      return '''Pour gérer tes disponibilités :

1. 📅 Va dans Réglages > Calendrier
2. ⏰ Définis tes horaires d'ouverture
3. 🔴 Bloque les créneaux indisponibles

Tu peux aussi connecter ton Google Calendar pour synchroniser automatiquement !

Tu veux que je t'explique comment optimiser ton planning ?''';
    } else if (_isEngineer) {
      return '''Pour gérer tes disponibilités :

1. 📅 Va dans Réglages > Disponibilités
2. ⏰ Configure tes horaires de travail
3. 🏖️ Ajoute tes indisponibilités (vacances, etc.)

Le studio pourra ainsi t'assigner des sessions sur tes créneaux actifs !''';
    }

    return '''Pour voir les disponibilités, tu peux :

1. 📍 Explorer les studios sur la carte
2. 🔍 Filtrer par date et créneau
3. 📅 Consulter le calendrier de chaque studio

La plupart des studios ont des créneaux disponibles en semaine. Les week-ends sont souvent plus demandés !

Tu cherches pour quelle date ?''';
  }

  String _getBookingResponse() {
    if (_isStudio) {
      return '''Pour gérer les demandes de réservation :

1. 📬 Les nouvelles demandes arrivent en "En attente"
2. ✅ Accepte et assigne un ingénieur
3. 💬 Un message est envoyé automatiquement à l'artiste

Conseil : Réponds rapidement pour fidéliser les artistes !

Tu as des demandes en attente ?''';
    }

    return '''Pour réserver une session, c'est simple :

1. Choisis un studio qui te plaît
2. Sélectionne un service et un créneau
3. Envoie ta demande de réservation
4. Le studio confirme et tu reçois les détails !

Tu veux que je t'aide à trouver un studio adapté à ton projet ?''';
  }

  String _getEquipmentResponse() {
    if (_isStudio) {
      return '''Pour mettre en avant ton équipement :

1. 📝 Liste tout dans ton profil studio
2. 📸 Ajoute des photos de qualité
3. 🏷️ Mentionne les marques (Neumann, SSL, etc.)

Un profil bien rempli attire plus d'artistes !

Tu veux que je t'aide à optimiser ton profil ?''';
    }

    return '''Chaque studio a son propre équipement. Sur UZME, tu peux voir :

🎤 **Micros** : Neumann, Shure, AKG...
🎚️ **Consoles** : SSL, Neve, API...
🖥️ **DAW** : Pro Tools, Logic, Ableton...
🔊 **Monitoring** : Genelec, Adam, Focal...

Dis-moi quel type de son tu recherches et je peux te recommander des studios avec l'équipement adapté !''';
  }

  String _getGreetingResponse() {
    if (_isStudio) {
      final greetings = [
        'Hey ! 👋 Comment va ton studio aujourd\'hui ?',
        'Salut ! 📊 Besoin d\'aide pour gérer ton activité ?',
        'Hello ! 🎵 Comment puis-je t\'aider ?',
      ];
      return greetings[DateTime.now().second % greetings.length];
    } else if (_isEngineer) {
      final greetings = [
        'Hey ! 👋 Prêt pour tes sessions ?',
        'Salut ! 🎚️ Comment ça va côté studio ?',
        'Hello ! 🎧 Besoin d\'aide ?',
      ];
      return greetings[DateTime.now().second % greetings.length];
    }

    final greetings = [
      'Hey ! 👋 Comment je peux t\'aider aujourd\'hui ?',
      'Salut ! 🎵 Qu\'est-ce que tu cherches ?',
      'Hello ! 🎤 Prêt à booker une session ?',
    ];
    return greetings[DateTime.now().second % greetings.length];
  }

  String _getDefaultResponse(String message) {
    if (_isStudio) {
      return '''Je comprends que tu cherches des infos sur "$message".

Pour mieux t'aider, tu peux me demander :
• Comment gérer les réservations
• Des conseils pour améliorer ta visibilité
• Comment configurer tes services
• Des astuces pour ton studio

Qu'est-ce qui t'intéresse ?''';
    } else if (_isEngineer) {
      return '''Je comprends que tu cherches des infos sur "$message".

Pour mieux t'aider, tu peux me demander :
• Comment gérer tes disponibilités
• Des conseils pour tes sessions
• Comment communiquer avec les artistes

Qu'est-ce que je peux faire pour toi ?''';
    }

    return '''Je comprends que tu cherches des infos sur "$message".

Pour mieux t'aider, tu peux me demander :
• Des recommandations de studios
• Des infos sur les prix
• Des disponibilités
• Des conseils pour ton projet

Qu'est-ce qui t'intéresse le plus ?''';
  }

  List<String> _generateFollowUpSuggestions(ChatIntent intent) {
    if (_isStudio) {
      switch (intent) {
        case ChatIntent.pricing:
          return [
            'Créer un nouveau service',
            'Voir mes tarifs actuels',
            'Conseils pricing',
          ];
        case ChatIntent.availability:
          return [
            'Configurer mes horaires',
            'Bloquer un créneau',
            'Connecter Google Calendar',
          ];
        case ChatIntent.booking:
          return [
            'Voir les demandes en attente',
            'Historique des sessions',
            'Contacter un artiste',
          ];
        default:
          return [
            'Gérer mes réservations',
            'Améliorer ma visibilité',
            'Configurer mon profil',
          ];
      }
    } else if (_isEngineer) {
      return [
        'Mes prochaines sessions',
        'Gérer mes dispos',
        'Contacter le studio',
      ];
    }

    // Artiste (par défaut)
    switch (intent) {
      case ChatIntent.pricing:
        return [
          'Studios moins de 30€/h',
          'Packs pour EP',
          'Studios avec mix inclus',
        ];
      case ChatIntent.availability:
        return [
          'Dispos ce week-end',
          'Sessions en soirée',
          'Réserver maintenant',
        ];
      case ChatIntent.booking:
        return [
          'Studios de rap',
          'Studios pop/rock',
          'Voir la carte',
        ];
      default:
        return [
          'Trouver un studio',
          'Comparer les prix',
          'Voir les avis',
        ];
    }
  }

  Future<void> _saveMessage(AIMessage message) async {
    if (_conversationId == null) return;

    try {
      await _firestore
          .collection('ai_conversations')
          .doc(_conversationId)
          .collection('messages')
          .add({
        'content': message.content,
        'isFromAI': message.isFromAI,
        'timestamp': FieldValue.serverTimestamp(),
        'suggestions': message.suggestions,
      });
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_isTyping) const AITypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.blue.shade400],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assistant UZME',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                'Toujours disponible',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    final isAI = message.isFromAI;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment:
            isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isAI
                  ? Theme.of(context).cardColor
                  : Colors.purple.shade500,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: isAI ? const Radius.circular(4) : null,
                bottomRight: !isAI ? const Radius.circular(4) : null,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAI)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: Colors.purple.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Assistant IA',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.purple.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isAI)
                  AIMessageContent(
                    content: message.content,
                  )
                else
                  Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),

          // Suggestions
          if (isAI && message.suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: message.suggestions.map((suggestion) {
                  return GestureDetector(
                    onTap: () => _sendMessage(suggestion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.purple.withValues(alpha:0.3),
                        ),
                      ),
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Pose ta question...',
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.blue.shade400],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isLoading
                  ? null
                  : () => _sendMessage(_messageController.text),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Message dans la conversation IA
class AIMessage {
  final String id;
  final String content;
  final bool isFromAI;
  final DateTime timestamp;
  final List<String> suggestions;
  final List<SuggestedAction> actions;

  AIMessage({
    required this.id,
    required this.content,
    required this.isFromAI,
    required this.timestamp,
    this.suggestions = const [],
    this.actions = const [],
  });
}
