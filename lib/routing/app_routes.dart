/// Route names for Use Me application
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';

  // Studio (Admin) routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Session routes (Studio)
  static const String sessions = '/sessions';
  static const String sessionDetail = '/sessions/:id';
  static const String sessionAdd = '/sessions/add';
  static const String sessionEdit = '/sessions/:id/edit';

  // Artist routes (Studio)
  static const String artists = '/artists';
  static const String artistDetail = '/artists/:id';
  static const String artistAdd = '/artists/add';
  static const String artistEdit = '/artists/:id/edit';

  // Service catalog routes (Studio)
  static const String services = '/services';
  static const String serviceDetail = '/services/:id';
  static const String serviceAdd = '/services/add';
  static const String serviceEdit = '/services/:id/edit';

  // Booking routes (Studio)
  static const String bookings = '/bookings';
  static const String bookingDetail = '/bookings/:id';
  static const String bookingAdd = '/bookings/add';

  // Engineer routes
  static const String engineerDashboard = '/engineer';
  static const String sessionTracking = '/engineer/session/:id';
  static const String engineerAvailability = '/engineer/availability';

  // Artist (Client) portal routes
  static const String artistPortal = '/artist';
  static const String artistSessions = '/artist/sessions';
  static const String artistSessionDetail = '/artist/sessions/:id';
  static const String artistSessionRequest = '/artist/sessions/request';
  static const String artistProfile = '/artist/profile';
  static const String artistSettings = '/artist/settings';

  // Profile & Settings
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Team management (Studio)
  static const String teamManagement = '/team';

  // Studio claim
  static const String studioClaim = '/studio/claim';
  static const String studioCreate = '/studio/create';
  static const String paymentMethods = '/studio/payment-methods';

  // Notifications
  static const String notifications = '/notifications';

  // Messaging
  static const String conversations = '/conversations';
  static const String chat = '/conversations/:id';

  // About
  static const String about = '/about';

  // Favorites
  static const String favorites = '/favorites';
}
