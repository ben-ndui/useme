# Corrections du Feedback Ben - Janvier 2026

Ce document resume les corrections apportees suite au feedback utilisateur.

## Statut des fonctionnalites demandees

| Fonctionnalite | Statut | Details |
|----------------|--------|---------|
| Reset password OAuth | Implemente | Bloque pour comptes Google/Apple |
| Bouton reserve superpose | Corrige | Padding FAB centralise |
| Retour -> home | Deja present | PopScope dans tous les scaffolds |

---

## 1. Bloquer reset password pour comptes Google/Apple

### Probleme
Les utilisateurs connectes via Google ou Apple recevaient des emails de reset password inutiles.

### Solution
Ajout d'une verification dans `BaseAuthService.resetPassword()` :
- Appel `fetchSignInMethodsForEmail` pour verifier la methode de connexion
- Si compte OAuth uniquement (pas de `password` dans les methodes) -> retourne code 403
- L'UI affiche un message localise : "Ce compte utilise Google. Connectez-vous avec Google."

### Fichiers modifies
- `smoothandesign_package/lib/core/services/base_auth_service.dart`
- `useme/lib/screens/auth/login_screen.dart`
- `useme/lib/l10n/app_fr.arb` et `app_en.arb`

### Localisations ajoutees
```json
"oauthAccountResetError": "Ce compte utilise {provider}. Connectez-vous avec {provider}.",
"passwordResetSent": "Email de reinitialisation envoye a {email}"
```

---

## 2. Fix bouton reserve superpose (Samsung S25)

### Probleme
Sur certains appareils Samsung (S25, etc.), le FAB "Reserver" chevauchait la barre de navigation flottante.

### Solution
Centralisation du padding FAB dans une constante `Responsive.fabBottomOffset` :
- Valeur: 80px (hauteur navbar 72px + 8px marge)
- Utilisation coherente dans tous les ecrans avec FAB

### Fichiers modifies
- `useme/lib/config/responsive_config.dart` - Ajout constantes
- `useme/lib/screens/artist/artist_sessions_page.dart`
- `useme/lib/screens/artist/artist_portal_page.dart`
- `useme/lib/screens/studio/sessions_page.dart`
- `useme/lib/screens/studio/artists_page.dart`

### Nouvelles constantes
```dart
static const double floatingNavHeight = 72;
static const double fabBottomOffset = 80;
```

---

## 3. Bouton retour -> home avant quitter app

### Statut
Deja implemente dans tous les scaffolds principaux.

### Implementation existante
```dart
PopScope(
  canPop: _currentIndex == 0,
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop && _currentIndex != 0) {
      _onNavTap(0); // Retour a home
    }
  },
  child: ...
)
```

### Fichiers concernes
- `useme/lib/screens/studio/studio_main_scaffold.dart`
- `useme/lib/screens/artist/artist_main_scaffold.dart`
- `useme/lib/screens/engineer/engineer_main_scaffold.dart`

---

## Tests recommandes

1. **OAuth reset password**
   - Creer un compte via Google
   - Tenter de reinitialiser le mot de passe
   - Verifier le message d'avertissement

2. **FAB superpose**
   - Tester sur Samsung S25 ou appareil similaire
   - Verifier que le FAB est au-dessus de la navbar
   - Tester en mode portrait et paysage

3. **Retour Android**
   - Naviguer vers une page autre que home
   - Appuyer sur le bouton retour
   - Verifier le retour a home au lieu de quitter
