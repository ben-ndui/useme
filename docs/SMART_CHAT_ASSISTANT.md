# Smart Chat Assistant - Use Me

## Vision

Deux systèmes IA combinés:

### 1. Assistant Personnel (Artistes)
Une conversation dédiée visible dans la liste des messages:
- Recommandations de studios personnalisées
- Comparaison de prix et services
- Aide à la recherche et réservation
- Toujours disponible

### 2. Suggestions IA (Studios)
Aide cachée pour les studios dans leurs conversations:
- Suggère des réponses aux questions fréquentes
- Répond automatiquement si configuré (auto-reply)
- Personnalisable via FAQs custom

---

## Use Cases Concrets

### Pour un Artiste qui écrit à un Studio

```
Artiste: "C'est combien pour 3h de mix?"

🤖 Assistant: "Le studio propose le Mix & Mastering à 45€/h.
Pour 3h, ça ferait 135€. Voulez-vous réserver un créneau?"

[Voir les dispos] [Parler au studio]
```

### Pour un Studio qui reçoit beaucoup de messages

```
Artiste: "Vous êtes ouverts le dimanche?"

🤖 Assistant (auto-reply): "Le studio est ouvert
Lun-Sam 10h-22h. Fermé le dimanche.
Un membre de l'équipe vous répondra bientôt!"
```

### FAQ automatiques

```
Artiste: "Vous avez quoi comme matos?"

🤖 Assistant: "Le studio dispose de:
• Neumann U87, SM7B, TLM 103
• Apollo x8, SSL Console
• Pro Tools, Logic Pro, Ableton

Voir la liste complète →"
```

### Aide à la réservation

```
Artiste: "Je voudrais réserver pour enregistrer un EP"

🤖 Assistant: "Super projet ! Pour un EP, je vous recommande:
• Session Recording (35€/h) - pour l'enregistrement
• Mix & Mastering (45€/h) - pour la finalisation

Combien de titres prévoyez-vous?"

[3-4 titres] [5-6 titres] [7+ titres]
```

### Négociation de prix

```
Artiste: "C'est un peu cher, vous faites des réductions?"

🤖 Assistant: "Le studio propose:
• -10% pour les sessions de 5h+
• -15% pour les projets complets (EP/Album)
• Pack fidélité après 3 sessions

Voulez-vous que je demande un devis personnalisé?"
```

---

## Architecture Technique

```
┌─────────────────────────────────────────────┐
│                   Chat UI                    │
│  ┌─────────────────────────────────────────┐│
│  │ Message Input                           ││
│  │ [Ask AI 🤖] button                      ││
│  │ Suggested responses chips               ││
│  └─────────────────────────────────────────┘│
├─────────────────────────────────────────────┤
│              ChatAssistantService            │
│  ┌─────────────┐  ┌──────────────────────┐  │
│  │ Intent      │  │ Context Builder      │  │
│  │ Detection   │  │ (studio, services,   │  │
│  │             │  │  availability, user) │  │
│  └─────────────┘  └──────────────────────┘  │
├─────────────────────────────────────────────┤
│           Claude API / Anthropic             │
│  - claude-3-haiku (rapide, économique)      │
│  - claude-3-sonnet (plus intelligent)       │
├─────────────────────────────────────────────┤
│              Cloud Functions                 │
│  - generateChatResponse                      │
│  - Rate limiting (10 req/min/user)          │
│  - Context injection                         │
│  - Response caching                          │
└─────────────────────────────────────────────┘
```

---

## Modes de Fonctionnement

| Mode | Description | Activation | Icône |
|------|-------------|------------|-------|
| **Suggestion** | Suggère une réponse au studio | Studio répond lui-même | 💡 |
| **Auto-Reply** | Répond automatiquement | Studio hors-ligne/occupé | 🤖 |
| **Assistant** | Bot visible dans le chat | Artiste clique "Ask AI" | ✨ |
| **Off** | Désactivé | Studio préfère manuel | ❌ |

### Configuration Studio

```dart
class StudioAISettings {
  bool enableAIAssistant;        // Activer l'assistant
  AIMode mode;                   // suggestion, autoReply, assistant
  int autoReplyDelayMinutes;     // Délai avant auto-reply (ex: 5 min)
  List<String> customFAQs;       // FAQs personnalisées
  String tone;                   // professional, friendly, casual
  bool allowPriceNegotiation;    // Peut discuter des prix
}
```

---

## Données Contextuelles

L'assistant a accès à:

### Informations Studio
- Nom, description, adresse
- Services et tarifs
- Équipements disponibles
- Horaires d'ouverture
- Règles (acompte, annulation)
- FAQs personnalisées

### Informations Artiste
- Nom, genre musical
- Historique de sessions
- Préférences connues

### Conversation
- Messages précédents (contexte)
- Intent détecté
- Langue préférée

---

## Implémentation

### Phase 1: Backend (Cloud Functions)

#### `functions/src/ai/chatAssistant.ts`

```typescript
import Anthropic from '@anthropic-ai/sdk';

interface ChatContext {
  studioId: string;
  studioName: string;
  services: Service[];
  workingHours: WorkingHours;
  equipment: string[];
  faqs: FAQ[];
  conversationHistory: Message[];
  artistName: string;
  artistGenre?: string;
}

export async function generateChatResponse(
  message: string,
  context: ChatContext
): Promise<ChatResponse> {
  const anthropic = new Anthropic();

  const systemPrompt = buildSystemPrompt(context);

  const response = await anthropic.messages.create({
    model: 'claude-3-haiku-20240307',
    max_tokens: 500,
    system: systemPrompt,
    messages: [
      ...context.conversationHistory.map(m => ({
        role: m.isFromStudio ? 'assistant' : 'user',
        content: m.content
      })),
      { role: 'user', content: message }
    ]
  });

  return {
    content: response.content[0].text,
    intent: detectIntent(message),
    suggestedActions: generateActions(response, context),
    confidence: calculateConfidence(response)
  };
}

function buildSystemPrompt(context: ChatContext): string {
  return `Tu es l'assistant IA du studio "${context.studioName}".

INFORMATIONS STUDIO:
- Services: ${context.services.map(s => `${s.name} (${s.price}€/h)`).join(', ')}
- Horaires: ${formatWorkingHours(context.workingHours)}
- Équipements: ${context.equipment.join(', ')}

RÈGLES:
- Réponds de manière concise et professionnelle
- Si tu ne connais pas la réponse, suggère de contacter le studio
- Ne donne jamais de fausses informations
- Propose des actions concrètes (réserver, voir les dispos, etc.)
- Réponds dans la langue de l'utilisateur

FAQs PERSONNALISÉES:
${context.faqs.map(f => `Q: ${f.question}\nR: ${f.answer}`).join('\n\n')}`;
}
```

#### `functions/src/ai/intentDetection.ts`

```typescript
export enum ChatIntent {
  PRICING = 'pricing',
  AVAILABILITY = 'availability',
  BOOKING = 'booking',
  EQUIPMENT = 'equipment',
  LOCATION = 'location',
  CANCELLATION = 'cancellation',
  NEGOTIATION = 'negotiation',
  GENERAL = 'general',
  HUMAN_NEEDED = 'human_needed'
}

export function detectIntent(message: string): ChatIntent {
  const lowerMessage = message.toLowerCase();

  if (lowerMessage.match(/prix|combien|tarif|coût|€|euro/)) {
    return ChatIntent.PRICING;
  }
  if (lowerMessage.match(/dispo|disponible|créneau|quand|horaire/)) {
    return ChatIntent.AVAILABILITY;
  }
  if (lowerMessage.match(/réserv|book|session|rendez-vous/)) {
    return ChatIntent.BOOKING;
  }
  if (lowerMessage.match(/micro|matos|équipement|console|daw/)) {
    return ChatIntent.EQUIPMENT;
  }
  if (lowerMessage.match(/où|adresse|situé|venir|parking/)) {
    return ChatIntent.LOCATION;
  }
  if (lowerMessage.match(/annul|rembours|report/)) {
    return ChatIntent.CANCELLATION;
  }
  if (lowerMessage.match(/réduc|moins cher|négo|remise/)) {
    return ChatIntent.NEGOTIATION;
  }
  if (lowerMessage.match(/parler|humain|quelqu'un|manager/)) {
    return ChatIntent.HUMAN_NEEDED;
  }

  return ChatIntent.GENERAL;
}
```

### Phase 2: Service Flutter

#### `lib/core/services/chat_assistant_service.dart`

```dart
import 'package:cloud_functions/cloud_functions.dart';

class ChatAssistantService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Génère une réponse IA pour un message
  Future<ChatAssistantResponse> generateResponse({
    required String message,
    required String conversationId,
    required String studioId,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateChatResponse');

      final result = await callable.call({
        'message': message,
        'conversationId': conversationId,
        'studioId': studioId,
      });

      return ChatAssistantResponse.fromJson(result.data);
    } catch (e) {
      throw ChatAssistantException('Failed to generate response: $e');
    }
  }

  /// Génère des suggestions de réponses rapides
  Future<List<String>> getSuggestedReplies({
    required String lastMessage,
    required String studioId,
  }) async {
    try {
      final callable = _functions.httpsCallable('getSuggestedReplies');

      final result = await callable.call({
        'lastMessage': lastMessage,
        'studioId': studioId,
      });

      return List<String>.from(result.data['suggestions']);
    } catch (e) {
      return []; // Fail silently, suggestions are optional
    }
  }
}

class ChatAssistantResponse {
  final String content;
  final String intent;
  final List<SuggestedAction> actions;
  final double confidence;
  final bool shouldEscalate;

  ChatAssistantResponse({
    required this.content,
    required this.intent,
    required this.actions,
    required this.confidence,
    required this.shouldEscalate,
  });

  factory ChatAssistantResponse.fromJson(Map<String, dynamic> json) {
    return ChatAssistantResponse(
      content: json['content'],
      intent: json['intent'],
      actions: (json['actions'] as List)
          .map((a) => SuggestedAction.fromJson(a))
          .toList(),
      confidence: json['confidence'].toDouble(),
      shouldEscalate: json['shouldEscalate'] ?? false,
    );
  }
}

class SuggestedAction {
  final String label;
  final String type; // 'booking', 'viewServices', 'contact', etc.
  final Map<String, dynamic>? payload;

  SuggestedAction({
    required this.label,
    required this.type,
    this.payload,
  });

  factory SuggestedAction.fromJson(Map<String, dynamic> json) {
    return SuggestedAction(
      label: json['label'],
      type: json['type'],
      payload: json['payload'],
    );
  }
}
```

### Phase 3: UI Integration

#### Widget: AI Response Bubble

```dart
class AIResponseBubble extends StatelessWidget {
  final ChatAssistantResponse response;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Badge
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
              SizedBox(width: 4),
              Text(
                'Assistant IA',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Response content
          Text(response.content),

          // Action buttons
          if (response.actions.isNotEmpty) ...[
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: response.actions.map((action) {
                return ActionChip(
                  label: Text(action.label),
                  onPressed: () => _handleAction(action),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
```

#### Widget: Suggested Replies

```dart
class SuggestedRepliesBar extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return SizedBox.shrink();

    return Container(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(suggestions[index]),
            onPressed: () => onSelect(suggestions[index]),
          );
        },
      ),
    );
  }
}
```

---

## Sécurité & Rate Limiting

### Rate Limits

| Tier | Requests/min | Requests/day |
|------|--------------|--------------|
| Free | 5 | 50 |
| Pro | 20 | 500 |
| Enterprise | 100 | Unlimited |

### Cloud Function Security

```typescript
// Vérification du rate limit
const rateLimiter = new RateLimiter({
  windowMs: 60 * 1000, // 1 minute
  max: async (userId: string) => {
    const tier = await getUserTier(userId);
    return RATE_LIMITS[tier].perMinute;
  }
});

// Validation des inputs
function validateInput(message: string): void {
  if (message.length > 1000) {
    throw new Error('Message too long');
  }
  if (containsInjection(message)) {
    throw new Error('Invalid input');
  }
}
```

---

## Coûts Estimés

### Claude API Pricing (Haiku)

| Métrique | Valeur |
|----------|--------|
| Input | $0.25 / 1M tokens |
| Output | $1.25 / 1M tokens |

### Estimation Mensuelle

| Scénario | Messages/mois | Coût estimé |
|----------|---------------|-------------|
| 100 studios, 10 msg/jour | 30,000 | ~$5-10 |
| 500 studios, 20 msg/jour | 300,000 | ~$50-100 |
| 1000 studios, 30 msg/jour | 900,000 | ~$150-250 |

---

## Roadmap

### Phase 1: MVP (2 semaines)
- [ ] Cloud Function `generateChatResponse`
- [ ] ChatAssistantService Flutter
- [ ] UI: AI response bubble
- [ ] Settings: Enable/disable AI

### Phase 2: Suggestions (1 semaine)
- [ ] Suggested replies bar
- [ ] Quick actions (booking, services)
- [ ] Intent-based routing

### Phase 3: Auto-Reply (1 semaine)
- [ ] Auto-reply after X minutes
- [ ] Studio offline detection
- [ ] Custom auto-reply messages

### Phase 4: Analytics (1 semaine)
- [ ] Track AI usage
- [ ] Measure response quality
- [ ] A/B testing responses

---

## Configuration Firestore

### Collection: `ai_settings/{studioId}`

```javascript
{
  enabled: true,
  mode: 'suggestion', // 'suggestion' | 'autoReply' | 'assistant'
  autoReplyDelayMinutes: 5,
  tone: 'professional', // 'professional' | 'friendly' | 'casual'
  allowPriceDiscussion: true,
  customFAQs: [
    { question: "Vous faites du mastering?", answer: "Oui, nous proposons..." }
  ],
  excludedTopics: ['politique', 'religion'],
  language: 'fr',
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### Collection: `ai_conversations/{conversationId}/ai_messages`

```javascript
{
  userMessage: "C'est combien pour 3h?",
  aiResponse: "Le mix coûte 45€/h, soit 135€ pour 3h.",
  intent: 'pricing',
  confidence: 0.95,
  wasUsed: true, // Le studio a utilisé la suggestion
  wasEdited: false,
  responseTimeMs: 450,
  createdAt: Timestamp
}
```

---

## Métriques de Succès

| KPI | Objectif | Mesure |
|-----|----------|--------|
| Temps de réponse | < 2s | P95 latency |
| Taux d'utilisation | > 60% | Suggestions utilisées |
| Satisfaction | > 4/5 | Rating post-chat |
| Réduction support | -30% | Tickets/conversations |
| Conversion booking | +15% | Sessions réservées via AI |
