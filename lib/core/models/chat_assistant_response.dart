import 'package:equatable/equatable.dart';

/// Réponse générée par l'assistant IA
class ChatAssistantResponse extends Equatable {
  final String content;
  final ChatIntent intent;
  final List<SuggestedAction> actions;
  final List<String> suggestions;
  final double confidence;
  final bool shouldEscalate;

  const ChatAssistantResponse({
    required this.content,
    required this.intent,
    this.actions = const [],
    this.suggestions = const [],
    this.confidence = 0.0,
    this.shouldEscalate = false,
  });

  factory ChatAssistantResponse.fromJson(Map<String, dynamic> json) {
    return ChatAssistantResponse(
      content: json['content'] as String? ?? '',
      intent: ChatIntent.fromString(json['intent'] as String?),
      actions: (json['actions'] as List<dynamic>?)
              ?.map((a) => SuggestedAction.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      shouldEscalate: json['shouldEscalate'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        'intent': intent.value,
        'actions': actions.map((a) => a.toJson()).toList(),
        'suggestions': suggestions,
        'confidence': confidence,
        'shouldEscalate': shouldEscalate,
      };

  @override
  List<Object?> get props =>
      [content, intent, actions, suggestions, confidence, shouldEscalate];
}

/// Action suggérée par l'IA
class SuggestedAction extends Equatable {
  final String label;
  final ActionType type;
  final Map<String, dynamic>? payload;

  const SuggestedAction({
    required this.label,
    required this.type,
    this.payload,
  });

  factory SuggestedAction.fromJson(Map<String, dynamic> json) {
    return SuggestedAction(
      label: json['label'] as String? ?? '',
      type: ActionType.fromString(json['type'] as String?),
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'type': type.value,
        if (payload != null) 'payload': payload,
      };

  @override
  List<Object?> get props => [label, type, payload];
}

/// Types d'actions suggérées
enum ActionType {
  booking('booking'),
  viewServices('view_services'),
  viewAvailability('view_availability'),
  contact('contact'),
  viewEquipment('view_equipment'),
  viewLocation('view_location'),
  customMessage('custom_message');

  final String value;
  const ActionType(this.value);

  static ActionType fromString(String? value) {
    return ActionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActionType.customMessage,
    );
  }
}

/// Intentions détectées dans les messages
enum ChatIntent {
  pricing('pricing'),
  availability('availability'),
  booking('booking'),
  equipment('equipment'),
  location('location'),
  cancellation('cancellation'),
  negotiation('negotiation'),
  general('general'),
  humanNeeded('human_needed'),
  greeting('greeting');

  final String value;
  const ChatIntent(this.value);

  static ChatIntent fromString(String? value) {
    return ChatIntent.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChatIntent.general,
    );
  }

  String get displayName {
    switch (this) {
      case ChatIntent.pricing:
        return 'Prix';
      case ChatIntent.availability:
        return 'Disponibilités';
      case ChatIntent.booking:
        return 'Réservation';
      case ChatIntent.equipment:
        return 'Équipements';
      case ChatIntent.location:
        return 'Localisation';
      case ChatIntent.cancellation:
        return 'Annulation';
      case ChatIntent.negotiation:
        return 'Négociation';
      case ChatIntent.general:
        return 'Général';
      case ChatIntent.humanNeeded:
        return 'Contact humain';
      case ChatIntent.greeting:
        return 'Salutation';
    }
  }
}
