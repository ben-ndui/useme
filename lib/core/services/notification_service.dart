import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smoothandesign_package/smoothandesign.dart';

/// Service de notifications pour Use Me.
/// Wrapper autour de BaseNotificationService avec sauvegarde du token.
class UseMeNotificationService {
  static UseMeNotificationService? _instance;
  String? _currentUserId;
  final BaseNotificationService _baseService = BaseNotificationService.instance;

  UseMeNotificationService._();

  /// Singleton instance.
  static UseMeNotificationService get instance {
    _instance ??= UseMeNotificationService._();
    return _instance!;
  }

  /// Token FCM actuel.
  String? get fcmToken => _baseService.fcmToken;

  /// Indique si le service est initialisé.
  bool get isInitialized => _baseService.isInitialized;

  /// Initialise le service avec l'ID utilisateur.
  Future<void> initializeForUser({
    required String userId,
    void Function(RemoteMessage)? onMessage,
    void Function(NotificationResponse)? onSelectNotification,
  }) async {
    _currentUserId = userId;

    await _baseService.initialize(
      androidChannelId: 'useme_channel',
      androidChannelName: 'Use Me Notifications',
      onMessage: onMessage,
      onSelectNotification: onSelectNotification,
    );

    // Écouter les refresh de token
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);

    // Sauvegarder le token initial
    if (fcmToken != null) {
      await _saveTokenToFirestore(fcmToken!);
    }
  }

  /// Demande les permissions de notification.
  Future<bool> requestPermissions() => _baseService.requestPermissions();

  /// Vérifie si les permissions sont accordées.
  Future<bool> hasPermissions() => _baseService.hasPermissions();

  /// Affiche une notification locale.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) =>
      _baseService.showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        channelId: 'useme_channel',
        channelName: 'Use Me Notifications',
      );

  /// Récupère le message initial (app lancée via notification).
  Future<RemoteMessage?> getInitialMessage() => _baseService.getInitialMessage();

  /// Configure le handler pour les notifications tapées.
  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    _baseService.onMessageOpenedApp(handler);
  }

  void _onTokenRefresh(String token) {
    _saveTokenToFirestore(token);
  }

  /// Sauvegarde le token FCM dans Firestore.
  Future<void> _saveTokenToFirestore(String token) async {
    if (_currentUserId == null) return;

    try {
      await SmoothFirebase.collection('users').doc(_currentUserId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Token FCM sauvegardé pour $_currentUserId');
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde token FCM: $e');
    }
  }

  /// Supprime le token FCM de Firestore (déconnexion).
  Future<void> removeToken() async {
    if (_currentUserId == null) return;

    try {
      await SmoothFirebase.collection('users').doc(_currentUserId).update({
        'fcmToken': null,
      });
      debugPrint('🗑️ Token FCM supprimé pour $_currentUserId');
    } catch (e) {
      debugPrint('❌ Erreur suppression token FCM: $e');
    }

    _currentUserId = null;
  }

  /// Met à jour l'ID utilisateur (après login).
  void setUserId(String userId) {
    _currentUserId = userId;
    if (fcmToken != null) {
      _saveTokenToFirestore(fcmToken!);
    }
  }
}
