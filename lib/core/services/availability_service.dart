import '../models/session.dart';
import '../models/unavailability.dart';
import 'engineer_availability_service.dart';
import 'session_service.dart';
import 'team_service.dart';
import 'unavailability_service.dart';

/// Représente un créneau horaire disponible
class TimeSlot {
  final DateTime start;
  final DateTime end;
  final bool isAvailable;

  const TimeSlot({
    required this.start,
    required this.end,
    this.isAvailable = true,
  });

  int get durationMinutes => end.difference(start).inMinutes;

  @override
  String toString() => '${start.hour}:${start.minute.toString().padLeft(2, '0')} - '
      '${end.hour}:${end.minute.toString().padLeft(2, '0')}';
}

/// Créneau enrichi avec info sur les ingénieurs disponibles
class EnhancedTimeSlot extends TimeSlot {
  final List<AvailableEngineer> availableEngineers;
  final int totalEngineers;

  const EnhancedTimeSlot({
    required super.start,
    required super.end,
    required super.isAvailable,
    required this.availableEngineers,
    required this.totalEngineers,
  });

  /// Nombre d'ingénieurs disponibles
  int get availableCount => availableEngineers.where((e) => e.isAvailable).length;

  /// Au moins un ingénieur est disponible
  bool get hasAvailableEngineer => availableCount > 0;

  /// Niveau de disponibilité (pour affichage badge)
  AvailabilityLevel get availabilityLevel {
    if (!isAvailable) return AvailabilityLevel.unavailable;
    if (availableCount == 0) return AvailabilityLevel.noEngineer;
    if (availableCount == 1) return AvailabilityLevel.limited;
    if (availableCount < totalEngineers) return AvailabilityLevel.partial;
    return AvailabilityLevel.full;
  }
}

/// Niveau de disponibilité d'un créneau
enum AvailabilityLevel {
  unavailable,  // Studio indisponible
  noEngineer,   // Aucun ingénieur dispo
  limited,      // 1 seul ingénieur
  partial,      // Quelques ingénieurs
  full,         // Tous les ingénieurs
}

/// Service pour calculer les disponibilités d'un studio
class AvailabilityService {
  final SessionService _sessionService;
  final UnavailabilityService _unavailabilityService;
  final EngineerAvailabilityService _engineerService;
  final TeamService _teamService;

  // Horaires d'ouverture par défaut (9h-22h)
  static const int defaultOpeningHour = 9;
  static const int defaultClosingHour = 22;
  static const int defaultSlotDurationMinutes = 60;

  AvailabilityService({
    SessionService? sessionService,
    UnavailabilityService? unavailabilityService,
    EngineerAvailabilityService? engineerService,
    TeamService? teamService,
  })  : _sessionService = sessionService ?? SessionService(),
        _unavailabilityService = unavailabilityService ?? UnavailabilityService(),
        _engineerService = engineerService ?? EngineerAvailabilityService(),
        _teamService = teamService ?? TeamService();

  /// Récupère les créneaux disponibles pour un jour donné
  Future<List<TimeSlot>> getAvailableSlots({
    required String studioId,
    required DateTime date,
    int slotDurationMinutes = defaultSlotDurationMinutes,
    int openingHour = defaultOpeningHour,
    int closingHour = defaultClosingHour,
  }) async {
    // 1. Récupérer les sessions confirmées du jour
    final sessions = await _getSessionsForDate(studioId, date);

    // 2. Récupérer les indisponibilités du jour
    final unavailabilities = await _unavailabilityService.getByDate(studioId, date);

    // 3. Calculer les créneaux disponibles
    return _calculateAvailableSlots(
      date: date,
      sessions: sessions,
      unavailabilities: unavailabilities,
      slotDurationMinutes: slotDurationMinutes,
      openingHour: openingHour,
      closingHour: closingHour,
    );
  }

  /// Récupère les créneaux enrichis avec info ingénieurs
  Future<List<EnhancedTimeSlot>> getEnhancedSlots({
    required String studioId,
    required DateTime date,
    int slotDurationMinutes = defaultSlotDurationMinutes,
    int openingHour = defaultOpeningHour,
    int closingHour = defaultClosingHour,
  }) async {
    // 1. Récupérer les créneaux basiques
    final sessions = await _getSessionsForDate(studioId, date);
    final unavailabilities = await _unavailabilityService.getByDate(studioId, date);

    // 2. Récupérer l'équipe du studio
    final engineers = await _teamService.getTeamMembers(studioId);
    final totalEngineers = engineers.length;

    // 3. Générer les créneaux enrichis
    final slots = <EnhancedTimeSlot>[];
    final slotDuration = Duration(minutes: slotDurationMinutes);

    var currentTime = DateTime(date.year, date.month, date.day, openingHour);
    final closingTime = DateTime(date.year, date.month, date.day, closingHour);

    while (currentTime.add(slotDuration).isBefore(closingTime) ||
        currentTime.add(slotDuration).isAtSameMomentAs(closingTime)) {
      final slotEnd = currentTime.add(slotDuration);

      // Vérifier disponibilité studio
      final studioAvailable = _isSlotAvailableLocal(
        currentTime,
        slotEnd,
        sessions,
        unavailabilities,
      );

      // Vérifier disponibilité ingénieurs
      List<AvailableEngineer> availableEngineers = [];
      if (studioAvailable && engineers.isNotEmpty) {
        availableEngineers = await _engineerService.getAvailableEngineers(
          studioId: studioId,
          start: currentTime,
          end: slotEnd,
        );
      }

      slots.add(EnhancedTimeSlot(
        start: currentTime,
        end: slotEnd,
        isAvailable: studioAvailable,
        availableEngineers: availableEngineers,
        totalEngineers: totalEngineers,
      ));

      currentTime = slotEnd;
    }

    return slots;
  }

  /// Vérifie si un créneau spécifique est disponible
  Future<bool> isSlotAvailable({
    required String studioId,
    required DateTime start,
    required DateTime end,
  }) async {
    // Vérifier les sessions confirmées
    final sessions = await _getSessionsForDate(studioId, start);
    for (final session in sessions) {
      if (_overlaps(start, end, session.scheduledStart, session.scheduledEnd)) {
        return false;
      }
    }

    // Vérifier les indisponibilités
    final hasConflict = await _unavailabilityService.hasConflict(studioId, start, end);
    return !hasConflict;
  }

  /// Récupère les sessions confirmées pour une date
  Future<List<Session>> _getSessionsForDate(String studioId, DateTime date) async {
    final allSessions = await _sessionService.getSessions(studioId);
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return allSessions.where((session) {
      // Seulement les sessions confirmées ou en cours
      if (session.status != SessionStatus.confirmed &&
          session.status != SessionStatus.inProgress) {
        return false;
      }
      // Sessions qui chevauchent le jour
      return session.scheduledStart.isBefore(endOfDay) &&
          session.scheduledEnd.isAfter(startOfDay);
    }).toList();
  }

  /// Calcule les créneaux disponibles
  List<TimeSlot> _calculateAvailableSlots({
    required DateTime date,
    required List<Session> sessions,
    required List<Unavailability> unavailabilities,
    required int slotDurationMinutes,
    required int openingHour,
    required int closingHour,
  }) {
    final slots = <TimeSlot>[];
    final slotDuration = Duration(minutes: slotDurationMinutes);

    // Créer tous les créneaux possibles
    var currentTime = DateTime(date.year, date.month, date.day, openingHour);
    final closingTime = DateTime(date.year, date.month, date.day, closingHour);

    while (currentTime.add(slotDuration).isBefore(closingTime) ||
        currentTime.add(slotDuration).isAtSameMomentAs(closingTime)) {
      final slotEnd = currentTime.add(slotDuration);

      // Vérifier si le créneau est disponible
      final isAvailable = _isSlotAvailableLocal(
        currentTime,
        slotEnd,
        sessions,
        unavailabilities,
      );

      slots.add(TimeSlot(
        start: currentTime,
        end: slotEnd,
        isAvailable: isAvailable,
      ));

      currentTime = slotEnd;
    }

    return slots;
  }

  /// Vérifie localement si un créneau est disponible
  bool _isSlotAvailableLocal(
    DateTime start,
    DateTime end,
    List<Session> sessions,
    List<Unavailability> unavailabilities,
  ) {
    // Vérifier les conflits avec les sessions
    for (final session in sessions) {
      if (_overlaps(start, end, session.scheduledStart, session.scheduledEnd)) {
        return false;
      }
    }

    // Vérifier les conflits avec les indisponibilités
    for (final unavailability in unavailabilities) {
      if (unavailability.overlapsWith(start, end)) {
        return false;
      }
    }

    return true;
  }

  /// Vérifie si deux périodes se chevauchent
  bool _overlaps(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }
}
