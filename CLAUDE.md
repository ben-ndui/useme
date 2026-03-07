# CLAUDE.md

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
- **Routing**: go_router
- **Shared Package**: smoothandesign_package (shared components with Smooth Devis)
- **Localization**: flutter_localizations with ARB files

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

# Analyze specific files
fvm flutter analyze lib/path/to/file.dart

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
├── config/                    # Theme, constants
├── core/
│   ├── blocs/                # BloC state management
│   │   ├── feature/
│   │   │   ├── feature_bloc.dart
│   │   │   ├── feature_event.dart
│   │   │   ├── feature_state.dart
│   │   │   └── feature_exports.dart
│   ├── models/               # Data models (Equatable)
│   └── services/             # Firebase services
├── l10n/                     # Localizations (FR/EN)
│   ├── app_fr.arb           # French strings (primary)
│   └── app_en.arb           # English strings
├── routing/
│   ├── app_routes.dart      # Route constants
│   └── router.dart          # GoRouter configuration
├── screens/
│   ├── artist/              # Artist-specific screens
│   ├── engineer/            # Engineer-specific screens
│   ├── studio/              # Studio admin screens
│   ├── shared/              # Cross-role screens
│   └── admin/               # SuperAdmin screens
└── widgets/                  # Reusable widgets by domain
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

### Backend-Only Collections (Cloud Functions)

| Collection | Description |
|------------|-------------|
| `ai_actions_log` | AI action tracking/logs |
| `ai_analytics` | AI analytics data |
| `counters` | Document counters (invoice numbering) |
| `encryption_ivs` | Encryption initialization vectors |
| `invitation_codes` | Invitation codes |
| `payment_accounts` | Payment account records |
| `payment_distributions` | Payment distribution records |
| `xpTransactions` | Experience point transactions |

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
import 'package:useme/core/models/session.dart';
```

## Key Features Implemented

### Map & Search
- **Search by city/address**: `SearchByAddressEvent` in `map_event.dart` - geocoding search
- **"Search in this zone" button**: `search_in_zone_button.dart` - appears when map moves
- **Service filters**: Filter studios by services offered
- **Partner filter**: Show only verified partner studios

### Sessions & Booking
- **Calendar views**: Week, Month, List views in `artist_sessions_page.dart`
- **Export to phone calendar**: `add_2_calendar` package in `artist_session_detail_screen.dart`
- **Availability picker**: `availability_picker.dart` with engineer availability
- **Working hours**: `WorkingHours` model from smoothandesign_package

### Studios
- **Manual registration**: `manual_studio_form_screen.dart` - no Google Maps required
- **Studio types**: `StudioType` enum (pro, independent, amateur) with badges
- **Verification badges**: Partner verified badge in `studio_detail_bottom_sheet.dart`
- **Studio claiming**: Claim existing Google Places studios via `studio_claim_screen.dart`

### Calendar Integration
- **Google Calendar import**: `CalendarBloc` with OAuth flow
- **Unavailabilities sync**: Import events as unavailabilities
- **Calendar review screen**: `calendar_import_review_screen.dart`

### Messaging
- **Contact search**: `new_conversation_bottom_sheet.dart` - search by name/email
- **AI Assistant**: `chat_assistant_service.dart` with intent detection
- **Voice messages**: Audio recording in conversations
- **Reactions**: Message reactions with emojis

### User Management
- **Multi-studio support**: `studioIds: List<String>` in AppUser for artists
- **Team invitations**: Invite engineers to studio team
- **Artist invitations**: Invite artists to studio
- **Device sessions**: `device_sessions_screen.dart` - manage connected devices

### Shared Package (smoothandesign_package)
Components migrated to shared package for reuse:
- Models: `WorkingHours`, `Unavailability`, `CalendarConnection`
- BLoCs: `LocaleBloc`
- Widgets: `AppSnackBar`, `AppLoader`, `FloatingBottomNav`, `NotificationBell`
- Glass widgets: `GlassChip`, `GlassEmptyState`, `GlassSectionHeader`
- Settings: `SettingsTile`, `SettingsSectionHeader`

## Backend

Cloud Functions located in `/Users/wesof./IdeaProjects/smoothbackend`:
- Notification triggers (invitations, messages, bookings)
- Push notifications via FCM
- Firestore security rules

## Related Projects

- **smoothandesign_package**: `/Users/wesof./IdeaProjects/smoothandesign_package`
- **smoothbackend**: `/Users/wesof./IdeaProjects/smoothbackend`
- **smoothdevis**: `/Users/wesof./IdeaProjects/smoothdevis` (uses same backend)
