import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:useme/core/models/ai_message.dart';
import 'package:useme/core/models/chat_assistant_response.dart';
import 'package:useme/core/services/ai_local_response_helper.dart';
import 'package:useme/core/utils/app_logger.dart';

/// Handles AI conversation persistence and Cloud Function calls.
class AIConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AILocalResponseHelper responseHelper;

  AIConversationService({required this.responseHelper});

  /// Loads existing messages for a conversation.
  Future<List<AIMessage>> loadMessages(String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection('ai_conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
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
    } catch (e) {
      appLog('Error loading messages: $e');
      return [];
    }
  }

  /// Saves a message to Firestore.
  Future<void> saveMessage(String conversationId, AIMessage message) async {
    try {
      await _firestore
          .collection('ai_conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'content': message.content,
        'isFromAI': message.isFromAI,
        'timestamp': FieldValue.serverTimestamp(),
        'suggestions': message.suggestions,
      });
    } catch (e) {
      appLog('Error saving message: $e');
    }
  }

  /// Calls the Cloud Function to generate an AI response.
  /// Falls back to local response generation on failure.
  Future<ChatAssistantResponse> generateResponse(
    String message,
    List<AIMessage> recentMessages,
  ) async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable(
        'generatePersonalAssistantResponse',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 60),
        ),
      );

      final history = recentMessages.reversed
          .take(5)
          .toList()
          .reversed
          .map((m) => {
                'content': m.content,
                'isFromAI': m.isFromAI,
              })
          .toList();

      final result = await callable.call({
        'message': message,
        'conversationHistory': history,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final intentStr = data['intent'] as String? ?? 'general';
      final intent = ChatIntent.values.firstWhere(
        (e) => e.value == intentStr,
        orElse: () => ChatIntent.general,
      );

      return ChatAssistantResponse(
        content: data['content'] as String? ?? '',
        intent: intent,
        actions: [],
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.8,
        suggestions: List<String>.from(data['suggestions'] ?? []),
      );
    } catch (e) {
      appLog('Cloud Function error: $e');
      return responseHelper.generateLocalResponse(message);
    }
  }
}
