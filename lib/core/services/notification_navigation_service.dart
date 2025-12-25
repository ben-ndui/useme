import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/routing/app_routes.dart';

/// Service for handling notification navigation in Use Me.
class NotificationNavigationService {
  static final NotificationNavigationService _instance =
      NotificationNavigationService._internal();
  factory NotificationNavigationService() => _instance;
  NotificationNavigationService._internal();

  GoRouter? _router;

  void setRouter(GoRouter router) {
    _router = router;
  }

  /// Navigate based on notification data
  void handleNotificationTap(RemoteMessage message) {
    if (_router == null) return;

    final route = getRouteForNotification(message.data);
    if (route != null) {
      _router!.push(route);
    }
  }

  /// Get route for notification data
  String? getRouteForNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'new_message':
        final conversationId = data['conversationId'];
        if (conversationId != null) {
          return '/conversations/$conversationId';
        }
        return AppRoutes.conversations;

      case 'session_assigned':
      case 'session_updated':
        final sessionId = data['sessionId'];
        if (sessionId != null) {
          return '/sessions/$sessionId';
        }
        return AppRoutes.sessions;

      case 'booking_confirmed':
      case 'booking_updated':
        final bookingId = data['bookingId'];
        if (bookingId != null) {
          return '/bookings/$bookingId';
        }
        return AppRoutes.bookings;

      case 'team_invitation':
        return AppRoutes.engineerInvitations;

      default:
        return AppRoutes.notifications;
    }
  }

  /// Navigate to a specific route
  void navigateTo(String route) {
    _router?.push(route);
  }
}
