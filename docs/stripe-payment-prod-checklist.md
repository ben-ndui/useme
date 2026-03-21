# Stripe Session Payment — Checklist Mise en Production

## Ce qui est fait

- [x] Backend: endpoints `session-payment`, `connect-onboard`, `connect-status`, `confirm-payment`
- [x] Backend: webhook handler pour `payment_intent.succeeded` avec metadata `useme_session_payment`
- [x] Backend: vérification `charges_enabled` avant `transfer_data` (fallback sans split)
- [x] Backend: Firebase Auth middleware sur toutes les routes Stripe (sauf webhook)
- [x] Backend: IDOR protection (verifyUserMatch)
- [x] Backend: Rate limiting 20 req/min sur endpoints paiement
- [x] Backend: Webhook signature verification (raw body + constructEvent)
- [x] Backend: Validation montant côté serveur (session Firestore vs client)
- [x] Backend: Idempotency key sur PaymentIntent creation
- [x] Backend: confirm-payment vérifie le PaymentIntent chez Stripe
- [x] Backend: Mode reset test supprimé
- [x] Backend: Publishable key hardcodée retirée (config Firestore uniquement)
- [x] Flutter: `SessionPaymentBloc` + `SessionPaymentService` + `SessionPaymentIntent` model
- [x] Flutter: `SessionPayButton` avec choix acompte / totalité / solde
- [x] Flutter: `StripeConnectScreen` avec onboarding + auto-refresh au retour dans l'app
- [x] Flutter: `stripeInApp` dans `PaymentMethodType` — option visible uniquement si Connect actif
- [x] Flutter: Real-time Firestore stream sur session detail (mise à jour instantanée)
- [x] Flutter: Payment banners glassmorphism ambre (feed artiste + chat)
- [x] Flutter: Deep link handling `useme://connect/return`
- [x] Flutter: Firebase Auth token envoyé avec chaque requête API
- [x] Flutter: Google Pay testEnv dynamique (kReleaseMode)
- [x] Flutter: Messages d'erreur user-friendly (pas de leak interne)
- [x] Flutter: Debug logs supprimés
- [x] Flutter: 3 locales (FR/EN/SG)
- [x] Flutter: 8 tests (model + bloc)
- [x] Website: pages `/connect/return` et `/connect/refresh` sur uzme.app
- [x] Cloud Functions déployées (avec sécu)
- [x] Firestore index `useme_sessions (artistIds + status)` déployé
- [x] Code pushé sur origin/master
- [x] Security review: 14/14 findings traités
- [x] Compliance review: Apple + Google conforme
- [x] Analyze: 0 erreurs, 0 warnings

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

### 4. Test end-to-end en mode Live

- [ ] Un studio connecte son compte Stripe (vrai KYC)
- [ ] Vérifier `chargesEnabled: true` et `payoutsEnabled: true`
- [ ] Un artiste paie un acompte avec une vraie carte
- [ ] Vérifier le paiement dans Stripe Dashboard
- [ ] Vérifier que le webhook met à jour Firestore
- [ ] Vérifier que le studio reçoit la notification
- [ ] Vérifier le split 85/15 dans Stripe (si Connect actif)
- [ ] Un artiste paie le solde restant
- [ ] Vérifier le status `fullyPaid` dans Firestore
- [ ] Vérifier les banners disparaissent après paiement
