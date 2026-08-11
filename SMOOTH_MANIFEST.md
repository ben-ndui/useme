# SMOOTH_MANIFEST — UZME (repo `uzme`, ex-`useme`)
App mobile de réservation de sessions studio — met en relation artistes, ingénieurs son et propriétaires de studios ("Youzmi").

## Identité

- **Stack** : Flutter 3.44.4 via FVM (`.fvmrc`) · BLoC (`flutter_bloc`) · `go_router` · Firebase (Auth, Firestore, Storage, Functions, Crashlytics, Messaging)
- **Package partagé** : `smoothandesign_package` (auth, messagerie, Stripe, IAP, notifications) + `smoothandesign_auth_biometric`
- **Firebase** : projet `uzme-app`, région `europe-west1` — API `https://europe-west1-uzme-app.cloudfunctions.net/api`
- **Backend** : monorepo `ben-ndui/smoothbackend`, dossier `projects/useme/` (14 modules assemblés). Deploy : `./scripts/deploy.sh useme`
- **Stores** : `com.smoothandesign.useme` (Android + iOS), v1.5.26+55 en Production sur les deux
- **Repo** : `ben-ndui/uzme` (branche `master`) · dashboard support : `ben-ndui/uzme-support` (domaine `uzme.app`)
- **Rôles applicatifs** : `superAdmin` · `admin` (studio) · `worker` (ingénieur) · `client` (artiste)

## Architecture

```
lib/
├── main.dart                  # bootstrap Firebase, notifs, deep links, device session, observer Crashlytics
├── core/blocs/                # un dossier par feature (bloc/event/state/exports)
├── core/models/               # modèles Equatable
├── core/services/             # 56 services Firebase/HTTP (couche métier réelle)
├── core/localization/         # délégués custom Sängö
├── routing/                   # app_routes.dart (constantes) + router.dart (GoRouter + guards de flags)
├── screens/{artist,engineer,studio,shared,admin,auth,onboarding}/
├── widgets/                   # par domaine (artist, engineer, studio, card, map, messaging, network...)
└── l10n/                      # app_fr.arb (template, ~2419 clés) + app_en.arb + app_sg.arb
third_party/nfc_manager/       # plugin NFC vendorisé et patché (voir VENDORED.md)
test/                          # 90 fichiers de tests (blocs, models, services, écrans smoke, router)
```

## Features

### Auth & comptes
- **Auth multi-provider** : email/password + Google + Apple, avec création du doc `users`. Tous les signups sont forcés en `client` depuis la Phase E1. `lib/core/services/auth_service.dart`, `lib/widgets/auth/role_selector_sheet.dart`
- **Verrouillage biométrique** : soft gate Face ID/empreinte qui ne déconnecte pas (tokens Firebase et FCM restent vivants). `lib/screens/auth/biometric_lock_screen.dart`
- **Comptes récents** : 5 derniers comptes en local pour un re-login en un tap. `lib/core/services/recent_accounts_service.dart`
- **Sessions d'appareils** : traçabilité device/OS/IP + révocation à distance (flip `isActive: false` observé en temps réel). `lib/screens/shared/device_sessions_screen.dart`
- **Changement de rôle** : bloqué si données actives incompatibles, sinon demande d'archivage validée par superAdmin ; conseiller IA avec fallback déterministe. `lib/core/services/role_switch_service.dart`
- **Onboarding permissions** : pages contenu puis localisation, notifications et CGU — conçu pour la conformité App Review. `lib/screens/onboarding/onboarding_screen.dart`
- **Invitations studio → artiste** : code `USEME-XXXXXX` à 30 jours, auto-link par email à l'inscription. `lib/core/services/invitation_service.dart`
- **Modération** : signalement d'utilisateur (notif à tous les superAdmins) et blocage unilatéral. Exigence Apple 1.2. `lib/core/services/report_service.dart`, `lib/core/services/block_service.dart`

### Réservation & planning
- **Demande de session** : l'artiste demande (`pending`), le studio accepte via sheet paiement + proposition d'ingénieurs, ou refuse. Multi-artistes (`artistIds`), multi-types (`types`), sessions de pro freelance (`proId`). `lib/core/services/session_service.dart`, `lib/widgets/studio/accept_booking_sheet.dart`
- **Moteur de créneaux** : calcul 100 % client croisant sessions confirmées, indisponibilités, `workingHours` et dispo par ingénieur. `availabilityLevel` pilote le code couleur. `lib/core/services/availability_service.dart`
- **Proposition multi-ingénieurs** : un studio propose à plusieurs ingénieurs, le premier qui accepte est assigné, les autres peuvent demander à rejoindre en co-ingénieur. `lib/core/services/engineer_proposal_service.dart`
- **Disponibilité ingénieur** : horaires de travail + congés ponctuels. `lib/core/services/engineer_availability_service.dart`
- **Suivi d'intervention** : check-in/check-out horodatés, photos et notes. `lib/screens/engineer/session_tracking_screen.dart`
- **Catalogue de services** : prestations du studio (tarif horaire, durée min/max) servant au calcul du `totalAmount`. `lib/core/services/service_catalog_service.dart`
- **Salles** : espaces réservables avec flag `requiresEngineer`. `lib/core/services/studio_room_service.dart`
- **Carnet d'artistes** : CRUD du roster studio + liaison à un compte utilisateur. `lib/core/services/artist_service.dart`
- **Équipe** : invitation d'ingénieur par code `TEAM-XXXXXX`, quota vérifié via l'abonnement. `lib/core/services/team_service.dart`

### Paiement
- **Paiement de session** : acompte puis solde via Stripe PaymentSheet in-app. `lib/core/services/session_payment_service.dart`, `lib/core/blocs/session_payment/session_payment_bloc.dart`
- **Stripe Connect** : onboarding Express pour qu'un studio encaisse. `lib/screens/studio/stripe_connect_screen.dart`
- **Abonnements studio** : free/pro/enterprise via Stripe Checkout (Android/web) ou Apple IAP (iOS). `lib/core/services/stripe_service.dart`, `lib/core/services/iap_service.dart`
- **Paliers d'abonnement** : configuration superAdmin des limites (`-1` = illimité). `lib/core/services/subscription_config_service.dart`
- **Config Stripe chiffrée** : écran DevMaster de saisie des clés, secrète et webhook chiffrées AES-256 avant écriture. `lib/core/services/stripe_config_service.dart`
- **Moyens de paiement manuels** : espèces, virement, PayPal — avec acompte par défaut et politique d'annulation. Champs bancaires chiffrés. `lib/core/services/payment_config_service.dart`
- **Remboursements** : politique flexible/moderate/strict ; annulation par le studio = toujours 100 %. Calcul Dart = prévisualisation, le backend fait foi. `lib/core/models/refund_calculation.dart`

### Communication & IA
- **Messagerie temps réel** : 1:1 et groupe (texte, pièce jointe, audio, objet métier), réactions emoji, archivage et mute par utilisateur. Toute la stack vient de `smoothandesign_package`. `lib/screens/shared/chat_screen.dart`
- **Assistant IA personnel** : un fil par utilisateur, réponses markdown avec blocs `[TYPE_DATA]{json}[/TYPE_DATA]` rendus en cards. `lib/screens/shared/ai_assistant_screen.dart`, `lib/widgets/chat/ai_widgets/`
- **IA d'assistance studio** : suggestion/auto-reply configurable — service et callables prêts, **UI non branchée** dans `chat_screen.dart`. `lib/core/services/chat_assistant_service.dart`
- **Push FCM** : token sauvé sur `users/{uid}.fcmToken`, consommé par les triggers backend. `lib/core/services/notification_service.dart`
- **Routage des notifications** : branchement par rôle métier (un même type route différemment pour ingénieur, artiste ou studio). `lib/core/services/notification_navigation_service.dart`
- **Annuaire de contacts** : qui peut ouvrir une conversation avec qui, selon le rôle. `lib/core/services/contact_service.dart`

### Découverte & réseau
- **Carte Google Maps** : Nearby + Text Search fusionnés avec les partenaires Firestore, tri pioneers > partenaires > distance. `lib/core/services/studio_discovery_service.dart`, `lib/screens/shared/discover_map_screen.dart`
- **Géocodage & itinéraires** : autocomplétion d'adresse avec session token Places, tracé polyline et ouverture des apps natives. `lib/core/services/geocoding_service.dart`, `lib/core/services/directions_service.dart`
- **Revendication de studio** : lien direct ou workflow d'approbation superAdmin d'un Google Place. `lib/core/services/studio_claim_service.dart`
- **Profil pro indépendant** : activable hors studio, marker orange sur la carte, flux de réservation propre. `lib/core/services/pro_profile_service.dart`
- **Carte de visite numérique** : personnalisation, effet holographique gyroscope, partage QR / NFC / vCard, statistiques de scan. `lib/core/services/card_config_service.dart`, `lib/core/services/nfc_share_service.dart`, `lib/core/services/vcard_service.dart`
- **Carnet réseau** : contacts pro on/off-plateforme, import du carnet téléphone, invitations SMS/email. `lib/core/services/network_service.dart`
- **Favoris** : studios, ingénieurs, artistes ; tri client volontaire pour éviter un index composite. `lib/core/services/favorite_service.dart`

### Plateforme
- **Feature flags** : résolveur central live, `isEnabled(user, key)` synchrone, 4 états (`disabled`/`pioneer`/`beta`/`enabled`), deny-by-default. Le pattern le plus réutilisable du repo. `lib/core/services/feature_flags_service.dart`, `lib/core/constants/feature_flag_keys.dart`
- **Programme Pioneer** : cohortes early-adopters scorées puis récompensées (badge, remise, exemption de commission, boost). `lib/core/services/pioneer_service.dart`
- **Annonces de features** : bottomsheet à la première ouverture d'un flag annoncé + écran Nouveautés résumé par IA. `lib/core/services/feature_announcements_service.dart`
- **Observabilité** : `CrashlyticsBlocObserver` global + boot logger visible en release (celui qui a permis de diagnostiquer les écrans blancs TestFlight). `lib/core/utils/crashlytics_bloc_observer.dart`
- **i18n trilingue** : FR (template) / EN / **Sängö**, avec délégués custom pour une locale que Flutter ne supporte pas. `lib/core/localization/sango_material_localizations.dart`

## Modèle de données

| Collection | Notions non évidentes |
|---|---|
| `users/{uid}` | `role`, `studioProfile`, `proProfile`, `paymentConfig`, `cardConfig`, `cardStats`, `subscription`, `pioneer`, `fcmToken`, `blockedUsers.{uid}`, `seenFeatureAnnouncements[]` |
| `useme_sessions` | dates en **millis int** en écriture, lecture tolérant Timestamp · `engineerIds` / `proposedEngineerIds` · `intervention.{checkinTime,photos,notes}` · `paymentStatus`, `stripePaymentIntentId` |
| `useme_bookings` | demandes de réservation (API `/api/bookings`) |
| `useme_artists` | `linkedUserId` (null = fiche orpheline rattachable par email) |
| `useme_studio_services` | double format d'entrée : app Flutter (`hourlyRate`, heures) et IA backend (`price`, minutes) |
| `useme_studio_rooms` | **Timestamp pur**, sans tolérance millis · `requiresEngineer` |
| `useme_favorites` | `type` polymorphe (studio/engineer/artist), `createdAt` String ISO |
| `conversations` + `/messages` | compteurs et flags = **maps par userId** (`unreadCounts.<uid>`, `isArchived.<uid>`, `isMuted.<uid>`) · `sentAt` String ISO8601 |
| `user_notifications` | `type` + `data{}` pilotent le deep-link ; `createdAt` Timestamp |
| `device_sessions` | `isActive: false` = logout distant |
| `feature_flags/{key}` | `rollout`, `betaUserIds[]`, `announcementTitle/Body` |
| `pioneer_programs/{id}/recipients/{uid}` | `draft → active → distributed → archived` |
| `role_switch_requests`, `studio_claims`, `studio_requests` | workflows d'approbation superAdmin |
| `team_invitations`, `studio_invitations` | codes d'invitation, millis int |
| `studio_unavailabilities`, `engineer_time_offs` | Timestamp (≠ sessions en millis) |
| `subscription_tiers`, `app_config/stripe` | config lue publiquement, écrite superAdmin |
| `ai_conversations/{id}/messages`, `ai_settings`, `ai_actions_log` | Timestamp/serverTimestamp (inverse de la messagerie) |
| `user_contacts`, `user_invitations`, `encryption_ivs`, `calendar_tokens`, `reports` | — |

## Intégrations

- **Stripe** : PaymentSheet (`flutter_stripe`), Connect Express, Checkout abonnement, portail client — clés dans `app_config/stripe`, secrète chiffrée AES-256
- **Apple IAP** : StoreKit iOS uniquement, callable `verifyAppleReceipt` ; Android passe par Stripe Checkout (Play Billing 8 depuis v1.5.26)
- **Google Maps / Places / Directions** : appels **directs depuis le client**, clé dans `assets/.env` (`GOOGLE_MAPS_API_KEY`, gitignoré)
- **Google Calendar** : OAuth et synchro via l'API backend (`/api/calendar/*`), scheduled `syncAllCalendars` toutes les 15 min
- **Claude (IA)** : callables `generatePersonalAssistantResponse`, `generateChatResponse`, `getSuggestedReplies`, `getWhatsNewForMe`
- **Firebase** : Auth, Firestore, Storage, Messaging, Crashlytics · 22 Cloud Functions (API Express + 11 callables + 9 triggers + 1 scheduled)
- **NFC** : `nfc_manager` vendorisé dans `third_party/nfc_manager/` (deux patches iOS documentés dans `VENDORED.md`)
- **CI/CD** : GitHub Actions + Fastlane — `.github/workflows/release.yml` orchestre bump, tag et deploy Android/iOS

## Commandes

```bash
fvm flutter pub get
fvm flutter run                    # -d ios | -d android | -d chrome
fvm flutter gen-l10n               # OBLIGATOIRE après toute modif d'ARB
fvm flutter analyze                # zéro warning attendu
fvm flutter test                   # 90 fichiers de tests
fvm flutter build apk / build ios

# Backend (monorepo smoothbackend)
cd ~/IdeaProjects/smoothbackend && ./scripts/deploy.sh useme

# Rules Firestore — source canonique + harnais émulateur AVANT tout deploy
cd ~/IdeaProjects/smoothbackend/tools/rules-test && npm run test:useme
cd ~/IdeaProjects/smoothbackend && firebase deploy --only firestore:rules \
  --config firebase.useme.json --project uzme-app
```

## Pièges

- **`firestore.rules` à la racine de ce repo est une COPIE, et elle est PÉRIMÉE** (430 lignes contre 488 côté canonique). La source de vérité est `smoothbackend/rules/useme/firestore.rules` : ne jamais éditer ni déployer depuis `uzme`. Durcissement du 2026-08-11 non répercuté ici (`pioneer` bloqué côté client, `useme_sessions` update restreint aux participants, scoping propriétaire sur favoris/contacts/invitations, compteurs fermés). Tester avec `npm run test:useme` avant chaque deploy de rules.
- **`fvm flutter` toujours**, jamais `flutter` nu : le Flutter global réécrit `AppDelegate.swift` et casse le démarrage iOS.
- **Ne jamais afficher `session.status`** en UI — utiliser `session.displayStatus` (recalcule `inProgress`/`completed` selon l'heure réelle) et vérifier `session.canBeCancelled` avant tout bouton d'annulation.
- **Conventions de dates incohérentes selon la collection** : `useme_sessions`/`useme_bookings` en millis int, `useme_studio_rooms`/`engineer_time_offs` en Timestamp, messages et favoris en String ISO8601. Vérifier la collection avant d'écrire.
- **`EncryptionService` est fail-fast depuis le 2026-08-11** : `encryptString` lève `StateError` si non initialisé et relance les erreurs au lieu de retourner le clair. Il n'y a plus de fallback de clé locale. Ne jamais le réintroduire : la clé dérivée d'un uid public était recalculable par n'importe qui.
- **`firestore.indexes.json` du repo est un template vide** — les index composites sont créés à la main en console.
- **Google Places/Directions renvoient HTTP 200 avec `status: REQUEST_DENIED` ou `OVER_QUERY_LIMIT`** : juger sur `data['status']`, jamais sur le code HTTP.
- **L'ordre des délégués de localisation est critique** : les délégués Sängö doivent précéder les `Global*Localizations.delegate`, sinon fallback silencieux en anglais.
- **La CI compile `smoothandesign_package` depuis sa ref git** (`pubspec_overrides.yaml` gitignoré) : sans bump du tag, la CI builde une version antérieure à celle testée en local.
- **Un tag poussé par `GITHUB_TOKEN` ne déclenche pas** les workflows `on: push: tags:` (anti-récursion GitHub) — passer par `gh workflow run` explicite.
- **Swift Package Manager est désactivé** volontairement (`firebase_core_shared` linké deux fois, 25 duplicate symbols au link).
- **Aucun workflow CI de `flutter analyze` / `flutter test`** : la suite ne tourne qu'en local, à faire tourner avant tout push.
- **Les routes admin n'ont aucun guard de rôle dans le router** — un non-admin qui devine l'URL voit l'écran (lecture ouverte) sans pouvoir agir.

> MAJ : 2026-08-11
