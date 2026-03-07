import 'package:mocktail/mocktail.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/session_service.dart';
import 'package:useme/core/services/booking_service.dart';
import 'package:useme/core/services/subscription_config_service.dart';
import 'package:useme/core/services/favorite_service.dart';
import 'package:useme/core/services/artist_service.dart';
import 'package:useme/core/services/location_service.dart';
import 'package:useme/core/services/studio_discovery_service.dart';
import 'package:useme/core/services/unavailability_service.dart';
import 'package:useme/core/services/engineer_availability_service.dart';
import 'package:useme/core/services/team_service.dart';
import 'package:useme/core/services/service_catalog_service.dart';
import 'package:useme/core/services/studio_room_service.dart';

class MockSessionService extends Mock implements SessionService {}

class MockBookingService extends Mock implements BookingService {}

class MockSubscriptionConfigService extends Mock
    implements SubscriptionConfigService {}

class MockFavoriteService extends Mock implements FavoriteService {}

class MockArtistService extends Mock implements ArtistService {}

class MockLocationService extends Mock implements LocationService {}

class MockStudioDiscoveryService extends Mock
    implements StudioDiscoveryService {}

class MockUnavailabilityService extends Mock
    implements UnavailabilityService {}

class MockEngineerAvailabilityService extends Mock
    implements EngineerAvailabilityService {}

class MockTeamService extends Mock implements TeamService {}

class MockServiceCatalogService extends Mock
    implements ServiceCatalogService {}

/// Fake classes for mocktail registerFallbackValue
class FakeSession extends Fake implements Session {}

class FakeBooking extends Fake implements Booking {}

class FakeArtist extends Fake implements Artist {}

class FakeStudioService extends Fake implements StudioService {}

class MockStudioRoomService extends Mock implements StudioRoomService {}

class FakeStudioRoom extends Fake implements StudioRoom {}

class FakeTimeOff extends Fake implements TimeOff {}
