import 'package:uzme/core/models/chat_assistant_response.dart';

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
