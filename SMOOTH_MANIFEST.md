# SMOOTH_MANIFEST.md

## Projet
- Nom: useme (UZME)
- Type: mobile (iOS, Android, macOS, Web)
- Client: Smooth & Design (interne)
- Statut: actif (dernier push: mars 2026)

## Stack
- Frontend: Flutter 3.38+ (Dart, gere via FVM)
- Backend: Firebase (Cloud Functions, Cloud Firestore, Cloud Storage)
- Auth: Firebase Auth (email, Google Sign-In, Apple Sign-In)
- Base de donnees: Firestore
- Autres: Google Maps API, Stripe (paiements), smoothandesign_package (shared package), flutter_dotenv, encryption (encrypt, crypto, flutter_secure_storage), PDF generation (pdf + printing), Deep Links (app_links), FCM (push notifications), l10n (FR/EN via ARB)

## Features implementees
- Reservation de sessions studio (booking flow complet)
- Trois roles utilisateur : Studio (admin/superAdmin), Engineer (worker), Artist (client)
- Recherche de studios par ville/adresse avec Google Maps
- Filtres par services et partenaires verifies
- Bouton "Rechercher dans cette zone" sur la carte
- Calendrier avec vues Semaine / Mois / Liste
- Export de sessions vers le calendrier du telephone (add_2_calendar)
- Import Google Calendar avec sync des indisponibilites
- Picker de disponibilites avec horaires de travail du studio
- Systeme de favoris (studios, ingenieurs, artistes) en temps reel via Firestore streams
- Messagerie temps reel entre utilisateurs (conversations, messages, reactions emoji, messages vocaux)
- Assistant IA integre (chat_assistant_service avec detection d'intent)
- Gestion d'equipe : invitations ingenieurs et artistes
- Enregistrement de studio manuel (sans Google Maps)
- Types de studio (pro, independent, amateur) avec badges de verification
- Revendication de studios existants Google Places (studio claiming)
- Notifications push via FCM et notifications locales
- Generation de PDF pour confirmations de session
- Gestion des sessions de devices connectes
- Multi-studio support pour les artistes
- Onboarding flow
- Panneau admin (superAdmin) pour approbation des revendications
- Theming et configuration (Stripe, etc.) via Firestore
- Localisation FR/EN avec ARB files
- Chiffrement securise (encrypt, flutter_secure_storage, crypto)
- Charts et statistiques (fl_chart)
- Carousel (carousel_slider)
- Animations (animate_do)

## Patterns notables
- Architecture: BloC (flutter_bloc) avec separation events/states/bloc + get_it pour DI
- Structure: lib/config, lib/core (blocs, models, services, data, utils), lib/screens (par role: artist, engineer, studio, admin, shared, auth, onboarding, dev), lib/widgets (par domaine), lib/routing (go_router), lib/l10n
- Collections Firestore:
  - `users` — comptes utilisateurs avec champs role-based et studioProfile
  - `useme_sessions` — sessions de reservation studio
  - `useme_bookings` — demandes de reservation
  - `useme_artists` — profils artistes lies aux studios
  - `useme_studio_services` — services proposes par les studios
  - `useme_studio_rooms` — salles/espaces studio
  - `useme_favorites` — favoris utilisateur
  - `conversations` / `messages` — messagerie
  - `user_notifications` — notifications
  - `team_invitations` / `studio_invitations` — invitations equipe/artiste
  - `studio_claims` / `studio_requests` — revendications et demandes studio
  - `studio_unavailabilities` — periodes d'indisponibilite
  - `subscription_tiers` — configurations d'abonnement
  - `app_config` — configuration app (Stripe, etc.)
  - `ai_conversations` / `ai_messages` / `ai_settings` — assistant IA
  - Backend-only: `ai_actions_log`, `ai_analytics`, `counters`, `encryption_ivs`, `invitation_codes`, `payment_accounts`, `payment_distributions`, `xpTransactions`
- Conventions de nommage: snake_case (fichiers Dart), camelCase (variables), VerbNounEvent / NounVerbedState (BloC)

## Reutilisabilite
- Snippets cles:
  - `smoothandesign_package` — package partage complet (modeles, blocs, widgets Glass, composants settings, AppSnackBar, AppLoader, FloatingBottomNav, NotificationBell)
  - `lib/core/services/` — services Firebase generiques reutilisables
  - `lib/widgets/common/` — widgets UI communs
  - `lib/core/blocs/` — pattern BloC reutilisable (events/states/exports)
  - `lib/routing/router.dart` — configuration GoRouter
  - `build_ios.sh` — script de build iOS
