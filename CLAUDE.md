# CLAUDE.md — useme (UZME)

> **Base de connaissance centralisée :** `/Users/wesof./.smooth-brain/`
> Lire en priorité : `stacks/flutter-bloc.md` + `cross-project/shared-package.md` + `cross-project/smoothbackend.md`

---

This file provides guidance to Claude Code when working with the Use Me codebase.

## Project Overview

Use Me is a studio booking platform connecting artists with recording studios and sound engineers. The app supports three user roles:
- **Studio (admin/superAdmin)**: Studio owners who manage bookings, engineers, and services
- **Engineer (worker)**: Sound engineers who work at studios and manage their availability
- **Artist (client)**: Musicians who book studio sessions

## Technology Stack

- **Frontend**: Flutter 3.38+ (managed via FVM)
- **State Management**: BloC pattern (flutter_bloc)
- **Backend**: Firebase (Firestore, Auth, Storage, Cloud Functions)
- **Firebase Project**: `uzme-app` (europe-west1)
- **Routing**: go_router
- **Shared Package**: smoothandesign_package (shared components with Smooth Devis)
- **Localization**: flutter_localizations with ARB files

## Backend (smoothbackend)

Le backend Use Me fait partie du monorepo `ben-ndui/smoothbackend`.
Le code est dans `projects/useme/` qui assemble 14 modules depuis `modules/`.

### Firebase Project: `uzme-app`
- **API**: `https://europe-west1-uzme-app.cloudfunctions.net/api`
- **Region**: europe-west1
- **22 Cloud Functions** (API Express + 11 callables + 9 triggers + 1 scheduled)

### API Endpoints

| Route | Description |
|-------|-------------|
| `GET/POST /api/users` | CRUD utilisateurs |
| `GET/POST /api/studios` | Studios + geoloc + staff |
| `GET/POST /api/studio-services` | Services + disponibilite |
| `GET/POST /api/bookings` | Reservations + annulations |
| `POST /api/calendar/google/auth-url` | Google Calendar OAuth |
| `POST /api/calendar/sync` | Sync calendrier |
| `POST /api/stripe/useme/session-payment` | Paiement session |
| `POST /api/stripe/useme/connect-onboard` | Stripe Connect onboarding |
| `POST /api/stripe/useme/subscription-checkout` | Abonnement studio |
| `POST /api/stripe/useme/refund-session` | Remboursement |
| `POST /api/website-generator/generate` | Generation site AI |
| `GET /health` | Health check |

### Callable Functions (Firebase)
| Function | Description |
|----------|-------------|
| `generateChatResponse` | Chat AI Claude |
| `generatePersonalAssistantResponse` | Assistant personnel |
| `getSuggestedReplies` | Suggestions de reponse |
| `getEncryptionKey` | Cle de chiffrement user |
| `generatePaymentMessage` | Message de paiement |
| `verifyAppleReceipt` | Verification IAP Apple |
| `syncRoleClaim` | Sync role -> custom claims |
| `forceLogoutUser` | Deconnexion forcee (admin) |
| `validateInvitationCode` | Validation code invitation |
| `sendPaymentReminder` | Relance paiement |

### Firestore Triggers
| Trigger | Collection |
|---------|------------|
| `onSessionConfirmed` | `useme_sessions` |
| `onSessionCreatedConfirmed` | `useme_sessions` |
| `onTeamInvitationCreated` | `team_invitations` |
| `onUserUpdatedCheckPioneer` | `users` |
| `onBookingCreated/Updated` | `bookings` |
| `onUserNotificationCreated` | `user_notifications` |
| `onMessageCreated` | `conversations/*/messages` |
| `onUserRoleUpdated` | `users` |
| `syncAllCalendars` | Scheduled (every 15min) |

### Modules Use Me dans smoothbackend
`booking`, `studio`, `studio-services`, `calendar`, `stripe-core`, `stripe-connect`,
`website-generator`, `ai-chat`, `encryption`, `iap`, `user-management`, `notifications`,
`payment-accounts`, `payment-distributions`

### Deployer le backend Use Me
```bash
cd ~/IdeaProjects/smoothbackend
./scripts/deploy.sh useme
```

## Common Commands

```bash
# Run the app (uses FVM-managed Flutter version)
fvm flutter run

# Run on specific device
fvm flutter run -d chrome
fvm flutter run -d ios
fvm flutter run -d android

# Get dependencies
fvm flutter pub get

# Generate localizations (REQUIRED after adding ARB strings)
fvm flutter gen-l10n

# Analyze code
fvm flutter analyze

# Run tests
fvm flutter test

# Clean build
fvm flutter clean && fvm flutter pub get

# Build for release
fvm flutter build apk
fvm flutter build ios
```

## Architecture

```
lib/
├── main.dart
├── firebase_options.dart          # Firebase config (uzme-app)
├── config/                        # Theme, constants
├── core/
│   ├── blocs/                    # BloC state management
│   │   ├── feature/
│   │   │   ├── feature_bloc.dart
│   │   │   ├── feature_event.dart
│   │   │   ├── feature_state.dart
│   │   │   └── feature_exports.dart
│   ├── models/                   # Data models (Equatable)
│   └── services/                 # Firebase services
├── l10n/                         # Localizations (FR/EN)
│   ├── app_fr.arb               # French strings (primary)
│   └── app_en.arb               # English strings
├── routing/
│   ├── app_routes.dart          # Route constants
│   └── router.dart              # GoRouter configuration
├── screens/
│   ├── artist/                  # Artist-specific screens
│   ├── engineer/                # Engineer-specific screens
│   ├── studio/                  # Studio admin screens
│   ├── shared/                  # Cross-role screens
│   └── admin/                   # SuperAdmin screens
└── widgets/                      # Reusable widgets by domain
    ├── artist/
    ├── engineer/
    ├── studio/
    ├── common/
    └── messaging/
```

## Critical Code Rules

**These rules are mandatory and must be followed strictly:**

1. **Maximum 200 lines per file** - Split large files into focused components.

2. **Reusable components first** - Extract common UI patterns:
   - `/lib/widgets/` for app-specific widgets
   - `smoothandesign_package` for cross-app components

3. **Use `displayStatus` for sessions** - Never use `session.status` directly for UI display. Always use `session.displayStatus` which accounts for time-based status (in progress, completed).

4. **Use `canBeCancelled` for actions** - Check `session.canBeCancelled` before showing cancel/decline buttons.

5. **Localization required** - All user-facing strings in ARB files, run `fvm flutter gen-l10n` after changes.

6. **FVM prefix required** - Always use `fvm flutter` not `flutter` directly.

7. **Zero technical debt** - Fix ALL warnings and deprecations immediately. Never leave `info`, `warning`, or `deprecated` issues in the codebase. Run `fvm flutter analyze` after changes and fix any issues before considering the task complete.

## Key Patterns

### Session Status Display
```dart
// WRONG - doesn't account for time
_StatusBadge(status: session.status)

// CORRECT - shows real-time status
_StatusBadge(status: session.displayStatus)
```

### Blocking Actions on Past Sessions
```dart
// CORRECT - checks if session can be cancelled
if (session.canBeCancelled)
  CancelButton(...)
```

### Favorites System
- Uses Firestore stream with client-side sorting (no orderBy to avoid index requirement)
- `LoadFavoritesEvent` dispatched in each MainScaffold
- `ClearFavoritesEvent` dispatched on logout

### Multi-Type Sessions
- Sessions support multiple types: `types: List<SessionType>`
- Use `session.typeLabel` for display (not deprecated `session.type.label`)
- Use `session.types.firstOrNull` for icons (not deprecated `session.type`)

### Studio Working Hours
- `StudioProfile.workingHours: WorkingHours?`
- Passed to `AvailabilityPicker` and `AvailabilityService`
- Determines available booking slots

## Firebase Collections

### App Collections (used by Flutter app)

| Collection | Description |
|------------|-------------|
| `users` | User accounts with role-based fields, studioProfile |
| `useme_sessions` | Studio booking sessions |
| `useme_bookings` | Booking requests |
| `useme_artists` | Artist profiles linked to studios |
| `useme_studio_services` | Services offered by studios |
| `useme_studio_rooms` | Studio rooms/spaces |
| `useme_favorites` | User favorites (studios, engineers, artists) |
| `conversations` | Messaging between users |
| `messages` | Messages (subcollection of conversations) |
| `user_notifications` | User notifications |
| `team_invitations` | Engineer team invitations |
| `studio_invitations` | Artist studio invitations |
| `studio_claims` | Studio claim requests (pending approval) |
| `studio_requests` | Requests to add missing studios |
| `studio_unavailabilities` | Studio unavailable periods |
| `subscription_tiers` | Subscription tier configurations |
| `app_config` | App configuration (Stripe, etc.) |
| `ai_conversations` | AI assistant conversations |
| `ai_messages` | AI messages (subcollection) |
| `ai_settings` | AI configuration per studio |

## Role-Based Access

| Role | Access |
|------|--------|
| `superAdmin` | Full system access, approves studio claims |
| `admin` (Studio) | Manages own studio, engineers, sessions |
| `worker` (Engineer) | Views assigned sessions, manages availability |
| `client` (Artist) | Books sessions, views history |

## BLoC Events/States Naming

```dart
// Events: VerbNounEvent
LoadSessionsEvent, CreateArtistEvent, ToggleFavoriteEvent

// States: NounVerbedState or NounLoadingState
SessionsLoadedState, FavoriteLoadingState, SessionCreatedState
```

## Import Order

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// 4. Shared package
import 'package:smoothandesign_package/smoothandesign.dart';

// 5. Local imports
import 'package:uzme/core/models/session.dart';
```

## Related Projects

- **smoothbackend** (monorepo backend): `/Users/wesof./IdeaProjects/smoothbackend` — repo `ben-ndui/smoothbackend`
- **smoothandesign_package** (shared Flutter package): `/Users/wesof./IdeaProjects/smoothandesign_package`
- **useme-website** (Next.js support site): `/Users/wesof./IdeaProjects/useme-support` — repo `ben-ndui/useme-website` — domaine `usmi.app`
