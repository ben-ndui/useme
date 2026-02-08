import 'dart:async';
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
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Callback pour les messages en foreground (affichage in-app)
  void Function(RemoteMessage)? onForegroundMessage;

  /// Callback pour la navigation quand une notification est tapée
  void Function(RemoteMessage)? onNotificationTap;

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

  /// Initialise le service SANS userId (à appeler au démarrage).
  Future<void> initialize({
    void Function(RemoteMessage)? onForegroundMessage,
    void Function(RemoteMessage)? onNotificationTap,
  }) async {
    this.onForegroundMessage = onForegroundMessage;
    this.onNotificationTap = onNotificationTap;

    // Configurer iOS foreground presentation (important!)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _baseService.initialize(
      androidChannelId: 'useme_channel',
      androidChannelName: 'UZME Notifications',
      onMessage: (message) {
        // Foreground: afficher banner in-app
        this.onForegroundMessage?.call(message);
      },
      onSelectNotification: _onLocalNotificationTap,
    );

    // Configurer le handler pour les taps sur notifications background
    _baseService.onMessageOpenedApp((message) {
      this.onNotificationTap?.call(message);
    });

    // Vérifier si l'app a été lancée via une notification
    final initialMessage = await _baseService.getInitialMessage();
    if (initialMessage != null) {
      this.onNotificationTap?.call(initialMessage);
    }

    // Écouter les refresh de token
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription =
        FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);

    // Demander les permissions automatiquement
    await requestPermissions();
    debugPrint('✅ Notifications initialisées, token: $fcmToken');
  }

  /// Gère le tap sur une notification locale
  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && onNotificationTap != null) {
      try {
        final data = Map<String, dynamic>.from(Uri.splitQueryString(payload));
        final message = RemoteMessage(
          data: data,
          notification: RemoteNotification(
            title: data['title'],
            body: data['body'],
          ),
        );
        onNotificationTap!(message);
      } catch (e) {
        debugPrint('❌ Erreur parsing notification payload: $e');
      }
    }
  }

  /// Demande les permissions de notification.
  Future<bool> requestPermissions() async {
    final granted = await _baseService.requestPermissions();
    if (granted) {
      // Après permission accordée, obtenir le token avec retry
      await _getTokenWithRetry();
    }
    return granted;
  }

  /// Obtient le token FCM avec retry (pour iOS APNS timing)
  Future<String?> _getTokenWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        if (i > 0) {
          await Future.delayed(Duration(milliseconds: 500 * i));
        }
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          debugPrint('✅ Token FCM obtenu (tentative ${i + 1}): ${token.substring(0, 20)}...');
          return token;
        }
      } catch (e) {
        debugPrint('⚠️ Tentative ${i + 1} échouée: $e');
      }
    }
    debugPrint('❌ Impossible d\'obtenir le token FCM après $maxRetries tentatives');
    return null;
  }

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
        channelName: 'UZME Notifications',
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
