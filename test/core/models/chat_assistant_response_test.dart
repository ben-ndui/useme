import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/models/chat_assistant_response.dart';

void main() {
  group('ChatIntent', () {
    test('fromString parses valid intents', () {
      expect(ChatIntent.fromString('pricing'), ChatIntent.pricing);
      expect(ChatIntent.fromString('availability'), ChatIntent.availability);
      expect(ChatIntent.fromString('booking'), ChatIntent.booking);
      expect(ChatIntent.fromString('equipment'), ChatIntent.equipment);
      expect(ChatIntent.fromString('location'), ChatIntent.location);
      expect(ChatIntent.fromString('cancellation'), ChatIntent.cancellation);
      expect(ChatIntent.fromString('negotiation'), ChatIntent.negotiation);
      expect(ChatIntent.fromString('general'), ChatIntent.general);
      expect(ChatIntent.fromString('human_needed'), ChatIntent.humanNeeded);
      expect(ChatIntent.fromString('greeting'), ChatIntent.greeting);
    });

    test('fromString defaults to general', () {
      expect(ChatIntent.fromString(null), ChatIntent.general);
      expect(ChatIntent.fromString('unknown'), ChatIntent.general);
    });

    test('displayName is not empty for all intents', () {
      for (final intent in ChatIntent.values) {
        expect(intent.displayName, isNotEmpty);
      }
    });

    test('specific displayNames', () {
      expect(ChatIntent.pricing.displayName, 'Prix');
      expect(ChatIntent.booking.displayName, 'Réservation');
      expect(ChatIntent.humanNeeded.displayName, 'Contact humain');
    });
  });

  group('ActionType', () {
    test('fromString parses valid types', () {
      expect(ActionType.fromString('booking'), ActionType.booking);
      expect(
          ActionType.fromString('view_services'), ActionType.viewServices);
      expect(ActionType.fromString('view_availability'),
          ActionType.viewAvailability);
      expect(ActionType.fromString('contact'), ActionType.contact);
      expect(ActionType.fromString('custom_message'),
          ActionType.customMessage);
    });

    test('fromString defaults to customMessage', () {
      expect(ActionType.fromString(null), ActionType.customMessage);
      expect(ActionType.fromString('unknown'), ActionType.customMessage);
    });
  });

  group('SuggestedAction', () {
    test('fromJson parses all fields', () {
      final action = SuggestedAction.fromJson({
        'label': 'Réserver',
        'type': 'booking',
        'payload': {'serviceId': 'svc-1'},
      });
      expect(action.label, 'Réserver');
      expect(action.type, ActionType.booking);
      expect(action.payload, {'serviceId': 'svc-1'});
    });

    test('fromJson handles missing fields', () {
      final action = SuggestedAction.fromJson({});
      expect(action.label, '');
      expect(action.type, ActionType.customMessage);
      expect(action.payload, isNull);
    });

    test('toJson round-trip', () {
      const action = SuggestedAction(
        label: 'Voir services',
        type: ActionType.viewServices,
      );
      final json = action.toJson();
      final restored = SuggestedAction.fromJson(json);
      expect(restored, equals(action));
    });

    test('toJson omits null payload', () {
      const action = SuggestedAction(
        label: 'L',
        type: ActionType.contact,
      );
      final json = action.toJson();
      expect(json.containsKey('payload'), isFalse);
    });

    test('toJson includes payload when present', () {
      const action = SuggestedAction(
        label: 'L',
        type: ActionType.booking,
        payload: {'key': 'value'},
      );
      final json = action.toJson();
      expect(json['payload'], {'key': 'value'});
    });
  });

  group('ChatAssistantResponse', () {
    test('fromJson parses all fields', () {
      final response = ChatAssistantResponse.fromJson({
        'content': 'Bonjour ! Comment puis-je vous aider ?',
        'intent': 'greeting',
        'actions': [
          {'label': 'Réserver', 'type': 'booking'},
        ],
        'suggestions': ['Voir les tarifs', 'Disponibilités'],
        'confidence': 0.95,
        'shouldEscalate': false,
      });

      expect(response.content, 'Bonjour ! Comment puis-je vous aider ?');
      expect(response.intent, ChatIntent.greeting);
      expect(response.actions.length, 1);
      expect(response.actions.first.label, 'Réserver');
      expect(response.suggestions, ['Voir les tarifs', 'Disponibilités']);
      expect(response.confidence, 0.95);
      expect(response.shouldEscalate, isFalse);
    });

    test('fromJson handles missing fields', () {
      final response = ChatAssistantResponse.fromJson({});
      expect(response.content, '');
      expect(response.intent, ChatIntent.general);
      expect(response.actions, isEmpty);
      expect(response.suggestions, isEmpty);
      expect(response.confidence, 0.0);
      expect(response.shouldEscalate, isFalse);
    });

    test('toJson round-trip', () {
      const response = ChatAssistantResponse(
        content: 'Test',
        intent: ChatIntent.pricing,
        confidence: 0.8,
        shouldEscalate: true,
        suggestions: ['A', 'B'],
      );
      final json = response.toJson();
      final restored = ChatAssistantResponse.fromJson(json);
      expect(restored, equals(response));
    });

    test('defaults', () {
      const response = ChatAssistantResponse(
        content: 'Hi',
        intent: ChatIntent.general,
      );
      expect(response.actions, isEmpty);
      expect(response.suggestions, isEmpty);
      expect(response.confidence, 0.0);
      expect(response.shouldEscalate, isFalse);
    });
  });
}
