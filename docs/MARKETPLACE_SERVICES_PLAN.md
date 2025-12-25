# Services Marketplace - Plan d'Implementation

> **Status**: IDEA / BACKLOG
> **Date**: 2025-12-24
> **Priority**: Future Feature

## Vision

Transformer Use Me en plateforme créative complète avec un marketplace de services freelance (Design/Artwork + Production musicale) avec commission de 10%.

---

## Décisions Prises

| Aspect | Décision |
|--------|----------|
| **Profils** | Hybrides (artiste peut aussi être designer) |
| **Commission** | 10% sur chaque transaction |
| **Validation** | Manuelle par l'équipe Use Me |
| **Pricing** | Prix fixe / Horaire / Devis - au choix |
| **Intégration** | Section dédiée + suggestions lors des bookings |
| **Catégories MVP** | Design/Artwork + Production musicale |

---

## Architecture Choisie

### Profils Hybrides (pas de nouveaux rôles)
```dart
class AppUser extends BaseUser {
  final BaseUserRole role;                    // Rôle principal inchangé
  final StudioProfile? studioProfile;         // Existant
  final ServiceProviderProfile? serviceProviderProfile; // NOUVEAU
}
```

**Avantage**: Un artiste peut aussi être designer, un ingénieur peut être beatmaker - sans casser le système de rôles existant.

---

## Nouveaux Modèles

### 1. `ServiceProviderProfile` (embedded dans AppUser)
```
lib/core/models/service_provider_profile.dart
- displayName, bio, portfolioImages, skills
- categories: [design, artwork, beatmaking, composition...]
- status: pending | approved | rejected | suspended
- rating, reviewCount, completedOrders
- approvedAt, approvedBy
```

### 2. `FreelanceService` (listing de service)
```
lib/core/models/freelance_service.dart
- providerId, providerName
- title, description, category, tags
- pricingType: fixed | hourly | daily | quote
- fixedPrice, hourlyRate, dailyRate, minPrice, maxPrice
- deliveryDays, images, sampleUrls
- isActive, isApproved
```

### 3. `ServiceOrder` (commande)
```
lib/core/models/service_order.dart
- serviceId, providerId, clientId
- status: pending | accepted | delivered | revision | completed | cancelled
- agreedPrice, commissionRate (0.10), commissionAmount, providerPayout
- customRequirements, attachments
- linkedBookingId, linkedSessionId (intégration studio)
```

### 4. `ProviderApplication` (candidature)
```
lib/core/models/provider_application.dart
- userId, proposedProfile, requestedCategories
- portfolioUrl, motivation
- status: pending | approved | rejected
- reviewedAt, reviewedBy, rejectionReason
```

---

## Collections Firestore

```
useme_freelance_services/{serviceId}    # Listings de services
useme_service_orders/{orderId}          # Commandes
useme_service_reviews/{reviewId}        # Avis clients
useme_provider_applications/{appId}     # Candidatures providers

users/{userId}
  └── serviceProviderProfile: {...}     # Profil provider embedded
```

---

## Services à Créer

| Service | Pattern à suivre | Responsabilité |
|---------|------------------|----------------|
| `FreelanceServiceService` | `StudioService` | CRUD services marketplace |
| `ServiceOrderService` | `BookingService` | Gestion commandes + transitions statut |
| `ProviderApplicationService` | `StudioClaimApprovalService` | Workflow de validation manuelle |
| `ServiceReviewService` | Nouveau | Avis et calcul rating |
| `MarketplaceDiscoveryService` | `StudioDiscoveryService` | Découverte + suggestions booking |

---

## BLoCs à Créer

```
lib/core/blocs/
├── marketplace/
│   ├── marketplace_bloc.dart
│   ├── marketplace_event.dart
│   └── marketplace_state.dart
├── service_order/
│   ├── service_order_bloc.dart
│   ├── service_order_event.dart
│   └── service_order_state.dart
└── provider_application/
    ├── provider_application_bloc.dart
    └── ...
```

---

## Écrans à Créer

### Browse & Découverte
```
lib/screens/marketplace/
├── marketplace_browse_page.dart      # Grille catégories + featured
├── marketplace_search_screen.dart    # Recherche avec filtres
├── service_detail_screen.dart        # Page service + bouton commander
└── provider_profile_screen.dart      # Portfolio provider
```

### Côté Provider
```
lib/screens/marketplace/provider/
├── my_services_page.dart             # Mes services
├── service_form_screen.dart          # Créer/éditer service
├── provider_orders_page.dart         # Commandes reçues
└── order_detail_screen.dart          # Détail + actions
```

### Côté Client
```
lib/screens/marketplace/client/
├── my_orders_page.dart               # Mes commandes
├── order_request_screen.dart         # Passer commande
└── review_form_screen.dart           # Laisser un avis
```

### Admin (SuperAdmin)
```
lib/screens/marketplace/admin/
├── provider_applications_screen.dart # File d'attente validation
└── application_detail_screen.dart    # Détail candidature
```

### Onboarding Provider
```
lib/screens/onboarding/
└── become_provider_screen.dart       # Formulaire candidature
```

---

## Intégration avec Booking Studio

### Suggestions pendant réservation
```dart
// Lors d'une réservation enregistrement -> suggérer pochettes
// Lors d'un mix/master -> suggérer artwork

MarketplaceDiscoveryService.getSuggestionsForBooking(
  studioId: studioId,
  sessionType: SessionType.recording,
) // -> retourne designers/artistes pertinents
```

### Liaison commande ↔ session
```dart
class ServiceOrder {
  final String? linkedBookingId;   // Lié à une résa studio
  final String? linkedSessionId;   // Lié à une session
}
```

---

## Workflow Validation Manuelle

```
User demande → Application créée (pending)
      ↓
SuperAdmin voit dans liste
      ↓
Review portfolio + profil
      ↓
   ┌──────────┐
   │ APPROVE  │ → User devient provider visible
   └──────────┘
        ou
   ┌──────────┐
   │ REJECT   │ → User peut re-postuler
   └──────────┘
```

---

## Commission 10%

```dart
class CommissionCalculator {
  static const double RATE = 0.10;

  // Exemple: service à 500€
  // Commission: 50€
  // Provider reçoit: 450€
}
```

**MVP**: Tracking manuel (provider marque "payé")
**Future**: Stripe Connect avec paiement in-app

---

## Phases d'Implémentation

### Phase 1: MVP (4-6 semaines)
- [ ] Modèles + Firestore schema
- [ ] Services CRUD
- [ ] BLoCs
- [ ] UI Browse + Détail service
- [ ] Devenir provider + Validation admin
- [ ] Flow commande basique

### Phase 2: Enhanced (2-3 semaines)
- [ ] Reviews & Ratings
- [ ] Recherche avancée + filtres
- [ ] Dashboard provider (stats)

### Phase 3: Payments (4-6 semaines)
- [ ] Stripe Connect onboarding
- [ ] Paiement in-app
- [ ] Escrow + Payouts auto
- [ ] Reporting commissions

### Phase 4: Future
- [ ] Messaging intégré
- [ ] Paiements par étapes
- [ ] Portfolio vidéo/audio
- [ ] Catégories: Photo, Vidéo/Clip, Scénariste...

---

## Fichiers Critiques à Modifier

1. `lib/core/models/app_user.dart` - Ajouter serviceProviderProfile
2. `lib/core/models/favorite.dart` - Ajouter types serviceProvider, freelanceService
3. `lib/routing/router.dart` - Ajouter routes marketplace
4. `lib/screens/artist/artist_main_scaffold.dart` - Ajouter onglet Services
5. `lib/core/blocs/blocs_exports.dart` - Exporter nouveaux blocs

---

## Catégories au Lancement

| Catégorie | Exemples |
|-----------|----------|
| `design` | Pochettes d'album, logos, branding |
| `artwork` | Illustrations, cover art |
| `beatmaking` | Production de beats |
| `composition` | Composition, arrangement musical |

---

## Notes

Ce document a été créé lors d'une session de brainstorming. À reprendre quand on sera prêts à développer cette feature.
