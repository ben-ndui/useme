import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/models/studio_ai_settings.dart';

void main() {
  group('AIMode', () {
    test('fromString parses valid modes', () {
      expect(AIMode.fromString('suggestion'), AIMode.suggestion);
      expect(AIMode.fromString('auto_reply'), AIMode.autoReply);
      expect(AIMode.fromString('assistant'), AIMode.assistant);
      expect(AIMode.fromString('off'), AIMode.off);
    });

    test('fromString defaults to suggestion', () {
      expect(AIMode.fromString(null), AIMode.suggestion);
      expect(AIMode.fromString('unknown'), AIMode.suggestion);
    });

    test('displayName returns localized label', () {
      expect(AIMode.suggestion.displayName, 'Suggestions');
      expect(AIMode.autoReply.displayName, isNotEmpty);
      expect(AIMode.assistant.displayName, 'Assistant');
      expect(AIMode.off.displayName, isNotEmpty);
    });

    test('description is not empty for all modes', () {
      for (final mode in AIMode.values) {
        expect(mode.description, isNotEmpty);
      }
    });

    test('icon is not empty for all modes', () {
      for (final mode in AIMode.values) {
        expect(mode.icon, isNotEmpty);
      }
    });

    test('value returns serializable string', () {
      expect(AIMode.suggestion.value, 'suggestion');
      expect(AIMode.autoReply.value, 'auto_reply');
      expect(AIMode.assistant.value, 'assistant');
      expect(AIMode.off.value, 'off');
    });
  });

  group('CustomFAQ', () {
    test('fromJson parses fields', () {
      final faq = CustomFAQ.fromJson({
        'question': 'Horaires ?',
        'answer': '9h-18h',
      });
      expect(faq.question, 'Horaires ?');
      expect(faq.answer, '9h-18h');
    });

    test('fromJson handles missing fields', () {
      final faq = CustomFAQ.fromJson({});
      expect(faq.question, '');
      expect(faq.answer, '');
    });

    test('toJson round-trip', () {
      const faq = CustomFAQ(question: 'Q', answer: 'A');
      final json = faq.toJson();
      final restored = CustomFAQ.fromJson(json);
      expect(restored, equals(faq));
    });
  });

  group('StudioAISettings', () {
    test('defaults', () {
      const settings = StudioAISettings(studioId: 's1');
      expect(settings.enabled, isFalse);
      expect(settings.mode, AIMode.suggestion);
      expect(settings.autoReplyDelayMinutes, 5);
      expect(settings.tone, 'professional');
      expect(settings.allowPriceDiscussion, isTrue);
      expect(settings.customFAQs, isEmpty);
      expect(settings.excludedTopics, isEmpty);
      expect(settings.language, 'fr');
    });

    test('empty factory sets studioId', () {
      final settings = StudioAISettings.empty('studio-123');
      expect(settings.studioId, 'studio-123');
      expect(settings.enabled, isFalse);
      expect(settings.createdAt, isNotNull);
      expect(settings.updatedAt, isNotNull);
    });

    test('fromJson parses all fields', () {
      final settings = StudioAISettings.fromJson({
        'enabled': true,
        'mode': 'auto_reply',
        'autoReplyDelayMinutes': 10,
        'tone': 'friendly',
        'allowPriceDiscussion': false,
        'customFAQs': [
          {'question': 'Q1', 'answer': 'A1'},
        ],
        'excludedTopics': ['pricing', 'competitors'],
        'language': 'en',
      }, 'studio-1');

      expect(settings.studioId, 'studio-1');
      expect(settings.enabled, isTrue);
      expect(settings.mode, AIMode.autoReply);
      expect(settings.autoReplyDelayMinutes, 10);
      expect(settings.tone, 'friendly');
      expect(settings.allowPriceDiscussion, isFalse);
      expect(settings.customFAQs.length, 1);
      expect(settings.customFAQs.first.question, 'Q1');
      expect(settings.excludedTopics, ['pricing', 'competitors']);
      expect(settings.language, 'en');
    });

    test('fromJson handles missing fields with defaults', () {
      final settings = StudioAISettings.fromJson({}, 'studio-1');
      expect(settings.enabled, isFalse);
      expect(settings.mode, AIMode.suggestion);
      expect(settings.autoReplyDelayMinutes, 5);
      expect(settings.tone, 'professional');
      expect(settings.allowPriceDiscussion, isTrue);
      expect(settings.customFAQs, isEmpty);
      expect(settings.excludedTopics, isEmpty);
      expect(settings.language, 'fr');
    });

    test('copyWith modifies specified fields', () {
      const original = StudioAISettings(
        studioId: 's1',
        enabled: false,
        mode: AIMode.suggestion,
      );
      final modified = original.copyWith(
        enabled: true,
        mode: AIMode.autoReply,
        tone: 'casual',
      );
      expect(modified.enabled, isTrue);
      expect(modified.mode, AIMode.autoReply);
      expect(modified.tone, 'casual');
      expect(modified.studioId, 's1'); // unchanged
      expect(modified.language, 'fr'); // unchanged
    });

    test('copyWith sets updatedAt', () {
      const original = StudioAISettings(studioId: 's1');
      final modified = original.copyWith(enabled: true);
      expect(modified.updatedAt, isNotNull);
    });
  });
}
