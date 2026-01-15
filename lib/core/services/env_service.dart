import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service pour accéder aux variables d'environnement de manière sécurisée.
/// Centralise l'accès aux clés API et autres configurations sensibles.
class EnvService {
  EnvService._();

  /// Google Maps API Key pour Places API et Maps SDK.
  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// DevMaster User ID (accès aux configurations système).
  static String get devMasterUserId =>
      dotenv.env['DEV_MASTER_USER_ID'] ?? '';

  /// Vérifie si les variables d'environnement sont chargées.
  static bool get isLoaded => dotenv.isInitialized;
}
