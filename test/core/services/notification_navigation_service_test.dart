import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/services/notification_navigation_service.dart';
import 'package:uzme/routing/app_routes.dart';

void main() {
  late NotificationNavigationService service;

  setUp(() {
    service = NotificationNavigationService();
  });

  group('NotificationNavigationService', () {
    test('returns conversations route for new_message', () {
      final route = service.getRouteForNotification({
        'type': 'new_message',
        'conversationId': 'conv-123',
      });
      expect(route, '/conversations/conv-123');
    });

    test('returns pro bookings route for pro_booking_request', () {
      final route = service.getRouteForNotification({
        'type': 'pro_booking_request',
        'sessionId': 'session-1',
        'proId': 'pro-1',
      });
      expect(route, AppRoutes.proBookingsReceived);
    });

    test('returns sessions route for session_assigned', () {
      final route = service.getRouteForNotification({
        'type': 'session_assigned',
        'sessionId': 'session-1',
      });
      expect(route, '/sessions/session-1');
    });

    test('returns bookings route for booking_confirmed', () {
      final route = service.getRouteForNotification({
        'type': 'booking_confirmed',
        'bookingId': 'booking-1',
      });
      expect(route, '/bookings/booking-1');
    });

    test('returns engineer invitations for team_invitation', () {
      final route = service.getRouteForNotification({
        'type': 'team_invitation',
      });
      expect(route, AppRoutes.engineerInvitations);
    });

    test('returns notifications for unknown type', () {
      final route = service.getRouteForNotification({
        'type': 'unknown',
      });
      expect(route, AppRoutes.notifications);
    });
  });
}
