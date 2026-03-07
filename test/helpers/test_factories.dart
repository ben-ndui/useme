import 'package:useme/core/models/session.dart';
import 'package:useme/core/models/booking.dart';

/// Factory pour créer des sessions de test facilement.
class SessionFactory {
  static Session create({
    String id = 'session-1',
    String studioId = 'studio-1',
    String? roomId,
    String? roomName,
    String? engineerId,
    String? engineerName,
    List<String> engineerIds = const [],
    List<String> engineerNames = const [],
    List<String> proposedEngineerIds = const [],
    List<String> artistIds = const ['artist-1'],
    List<String> artistNames = const ['Test Artist'],
    List<SessionType>? types,
    SessionStatus status = SessionStatus.pending,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    int durationMinutes = 60,
    String? notes,
    SessionIntervention? intervention,
    DateTime? createdAt,
  }) {
    return Session(
      id: id,
      studioId: studioId,
      roomId: roomId,
      roomName: roomName,
      engineerId: engineerId,
      engineerName: engineerName,
      engineerIds: engineerIds,
      engineerNames: engineerNames,
      proposedEngineerIds: proposedEngineerIds,
      artistIds: artistIds,
      artistNames: artistNames,
      types: types,
      status: status,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      durationMinutes: durationMinutes,
      notes: notes,
      intervention: intervention,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Session dans le futur (demain, 2h)
  static Session future({
    SessionStatus status = SessionStatus.confirmed,
    List<SessionType>? types,
    String? engineerId,
    List<String> engineerIds = const [],
  }) {
    final start = DateTime.now().add(const Duration(days: 1));
    return create(
      status: status,
      types: types,
      engineerId: engineerId,
      engineerIds: engineerIds,
      scheduledStart: start,
      scheduledEnd: start.add(const Duration(hours: 2)),
      durationMinutes: 120,
    );
  }

  /// Session en cours maintenant
  static Session happening({
    SessionStatus status = SessionStatus.confirmed,
  }) {
    final start = DateTime.now().subtract(const Duration(minutes: 30));
    return create(
      status: status,
      scheduledStart: start,
      scheduledEnd: start.add(const Duration(hours: 2)),
      durationMinutes: 120,
    );
  }

  /// Session passée (hier)
  static Session past({
    SessionStatus status = SessionStatus.confirmed,
  }) {
    final start = DateTime.now().subtract(const Duration(days: 1, hours: 2));
    return create(
      status: status,
      scheduledStart: start,
      scheduledEnd: start.add(const Duration(hours: 2)),
      durationMinutes: 120,
    );
  }
}

/// Factory pour créer des bookings de test.
class BookingFactory {
  static Booking create({
    String id = 'booking-1',
    String studioId = 'studio-1',
    String artistId = 'artist-1',
    String artistName = 'Test Artist',
    String? sessionId,
    BookingStatus status = BookingStatus.draft,
    double totalAmount = 100.0,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? notes,
    String? cancellationReason,
  }) {
    return Booking(
      id: id,
      studioId: studioId,
      artistId: artistId,
      artistName: artistName,
      sessionId: sessionId,
      status: status,
      totalAmount: totalAmount,
      createdAt: createdAt ?? DateTime.now(),
      confirmedAt: confirmedAt,
      completedAt: completedAt,
      cancelledAt: cancelledAt,
      notes: notes,
      cancellationReason: cancellationReason,
    );
  }
}
