import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uzme/core/models/chat_assistant_response.dart';
import 'package:uzme/core/services/chat_assistant_service.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockFunctions extends Mock implements FirebaseFunctions {}

void main() {
  late ChatAssistantService service;

  setUp(() {
    service = ChatAssistantService(
      firestore: MockFirestore(),
      functions: MockFunctions(),
    );
  });

  group('detectIntentLocally', () {
    group('greeting', () {
      test('detects salut', () {
        expect(
            service.detectIntentLocally('Salut !'), ChatIntent.greeting);
      });

      test('detects bonjour', () {
        expect(service.detectIntentLocally('Bonjour, je suis DJ Test'),
            ChatIntent.greeting);
      });

      test('detects hello', () {
        expect(service.detectIntentLocally('Hello'), ChatIntent.greeting);
      });

      test('detects coucou', () {
        expect(
            service.detectIntentLocally('coucou !'), ChatIntent.greeting);
      });
    });

    group('pricing', () {
      test('detects prix', () {
        expect(service.detectIntentLocally('Quel est le prix ?'),
            ChatIntent.pricing);
      });

      test('detects combien', () {
        expect(
            service.detectIntentLocally('Combien coûte une session ?'),
            ChatIntent.pricing);
      });

      test('detects tarif', () {
        expect(service.detectIntentLocally('Quels sont vos tarifs ?'),
            ChatIntent.pricing);
      });

      test('detects euro symbol', () {
        expect(service.detectIntentLocally('C\'est 50€ la session ?'),
            ChatIntent.pricing);
      });
    });

    group('availability', () {
      test('detects dispo', () {
        expect(
            service.detectIntentLocally('T\'es dispo samedi ?'),
            ChatIntent.availability);
      });

      test('detects créneau', () {
        expect(
            service.detectIntentLocally('Y a un créneau libre ?'),
            ChatIntent.availability);
      });

      test('detects horaire', () {
        expect(
            service.detectIntentLocally('Quels sont vos horaires ?'),
            ChatIntent.availability);
      });
    });

    group('booking', () {
      test('detects réserver', () {
        expect(
            service.detectIntentLocally('Je veux réserver une session'),
            ChatIntent.booking);
      });

      test('detects session', () {
        expect(
            service.detectIntentLocally('Comment booker une session ?'),
            ChatIntent.booking);
      });
    });

    group('equipment', () {
      test('detects micro', () {
        expect(
            service.detectIntentLocally('Vous avez quel micro ?'),
            ChatIntent.equipment);
      });

      test('detects matos', () {
        expect(
            service.detectIntentLocally('C\'est quoi le matos ?'),
            ChatIntent.equipment);
      });

      test('detects DAW', () {
        expect(
            service.detectIntentLocally('Vous bossez sur quel daw ?'),
            ChatIntent.equipment);
      });
    });

    group('location', () {
      test('detects où', () {
        expect(
            service.detectIntentLocally('Vous êtes où ?'),
            ChatIntent.location);
      });

      test('detects adresse', () {
        expect(
            service.detectIntentLocally('C\'est quoi l\'adresse ?'),
            ChatIntent.location);
      });

      test('detects parking', () {
        expect(
            service.detectIntentLocally('Y a un parking ?'),
            ChatIntent.location);
      });
    });

    group('cancellation', () {
      test('detects annuler', () {
        expect(
            service.detectIntentLocally('Je veux annuler'),
            ChatIntent.cancellation);
      });

      test('detects rembourser', () {
        expect(
            service.detectIntentLocally('Je peux me faire rembourser ?'),
            ChatIntent.cancellation);
      });

      test('detects décaler', () {
        expect(
            service.detectIntentLocally('On peut décaler à lundi ?'),
            ChatIntent.cancellation);
      });
    });

    group('negotiation', () {
      test('detects réduction', () {
        expect(
            service.detectIntentLocally('Y a une réduction possible ?'),
            ChatIntent.negotiation);
      });

      test('detects négo', () {
        expect(
            service.detectIntentLocally('On peut négo le montant ?'),
            ChatIntent.negotiation);
      });

      test('detects promotion', () {
        expect(
            service.detectIntentLocally('Vous faites des promotions ?'),
            ChatIntent.negotiation);
      });
    });

    group('humanNeeded', () {
      test('detects parler à quelqu\'un', () {
        expect(
            service.detectIntentLocally('Je veux parler à quelqu\'un'),
            ChatIntent.humanNeeded);
      });

      test('detects responsable', () {
        expect(
            service.detectIntentLocally('Je peux voir le responsable ?'),
            ChatIntent.humanNeeded);
      });
    });

    group('general', () {
      test('returns general for unmatched messages', () {
        expect(
            service.detectIntentLocally('Merci beaucoup'),
            ChatIntent.general);
      });

      test('returns general for empty string', () {
        expect(
            service.detectIntentLocally(''), ChatIntent.general);
      });

      test('returns general for random text', () {
        expect(
            service.detectIntentLocally('abc xyz 123'),
            ChatIntent.general);
      });
    });

    group('case insensitivity', () {
      test('detects uppercase', () {
        expect(
            service.detectIntentLocally('BONJOUR'),
            ChatIntent.greeting);
      });

      test('detects mixed case', () {
        expect(
            service.detectIntentLocally('Quel est le PRIX ?'),
            ChatIntent.pricing);
      });
    });

    group('priority (first match wins)', () {
      test('greeting takes priority over other intents', () {
        // "salut" matches greeting, even if other patterns exist
        expect(
            service.detectIntentLocally('Salut, c\'est combien ?'),
            ChatIntent.greeting);
      });
    });
  });

  group('ChatAssistantException', () {
    test('toString includes message', () {
      final e = ChatAssistantException('Test error', code: 'NOT_FOUND');
      expect(e.toString(), 'ChatAssistantException: Test error');
      expect(e.message, 'Test error');
      expect(e.code, 'NOT_FOUND');
    });

    test('code is optional', () {
      final e = ChatAssistantException('Error');
      expect(e.code, isNull);
    });
  });
}
