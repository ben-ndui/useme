# Device Sessions - Gestion des Appareils Connectes

## Statut: Implemente

Cette fonctionnalite permet aux utilisateurs de voir et gerer tous les appareils sur lesquels ils sont connectes, avec possibilite de deconnexion a distance.

## Architecture

### Package (smoothandesign_package)

| Fichier | Description |
|---------|-------------|
| `lib/core/models/device_session.dart` | Modele DeviceSession avec serialisation |
| `lib/core/services/base_device_session_service.dart` | Service CRUD complet |
| `lib/core/widgets/device_sessions/device_session_tile.dart` | Widget tile par appareil |
| `lib/core/widgets/device_sessions/device_sessions_screen.dart` | Ecran principal |

### Use Me (specifique)

| Fichier | Description |
|---------|-------------|
| `lib/screens/shared/device_sessions_screen.dart` | Wrapper avec localisation |
| `lib/widgets/studio/settings/security_settings_section.dart` | Section dans Settings |
| `lib/routing/app_routes.dart` | Route `/settings/devices` |
| `lib/l10n/app_*.arb` | ~15 strings FR/EN |

## Modele DeviceSession

```dart
class DeviceSession {
  final String id;
  final String userId;
  final String deviceId;        // Identifiant unique du device
  final String deviceName;      // "iPhone 15 Pro", "Samsung Galaxy S24"
  final String deviceModel;     // "iPhone15,2", "SM-S928B"
  final DeviceType deviceType;  // ios, android, web, unknown
  final String? osVersion;      // "iOS 17.4", "Android 14"
  final String? appVersion;     // "1.2.3"
  final String? fcmToken;       // Pour notifications
  final String? ipAddress;      // IP de connexion
  final String? city;           // Ville detectee
  final String? country;        // Pays
  final DateTime loginAt;       // Date de connexion
  final DateTime lastActiveAt;  // Derniere activite
  final bool isActive;          // Session active ou revoquee
}
```

## Firestore Collection

**Collection:** `device_sessions`

```json
{
  "userId": "string",
  "deviceId": "string",
  "deviceName": "string",
  "deviceModel": "string",
  "deviceType": "ios|android|web|unknown",
  "osVersion": "string?",
  "appVersion": "string?",
  "fcmToken": "string?",
  "ipAddress": "string?",
  "city": "string?",
  "country": "string?",
  "loginAt": "timestamp",
  "lastActiveAt": "timestamp",
  "isActive": "boolean"
}
```

## Service API

```dart
class BaseDeviceSessionService {
  // Recuperation
  Stream<List<DeviceSession>> streamUserSessions(String userId);
  Future<DeviceSession?> getCurrentSession(String userId, String deviceId);

  // Gestion
  Future<String> createSession(DeviceSession session);
  Future<void> updateLastActive(String sessionId, {String? fcmToken});
  Future<void> revokeSession(String sessionId);
  Future<void> revokeAllOtherSessions(String userId, String currentDeviceId);
  Future<void> revokeAllSessions(String userId);

  // Detection remote logout
  Stream<bool> watchSessionRevoked(String sessionId);

  // Device Info
  static Future<DeviceInfo> getDeviceInfo();
  static Future<String> getStoredDeviceId();
  static Future<IpLocation?> getIpLocation();
}
```

## Integration Auth (main.dart)

### A la connexion

```dart
Future<void> _createDeviceSession(String userId) async {
  final fcmToken = await notificationService.getToken();
  final sessionId = await deviceSessionService.createSession(
    DeviceSession(
      userId: userId,
      fcmToken: fcmToken,
      // ... device info auto-detecte
    ),
  );
  _startSessionRevocationListener(sessionId);
}
```

### Detection deconnexion a distance

```dart
void _startSessionRevocationListener(String sessionId) {
  _sessionRevocationSubscription = deviceSessionService
      .watchSessionRevoked(sessionId)
      .listen((isRevoked) {
    if (isRevoked) {
      _handleRemoteLogout();
    }
  });
}
```

### A la deconnexion

```dart
// Dans SignOutEvent handler
await notificationService.removeToken();
_sessionRevocationSubscription?.cancel();
await deviceSessionService.clearLocalSession();
```

## UI

L'ecran affiche:
- Appareil actuel avec badge "Cet appareil"
- Liste des autres appareils avec:
  - Nom et modele
  - OS et version
  - Ville, Pays
  - Derniere activite
  - Bouton "Deconnecter"
- Bouton "Deconnecter tous les autres appareils"

## Localisation

### Francais (app_fr.arb)
```json
"connectedDevices": "Appareils connectes",
"thisDevice": "Cet appareil",
"disconnectDevice": "Deconnecter",
"disconnectAllOthers": "Deconnecter tous les autres appareils",
"activeNow": "Actif maintenant",
"activeAgo": "Actif {time}",
"disconnectedRemotely": "Vous avez ete deconnecte depuis un autre appareil"
```

### Anglais (app_en.arb)
```json
"connectedDevices": "Connected devices",
"thisDevice": "This device",
"disconnectDevice": "Disconnect",
"disconnectAllOthers": "Disconnect all other devices",
"activeNow": "Active now",
"activeAgo": "Active {time}",
"disconnectedRemotely": "You have been disconnected from another device"
```

## Dependances

- `device_info_plus: ^11.3.3` - Detection device
- `shared_preferences: ^2.5.3` - Stockage local
- `http: ^1.2.2` - Geolocalisation IP (ip-api.com)

## Notes Techniques

- **Device ID persistant**: `identifierForVendor` (iOS) ou `androidId` (Android)
- **Geolocalisation**: Via API gratuite ip-api.com (timeout 5s)
- **Rate limiting**: updateLastActive limite a 1x/session
- **Tri client-side**: Evite les index Firestore composites
- **Cleanup**: Sessions inactives > 30 jours peuvent etre nettoyees
