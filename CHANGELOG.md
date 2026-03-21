# Changelog

All notable changes to the **Use Me** app are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/).

---

## [Unreleased]

### Added
- **Stripe session payment** — Artists can pay deposits and remaining balances directly in-app via Stripe PaymentSheet (Apple Pay, Google Pay, Card)
- **Stripe Connect for studios** — Studios can connect their Stripe account to receive payments directly (Express accounts, 15% platform commission)
- **Stripe Connect onboarding screen** — `/studio/stripe-connect` with status indicators and onboarding flow
- **"Paiement via l'app" payment method** — New `stripeInApp` option in booking acceptance; only shows when studio has Stripe Connect active
- **SessionPayButton widget** — Contextual pay button on artist session detail (deposit or remaining)
- **SessionPaymentBloc** — Full BLoC with payment intent creation, PaymentSheet presentation, and Connect status checking
- **Dual pay buttons** — Artist can choose to pay deposit only or full amount upfront; after deposit, "Pay remaining" button appears
- **Real-time session detail** — Firestore StreamBuilder on artist session detail for instant payment status updates
- **Confirm payment endpoint** — Backend `confirm-payment` updates Firestore server-side after PaymentSheet success
- Backend: 4 Cloud Function endpoints (`session-payment`, `connect-onboard`, `connect-status`, `confirm-payment`) + webhook handler
- Session model: `stripePaymentIntentId`, `stripeDepositIntentId`, `canPayDeposit`, `canPayRemaining` helpers
- Website: `/connect/return` and `/connect/refresh` pages for Stripe onboarding redirect
- Deep link handling for `useme://connect/return` with auto-refresh on app resume
- 8 unit tests (SessionPaymentIntent model + SessionPaymentBloc)
- Localization: 15 new payment strings (FR/EN/SG)
- Production checklist: `docs/stripe-payment-prod-checklist.md`
- **Discover map for Studio & Engineer** — "Explorez la carte" button on dashboards opens shared map view (`/discover`)
- Studio name search on map — matches loaded studios before geocoding
- Selected studio highlighted on map with larger pin + glow ring
- `SubscriptionLegalFooter` widget (Apple App Store compliance 3.1.2)
- Auto-renew notice + Terms/Privacy links on upgrade screen
- Localization strings: `subscriptionAutoRenewNotice`, `subscriptionLegalFooter` (EN/FR/SG)
- Tests for studio name search matching (exact, partial, case-insensitive, fallback to geocoding)

### Changed
- `StudioDetailBottomSheet.show()` and `ProDetailBottomSheet.show()` now return `Future<void>`
- Artist portal opens studio detail via `BlocListener` (supports search-triggered selection)
- Map zooms to 16 on selected studio, 13 on area search
- Custom pin deselects visually when tapping elsewhere on the map
- Studio quick access: replaced "Stats" (no-op) with "Explorez la carte"

### Fixed
- Legal URLs corrected from `useme.app` to `uzme.app` (terms, privacy, legal, help)
- Profile photo sync in messaging — changes propagate in real-time across all roles
- 9 missing Sango translations added
- Stripe config decryption crash on corrupted/unencrypted data (now tolerant)
- Non-exhaustive switch statements after adding `stripeInApp` payment type

---

## [1.0.0] - 2026-03-18

### Added
- Apple In-App Purchase subscription flow (`feat(iap)`)
- Pro profiles on map with geocoded city
- Pro profile: portfolio photos, payment methods, pending badges, calendar dots
- Pro profile: photo selection with smart fallback chain
- Pro booking deposit/payment system with deposit percentage config
- Manual payment tracking and session type for pro bookings
- Multi-account recent login for quick re-authentication
- Custom UZME-branded map styles (light/dark)
- Tablet/desktop responsive layout support
- macOS build configured for App Store submission
- Apple Sign-In and push notification entitlements (macOS)
- Cancel button for confirmed pro bookings

### Fixed
- RenderFlex overflow errors on studio dashboard
- 15 failing tests (mocked `StudioDiscoveryService`)
- iOS location permission no longer re-requested on every map visit
- Discovery cache invalidated when pro profile is updated
- Removed Pro Profile doublon from studio settings

### Changed
- Xcode project files and macOS Podfile.lock updated
- Missing v1 features implemented, strings localized, oversized files split
