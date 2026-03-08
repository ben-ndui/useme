import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service pour accéder aux variables d'environnement de manière sécurisée.
/// Centralise l'accès aux clés API et autres configurations sensibles.
class EnvService {
  EnvService._();

  static const _defaultGoogleMapsKey = 'AIzaSyBQFkJ6oG4RTRRb6RbJ3Tk0MfrA1seHTqM';

  /// Google Maps API Key pour Places API et Maps SDK.
  /// En dev, chargée depuis assets/.env. En prod, fallback sur la clé
  /// déjà présente dans AndroidManifest.xml et AppDelegate.swift.
  static String get googleMapsApiKey {
    if (!dotenv.isInitialized) return _defaultGoogleMapsKey;
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? _defaultGoogleMapsKey;
  }

  /// Vérifie si les variables d'environnement sont chargées.
  static bool get isLoaded => dotenv.isInitialized;
}
