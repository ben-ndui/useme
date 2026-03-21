# Stripe Session Payment — Checklist Mise en Production

## Ce qui est fait

- [x] Backend: endpoints `session-payment`, `connect-onboard`, `connect-status`, `confirm-payment`
- [x] Backend: webhook handler pour `payment_intent.succeeded` avec metadata `useme_session_payment`
- [x] Backend: vérification `charges_enabled` avant `transfer_data` (fallback sans split)
- [x] Flutter: `SessionPaymentBloc` + `SessionPaymentService` + `SessionPaymentIntent` model
- [x] Flutter: `SessionPayButton` avec choix acompte / totalité / solde
- [x] Flutter: `StripeConnectScreen` avec onboarding + auto-refresh au retour dans l'app
- [x] Flutter: `stripeInApp` dans `PaymentMethodType` — option visible uniquement si Connect actif
- [x] Flutter: Real-time Firestore stream sur session detail (mise à jour instantanée)
- [x] Flutter: 3 locales (FR/EN/SG)
- [x] Flutter: 8 tests (model + bloc)
- [x] Website: pages `/connect/return` et `/connect/refresh` sur uzme.app
- [x] Cloud Functions déployées

---

## A faire avant la mise en prod

### 1. Stripe Dashboard (obligatoire)

- [ ] **Activer Stripe Connect** : dashboard.stripe.com/settings/connect
  - Type: Express
  - Branding: UZME, logo, couleur
  - Pays: France

- [ ] **Passer en mode Live** : dashboard.stripe.com/developers/api-keys
  - Copier la `pk_live_...` (publishable key live)
  - Copier la `sk_live_...` (secret key live)

- [ ] **Configurer le Webhook Live** : dashboard.stripe.com/webhooks
  - URL: `https://us-central1-smoothandesign.cloudfunctions.net/api/api/stripe/webhook`
  - Events:
    - `payment_intent.succeeded`
    - `payment_intent.payment_failed`
    - `checkout.session.completed`
    - `customer.subscription.created`
    - `customer.subscription.updated`
    - `customer.subscription.deleted`
    - `invoice.payment_failed`
  - Copier le Signing Secret (`whsec_...`)

### 2. Firebase (obligatoire)

- [ ] **Mettre à jour les secrets Firebase** (mode live) :
  ```bash
  firebase functions:secrets:set STRIPE_SECRET_KEY
  # Coller: sk_live_...
  firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
  # Coller: whsec_... (du webhook live)
  ```

- [ ] **Mettre à jour Firestore** `app_config/stripe` :
  - `publishableKey`: `pk_live_...`
  - `isLiveMode`: `true`
  - (via l'écran admin Stripe Config dans l'app, en mode DevMaster)

- [ ] **Redéployer les Cloud Functions** après mise à jour des secrets :
  ```bash
  cd smoothbackend/functions && firebase deploy --only functions:api
  ```

### 3. Apple Pay (optionnel, recommandé)

- [ ] Créer un Merchant ID dans Apple Developer Portal
- [ ] Configurer dans Stripe Dashboard → Settings → Apple Pay
- [ ] Ajouter l'entitlement dans Xcode (Runner.entitlements)
- [ ] Passer le `merchantIdentifier` dans `Stripe.instance.applySettings()`
- [ ] Réactiver `PaymentSheetApplePay` dans `session_payment_service.dart`

### 4. Sécurité (recommandé)

- [ ] **Webhook signature verification** : corriger le parsing du raw body dans `stripe_controller.js` (actuellement skipé en mode parsed body)
- [ ] **Endpoint `confirm-payment`** : ajouter une vérification que le PaymentIntent existe réellement chez Stripe avant de confirmer (éviter les appels frauduleux)
- [ ] **Retirer le mode `reset`** de l'endpoint `confirm-payment` (c'est un outil de test uniquement)
- [ ] **Firestore Security Rules** : vérifier que les artistes ne peuvent pas modifier `paymentStatus` directement

### 5. Test end-to-end en mode Live

- [ ] Un studio connecte son compte Stripe (vrai KYC)
- [ ] Vérifier `chargesEnabled: true` et `payoutsEnabled: true`
- [ ] Un artiste paie un acompte avec une vraie carte
- [ ] Vérifier le paiement dans Stripe Dashboard
- [ ] Vérifier que le webhook met à jour Firestore
- [ ] Vérifier que le studio reçoit la notification
- [ ] Vérifier le split 85/15 dans Stripe (si Connect actif)
- [ ] Un artiste paie le solde restant
- [ ] Vérifier le status `fullyPaid` dans Firestore

### 6. Debug logs à retirer

- [ ] `session_payment_service.dart` : retirer les `debugPrint('[StripeService]...')` et `debugPrint('[StripeConnect]...')`
- [ ] `session_payment_bloc.dart` : retirer les `debugPrint('[PaymentBloc]...')`

---

## Architecture du flow

```
Studio accepte booking → Choisit "Paiement via l'app"
    │
    ▼
Session Firestore: paymentStatus = "depositPending"
    │
    ▼
Artiste ouvre session detail (StreamBuilder temps réel)
    ├── Bouton "Payer l'acompte (XX €)"
    └── Bouton "Payer le solde (total €)"
    │
    ▼
Artiste tape "Payer" → SessionPaymentBloc
    │
    ├── 1. POST /api/stripe/useme/session-payment
    │      → PaymentIntent créé (+ transfer_data si Connect actif)
    │      → clientSecret + ephemeralKey retournés
    │
    ├── 2. Stripe.publishableKey = pk_...
    │      → Stripe.initPaymentSheet(clientSecret, ephemeralKey)
    │      → Stripe.presentPaymentSheet()
    │
    ├── 3. Paiement réussi
    │      → POST /api/stripe/useme/confirm-payment
    │      → Firestore: paymentStatus = "depositPaid" ou "fullyPaid"
    │
    └── 4. StreamBuilder détecte le changement → UI refresh instantané
            → Bouton disparaît ou passe à "Payer le solde"

    (En parallèle, si webhook configuré)
    Stripe webhook → payment_intent.succeeded
        → Met à jour Firestore + crée notification studio
```

## Endpoints backend

| Route | Méthode | Description |
|-------|---------|-------------|
| `/api/stripe/useme/session-payment` | POST | Crée PaymentIntent + ephemeral key |
| `/api/stripe/useme/confirm-payment` | POST | Met à jour paymentStatus dans Firestore |
| `/api/stripe/useme/connect-onboard` | POST | Crée compte Connect Express + lien onboarding |
| `/api/stripe/useme/connect-status` | POST | Vérifie chargesEnabled, payoutsEnabled |
| `/api/stripe/webhook` | POST | Webhook Stripe (payment events) |

## Fichiers clés

| Fichier | Rôle |
|---------|------|
| `lib/core/services/session_payment_service.dart` | HTTP + PaymentSheet + Connect |
| `lib/core/blocs/session_payment/` | BLoC complet (events, states, bloc) |
| `lib/widgets/common/session_pay_button.dart` | Boutons paiement (acompte/total/solde) |
| `lib/screens/studio/stripe_connect_screen.dart` | Onboarding Stripe Connect |
| `lib/screens/artist/artist_session_detail_screen.dart` | StreamBuilder temps réel |
| `smoothbackend/functions/controllers/stripe_controller.js` | Tous les endpoints |
| `smoothbackend/functions/routes/stripe_routes.js` | Routage Express |
