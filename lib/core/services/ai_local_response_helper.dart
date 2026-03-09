import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/chat_assistant_response.dart';
import 'package:useme/core/services/ai_response_texts.dart';
import 'package:useme/core/services/chat_assistant_service.dart';

/// Generates local AI responses as fallback when Cloud Function fails.
/// Also provides welcome messages and suggestions based on user role.
class AILocalResponseHelper {
  final ChatAssistantService _aiService;
  final BaseUserRole? userRole;
  late final AIResponseTexts _texts;

  AILocalResponseHelper({
    required ChatAssistantService aiService,
    required this.userRole,
  }) : _aiService = aiService {
    _texts = AIResponseTexts(
      isStudio: _isStudio,
      isEngineer: _isEngineer,
    );
  }

  bool get _isStudio =>
      userRole == BaseUserRole.admin || userRole == BaseUserRole.superAdmin;
  bool get _isEngineer => userRole == BaseUserRole.worker;

  String getWelcomeMessage() => _texts.getWelcomeMessage();

  List<String> getInitialSuggestions() => _texts.getInitialSuggestions();

  ChatAssistantResponse generateLocalResponse(String message) {
    final intent = _aiService.detectIntentLocally(message);

    String response;
    List<SuggestedAction> actions = [];

    switch (intent) {
      case ChatIntent.pricing:
        response = _texts.getPricingResponse();
        actions = [
          const SuggestedAction(
            label: 'Voir les studios',
            type: ActionType.viewServices,
          ),
        ];
        break;
      case ChatIntent.availability:
        response = _texts.getAvailabilityResponse();
        actions = [
          const SuggestedAction(
            label: 'Explorer les studios',
            type: ActionType.viewAvailability,
          ),
        ];
        break;
      case ChatIntent.booking:
        response = _texts.getBookingResponse();
        actions = [
          const SuggestedAction(
            label: 'Réserver',
            type: ActionType.booking,
          ),
        ];
        break;
      case ChatIntent.equipment:
        response = _texts.getEquipmentResponse();
        break;
      case ChatIntent.greeting:
        response = _texts.getGreetingResponse();
        break;
      default:
        response = _texts.getDefaultResponse(message);
    }

    return ChatAssistantResponse(
      content: response,
      intent: intent,
      actions: actions,
      confidence: 0.85,
    );
  }

  List<String> generateFollowUpSuggestions(ChatIntent intent) {
    if (_isStudio) {
      return _studioFollowUps(intent);
    } else if (_isEngineer) {
      return [
        'Mes prochaines sessions',
        'Gérer mes dispos',
        'Contacter le studio',
      ];
    }
    return _artistFollowUps(intent);
  }

  List<String> _studioFollowUps(ChatIntent intent) {
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
  }

  List<String> _artistFollowUps(ChatIntent intent) {
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
}
