# UZME Subscription Pricing

## Plans

### Free
- **Prix** : Gratuit
- **Description** : Pour démarrer
- **Sessions** : 20 / mois
- **Rooms** : 3
- **Services** : 5
- **Ingénieurs** : 3
- **AI Assistant** : 50 messages / mois
- Pas de visibilité Discovery
- Pas d'analytics
- Pas de badge vérifié

### Pro
- **Prix** : 19€ / mois | 190€ / an (2 mois offerts)
- **Description** : Pour les studios actifs
- **Sessions** : Illimitées
- **Rooms** : 10
- **Services** : Illimités
- **Ingénieurs** : 10
- **AI Assistant** : 500 messages / mois (AI avancée)
- Visibilité Discovery
- Analytics de base
- Badge vérifié

### Enterprise
- **Prix** : 79€ / mois | 790€ / an (2 mois offerts)
- **Description** : Pour les grands studios
- **Sessions** : Illimitées
- **Rooms** : Illimitées
- **Services** : Illimités
- **Ingénieurs** : Illimités
- **AI Assistant** : Illimité (AI avancée)
- Visibilité Discovery
- Analytics avancées
- Multi-studios
- Accès API
- Support prioritaire
- Badge vérifié

## Apple IAP Product IDs

| Plan | Product ID |
|------|-----------|
| Pro Mensuel | `com.smoothandesign.useme.pro.monthly` |
| Pro Annuel | `com.smoothandesign.useme.pro.yearly` |
| Enterprise Mensuel | `com.smoothandesign.useme.enterprise.monthly` |
| Enterprise Annuel | `com.smoothandesign.useme.enterprise.yearly` |

**Subscription Group** : `UZME Pro Plans`

**Upgrade levels** (1 = plus premium) :
1. Enterprise Yearly
2. Enterprise Monthly
3. Pro Yearly
4. Pro Monthly

## Sources de prix

| Plateforme | Source |
|------------|--------|
| iOS | Apple StoreKit (prix définis dans App Store Connect) |
| Android / Web | Stripe (prix définis via Firestore `subscription_tiers`) |
| Fallback | Hardcodé dans `SubscriptionTierConfig` defaults |

## Firestore

- **Collection** : `subscription_tiers`
- **Documents** : `free`, `pro`, `enterprise`
- **Champs prix** : `priceMonthly`, `priceYearly`

## Fichiers clés

| Fichier | Rôle |
|---------|------|
| `lib/core/models/subscription_tier_config.dart` | Modèle + defaults hardcodés |
| `lib/core/services/iap_service.dart` | Service IAP Apple (StoreKit) |
| `lib/core/services/stripe_service.dart` | Service Stripe (Android/Web) |
| `lib/core/services/subscription_config_service.dart` | Lecture Firestore |
| `lib/screens/shared/upgrade_screen.dart` | Écran de choix d'offre |
| `lib/screens/shared/upgrade_screen_actions.dart` | Logique d'achat (mixin) |
| `lib/widgets/studio/upgrade/tier_pricing_card.dart` | Card d'affichage prix |
| `lib/widgets/studio/settings/subscription_section.dart` | Section Settings |
