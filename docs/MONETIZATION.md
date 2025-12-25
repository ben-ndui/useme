# Plan de Monétisation - Use Me

## Décisions Validées

- **Modèle principal**: Abonnements Studios
- **Marché**: International (multi-langue, multi-devise)
- **Paiement**: Stripe
- **MVP**: Quick Win (isPartner) + Limites Free Tier
- **Free Tier**: Généreux (20 sessions, 3 salles, 5 services)
- **Pricing**: Agressif (Pro 19€, Enterprise 79€)
- **Admin**: Tiers configurables par SuperAdmin (prix, limites, features)
- **Sécurité**: Config sensible visible UNIQUEMENT par SuperAdmin/DevMaster
- **Clés Stripe**: Configurables via interface dédiée, cryptées AES-256 avant stockage
- **White-Label Ready**: App prête à être déployée/vendue pour d'autres clients

---

## Vision White-Label

L'app est conçue pour être **revendue/déployée** facilement:

| Config | Où | Qui peut modifier |
|--------|-----|-------------------|
| Clés Stripe | `app_config/stripe` | DevMaster |
| Tiers/Prix | `subscription_tiers` | SuperAdmin |
| Branding (logo, couleurs) | `app_config/branding` | SuperAdmin (future) |
| Firebase Config | `app_config/firebase` | DevMaster (future) |
| Limites système | `app_config/limits` | DevMaster |

**Avantage**: Un nouveau client n'a qu'à:
1. Créer son compte Firebase
2. Créer son compte Stripe
3. Se connecter en DevMaster
4. Configurer ses clés via l'interface
5. Personnaliser ses tiers

---

## Stratégie Finale

### Abonnements Studios (3 Tiers)

| Tier | Prix | Limites | Fonctionnalités |
|------|------|---------|-----------------|
| **Free** | 0€ | 20 sessions/mois, 3 salles, 5 services, 3 engineers | Pas de visibilité Discovery, pas d'analytics |
| **Pro** | 19€/mois | Sessions ∞, 10 salles, services ∞, 10 engineers | Visibilité Discovery, analytics basiques, badge vérifié |
| **Enterprise** | 79€/mois | Tout illimité | Multi-studios, analytics avancés, API, support prioritaire |

### Fonctionnalités par Tier

| Feature | Free | Pro | Enterprise |
|---------|------|-----|------------|
| Sessions/mois | 20 | ∞ | ∞ |
| Salles | 3 | 10 | ∞ |
| Services | 5 | ∞ | ∞ |
| Engineers équipe | 3 | 10 | ∞ |
| **Visibilité Discovery** | ❌ | ✅ | ✅ (priorité) |
| Analytics | ❌ | Basiques | Avancés |
| Badge vérifié | ❌ | ✅ | ✅ |
| Multi-studios | ❌ | ❌ | ✅ |
| API Access | ❌ | ❌ | ✅ |
| Support prioritaire | ❌ | ❌ | ✅ |

---

## Plan d'Implémentation MVP

### Phase 1: Quick Wins (Limites + Visibilité)

#### 1.1 Modèle SubscriptionTierConfig (Configurable par SuperAdmin)
Créer `/lib/core/models/subscription_tier_config.dart`:
```dart
class SubscriptionTierConfig extends Equatable {
  final String id; // 'free', 'pro', 'enterprise'
  final String name;
  final String description;
  final double priceMonthly; // 0, 19, 79
  final double priceYearly; // 0, 190, 790
  final int maxSessions; // -1 = illimité
  final int maxRooms;
  final int maxServices;
  final int maxEngineers;
  final bool hasDiscoveryVisibility;
  final bool hasAnalytics;
  final bool hasAdvancedAnalytics;
  final bool hasMultiStudios;
  final bool hasApiAccess;
  final bool hasPrioritySupport;
  final bool isActive;
  final int sortOrder; // Pour l'affichage

  // Firestore: collection 'subscription_tiers'
}
```

#### 1.2 Modèle StudioSubscription (Abonnement d'un studio)
Créer `/lib/core/models/studio_subscription.dart`:
```dart
class StudioSubscription extends Equatable {
  final String tierId; // 'free', 'pro', 'enterprise'
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final String? stripeSubscriptionId;
  final int sessionsThisMonth;
  final DateTime sessionsResetAt; // Reset mensuel

  bool get isActive => expiresAt == null || expiresAt!.isAfter(DateTime.now());
}
```

#### 1.3 Service SubscriptionConfigService (SuperAdmin)
Créer `/lib/core/services/subscription_config_service.dart`:
```dart
class SubscriptionConfigService {
  // Collection: 'subscription_tiers'

  Stream<List<SubscriptionTierConfig>> streamTiers();
  Future<void> updateTier(SubscriptionTierConfig tier);
  Future<SubscriptionTierConfig?> getTier(String tierId);

  // Cache local pour éviter les lectures répétées
  List<SubscriptionTierConfig>? _cachedTiers;
}
```

#### 1.4 Modifier AppUser
Fichier: `/lib/core/models/app_user.dart`
- Ajouter `subscription: StudioSubscription?`
- Ajouter getters: `subscriptionTier`, `canCreateSession`, `canCreateRoom`, etc.

#### 1.5 Limites dans les BloCs
Les limites sont dynamiques (lues depuis SubscriptionTierConfig):

**SessionBloc** (`/lib/core/blocs/session/session_bloc.dart`):
- Dans `_onCreateSession`: comparer `sessionsThisMonth` vs `tierConfig.maxSessions`
- Si limite atteinte → émettre `SessionLimitReachedState`

**StudioRoomBloc** (`/lib/core/blocs/studio_room/studio_room_bloc.dart`):
- Vérifier nombre de salles vs `tierConfig.maxRooms`

**ServiceBloc** (`/lib/core/blocs/service/service_bloc.dart`):
- Vérifier nombre de services vs `tierConfig.maxServices`

#### 1.6 Visibilité Discovery
Fichier: `/lib/core/services/studio_discovery_service.dart`
- Utiliser `tierConfig.hasDiscoveryVisibility` au lieu de `isPartner`
- Ou synchroniser `isPartner = tierConfig.hasDiscoveryVisibility`

#### 1.7 Dashboard SuperAdmin - Configuration Tiers
Créer `/lib/screens/admin/subscription_tiers_screen.dart`:
```dart
// Liste éditable des tiers
// - Modifier prix (mensuel/annuel)
// - Modifier limites (sessions, salles, services, engineers)
// - Activer/désactiver features (analytics, API, etc.)
// - Prévisualisation du pricing table
```

#### 1.8 Configuration Stripe Sécurisée (DevMaster Only)
Créer `/lib/screens/admin/stripe_config_screen.dart`:
```dart
// UNIQUEMENT visible pour role == devMaster
// Interface pour configurer:
// - Stripe Publishable Key (pk_live_xxx ou pk_test_xxx)
// - Stripe Secret Key (sk_live_xxx ou sk_test_xxx) → cryptée AES-256
// - Webhook Secret (whsec_xxx) → crypté AES-256
// - Mode: test ou live (switch)
// - Price IDs pour chaque tier (price_xxx)
```

#### 1.9 Modèle StripeConfig
Créer `/lib/core/models/stripe_config.dart`:
```dart
class StripeConfig extends Equatable {
  final String publishableKey;        // pk_xxx (public, pas crypté)
  final String encryptedSecretKey;    // Crypté AES-256
  final String encryptedWebhookSecret; // Crypté AES-256
  final bool isLiveMode;              // true = prod, false = test
  final Map<String, String> priceIds; // { 'pro_monthly': 'price_xxx', ... }
  final DateTime updatedAt;
  final String updatedBy;             // userId du devMaster

  // Firestore: collection 'app_config' doc 'stripe'
  // Règles de sécurité: lecture/écriture UNIQUEMENT role == devMaster
}
```

#### 1.10 Service StripeConfigService
Créer `/lib/core/services/stripe_config_service.dart`:
```dart
class StripeConfigService {
  final EncryptionService _encryption;

  // Récupérer config (déchiffre les clés sensibles)
  Future<StripeConfig?> getConfig();

  // Sauvegarder config (chiffre les clés sensibles avant stockage)
  Future<void> saveConfig(StripeConfig config);

  // Valider les clés (test API call)
  Future<bool> validateKeys(String publishableKey, String secretKey);
}
```

#### 1.11 Rôle DevMaster
Modifier `/lib/core/models/app_user.dart`:
```dart
// Ajouter role 'devMaster' ou champ isDevMaster
// DevMaster = SuperAdmin + accès config Stripe + config système

bool get isDevMaster => role == BaseUserRole.devMaster;
// OU
bool get isDevMaster => isSuperAdmin && _isDevMaster;
```

---

### Phase 2: UI Upgrade

#### 2.1 Paywall Screen
Créer `/lib/screens/shared/upgrade_screen.dart`:
- Afficher les 3 tiers avec comparaison
- Boutons "Choisir ce plan"
- Design attractif avec highlights sur Pro

#### 2.2 Limite Atteinte Dialog
Créer `/lib/widgets/common/limit_reached_dialog.dart`:
- Message expliquant la limite
- CTA vers upgrade
- Option "Plus tard"

#### 2.3 Settings - Section Abonnement
Modifier `/lib/screens/studio/studio_settings_page.dart`:
- Afficher tier actuel
- Bouton "Gérer mon abonnement"
- Usage actuel (X/20 sessions ce mois)

---

### Phase 3: Stripe Integration

#### 3.1 Stripe Service
Créer `/lib/core/services/stripe_service.dart`:
- Initialisation Stripe
- Création PaymentSheet
- Gestion abonnements

#### 3.2 Cloud Functions
Dans `/smoothbackend`:
- `createCheckoutSession` - Créer session Stripe
- `handleStripeWebhook` - Gérer events (subscription.created, cancelled, etc.)
- `updateSubscription` - Mettre à jour Firestore

#### 3.3 Price IDs Stripe
```
price_pro_monthly: 19€/mois
price_pro_yearly: 190€/an (2 mois gratuits)
price_enterprise_monthly: 79€/mois
price_enterprise_yearly: 790€/an (2 mois gratuits)
```

---

## Fichiers à Créer/Modifier

### Nouveaux Fichiers
```
# Modèles
lib/core/models/subscription_tier_config.dart  # Config des tiers (SuperAdmin)
lib/core/models/studio_subscription.dart       # Abonnement d'un studio
lib/core/models/stripe_config.dart             # Config Stripe cryptée (DevMaster)

# Services
lib/core/services/subscription_config_service.dart # CRUD tiers (SuperAdmin)
lib/core/services/subscription_service.dart        # Gestion abonnements studios
lib/core/services/stripe_config_service.dart       # Config Stripe cryptée (DevMaster)
lib/core/services/stripe_service.dart              # Intégration Stripe payments

# BloC
lib/core/blocs/subscription/
  ├── subscription_bloc.dart
  ├── subscription_event.dart
  ├── subscription_state.dart
  └── subscription_exports.dart

# Screens Admin (SuperAdmin/DevMaster)
lib/screens/admin/subscription_tiers_screen.dart   # Config tiers (SuperAdmin)
lib/screens/admin/stripe_config_screen.dart        # Config clés Stripe (DevMaster ONLY)
lib/screens/admin/admin_dashboard_screen.dart      # Dashboard admin central

# Screens Shared
lib/screens/shared/upgrade_screen.dart             # Page upgrade/pricing

# Widgets
lib/widgets/common/limit_reached_dialog.dart       # Dialog limite atteinte
lib/widgets/admin/tier_config_card.dart            # Carte config tier
lib/widgets/admin/stripe_key_field.dart            # Champ clé masqué/révélé
```

### Fichiers à Modifier
```
lib/core/models/app_user.dart                      # Ajouter champ subscription
lib/core/models/models_exports.dart                # Exporter nouveaux modèles
lib/core/services/services_exports.dart            # Exporter nouveaux services
lib/core/blocs/blocs_exports.dart                  # Exporter nouveau BloC
lib/core/blocs/session/session_bloc.dart           # Check limite sessions
lib/core/blocs/studio_room/studio_room_bloc.dart   # Check limite salles
lib/core/blocs/service/service_bloc.dart           # Check limite services
lib/screens/studio/studio_settings_page.dart       # Section abonnement
lib/screens/admin/studio_claims_screen.dart        # Ajouter nav vers tiers
lib/routing/router.dart                            # Routes upgrade + admin tiers
lib/main.dart                                      # Init Stripe
```

### Collection Firestore
```
subscription_tiers/           # Config des tiers (géré par SuperAdmin)
  ├── free
  ├── pro
  └── enterprise

app_config/                   # Config système (DevMaster only)
  └── stripe: {
        publishableKey: 'pk_xxx',
        encryptedSecretKey: 'encrypted...',
        encryptedWebhookSecret: 'encrypted...',
        isLiveMode: false,
        priceIds: { ... },
        updatedAt: timestamp,
        updatedBy: 'userId'
      }

users/{userId}/               # Champ subscription ajouté
  └── subscription: {
        tierId: 'free',
        startedAt: timestamp,
        expiresAt: timestamp | null,
        stripeSubscriptionId: string | null,
        sessionsThisMonth: number,
        sessionsResetAt: timestamp
      }
```

---

## Revenue Projections

**Hypothèses**: 100 studios après 6 mois

| Source | Calcul | Revenu Mensuel |
|--------|--------|----------------|
| Free (60%) | 60 studios × 0€ | 0€ |
| Pro (30%) | 30 × 19€ | 570€ |
| Enterprise (10%) | 10 × 79€ | 790€ |
| **Total** | | **~1,360€/mois** |

Avec 500 studios (objectif 1 an):
- Pro (35%): 175 × 19€ = **3,325€**
- Enterprise (15%): 75 × 79€ = **5,925€**
- **Total: ~9,250€/mois**

---

## Prochaines Étapes Futures

### Après le MVP
1. **Analytics Dashboard** (Pro/Enterprise)
2. **Featured Placement** (achat ponctuel)
3. **Commission sur paiements** (optionnel, Stripe Connect)
4. **Abonnement Artistes** (4.99€/14.99€)
5. **Marketplace Engineers**

---

## Analyse Complète des Features Existantes

### Services Identifiés (25)
- SessionService, BookingService, EngineerProposalService, BookingAcceptanceService
- AvailabilityService, UnavailabilityService, EngineerAvailabilityService
- ServiceCatalogService, StudioRoomService, ArtistService, TeamService
- StudioDiscoveryService, StudioClaimService
- NotificationService, ContactService
- PaymentConfigService (avec encryption AES-256)
- FavoriteService, NotificationNavigationService, ProfilePhotoService, EncryptionService

### Workflow Session
```
1. Artist books → Session (pending)
2. Studio accepts → Session (confirmed) + Engineer assignment
3. Engineer check-in → Session (inProgress)
4. Check-out → Session (completed)
```

### Payment Methods Supportés
- Cash, Bank Transfer (IBAN/BIC), PayPal, Card, Other
- Encryption AES-256 pour données sensibles
- Cloud Function pour génération sécurisée des messages de paiement
