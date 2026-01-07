import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Configuration IA pour un studio
class StudioAISettings extends Equatable {
  final String studioId;
  final bool enabled;
  final AIMode mode;
  final int autoReplyDelayMinutes;
  final String tone;
  final bool allowPriceDiscussion;
  final List<CustomFAQ> customFAQs;
  final List<String> excludedTopics;
  final String language;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudioAISettings({
    required this.studioId,
    this.enabled = false,
    this.mode = AIMode.suggestion,
    this.autoReplyDelayMinutes = 5,
    this.tone = 'professional',
    this.allowPriceDiscussion = true,
    this.customFAQs = const [],
    this.excludedTopics = const [],
    this.language = 'fr',
    this.createdAt,
    this.updatedAt,
  });

  factory StudioAISettings.empty(String studioId) => StudioAISettings(
        studioId: studioId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  factory StudioAISettings.fromJson(Map<String, dynamic> json, String studioId) {
    return StudioAISettings(
      studioId: studioId,
      enabled: json['enabled'] as bool? ?? false,
      mode: AIMode.fromString(json['mode'] as String?),
      autoReplyDelayMinutes: json['autoReplyDelayMinutes'] as int? ?? 5,
      tone: json['tone'] as String? ?? 'professional',
      allowPriceDiscussion: json['allowPriceDiscussion'] as bool? ?? true,
      customFAQs: (json['customFAQs'] as List<dynamic>?)
              ?.map((f) => CustomFAQ.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      excludedTopics: (json['excludedTopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      language: json['language'] as String? ?? 'fr',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'mode': mode.value,
        'autoReplyDelayMinutes': autoReplyDelayMinutes,
        'tone': tone,
        'allowPriceDiscussion': allowPriceDiscussion,
        'customFAQs': customFAQs.map((f) => f.toJson()).toList(),
        'excludedTopics': excludedTopics,
        'language': language,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  StudioAISettings copyWith({
    bool? enabled,
    AIMode? mode,
    int? autoReplyDelayMinutes,
    String? tone,
    bool? allowPriceDiscussion,
    List<CustomFAQ>? customFAQs,
    List<String>? excludedTopics,
    String? language,
  }) {
    return StudioAISettings(
      studioId: studioId,
      enabled: enabled ?? this.enabled,
      mode: mode ?? this.mode,
      autoReplyDelayMinutes: autoReplyDelayMinutes ?? this.autoReplyDelayMinutes,
      tone: tone ?? this.tone,
      allowPriceDiscussion: allowPriceDiscussion ?? this.allowPriceDiscussion,
      customFAQs: customFAQs ?? this.customFAQs,
      excludedTopics: excludedTopics ?? this.excludedTopics,
      language: language ?? this.language,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        studioId,
        enabled,
        mode,
        autoReplyDelayMinutes,
        tone,
        allowPriceDiscussion,
        customFAQs,
        excludedTopics,
        language,
      ];
}

/// Modes de fonctionnement de l'IA
enum AIMode {
  /// Suggère des réponses au studio (ne répond pas automatiquement)
  suggestion('suggestion'),

  /// Répond automatiquement après un délai si le studio ne répond pas
  autoReply('auto_reply'),

  /// Assistant visible dans le chat (l'artiste peut poser des questions à l'IA)
  assistant('assistant'),

  /// IA désactivée
  off('off');

  final String value;
  const AIMode(this.value);

  static AIMode fromString(String? value) {
    return AIMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AIMode.suggestion,
    );
  }

  String get displayName {
    switch (this) {
      case AIMode.suggestion:
        return 'Suggestions';
      case AIMode.autoReply:
        return 'Réponse auto';
      case AIMode.assistant:
        return 'Assistant';
      case AIMode.off:
        return 'Désactivé';
    }
  }

  String get description {
    switch (this) {
      case AIMode.suggestion:
        return 'L\'IA suggère des réponses que vous pouvez modifier';
      case AIMode.autoReply:
        return 'L\'IA répond automatiquement si vous ne répondez pas';
      case AIMode.assistant:
        return 'Les artistes peuvent poser des questions à l\'IA';
      case AIMode.off:
        return 'L\'IA est désactivée';
    }
  }

  String get icon {
    switch (this) {
      case AIMode.suggestion:
        return '💡';
      case AIMode.autoReply:
        return '🤖';
      case AIMode.assistant:
        return '✨';
      case AIMode.off:
        return '❌';
    }
  }
}

/// FAQ personnalisée
class CustomFAQ extends Equatable {
  final String question;
  final String answer;

  const CustomFAQ({
    required this.question,
    required this.answer,
  });

  factory CustomFAQ.fromJson(Map<String, dynamic> json) {
    return CustomFAQ(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };

  @override
  List<Object?> get props => [question, answer];
}
