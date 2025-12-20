import 'package:equatable/equatable.dart';

/// Représente les horaires d'une journée
class DaySchedule extends Equatable {
  final String start; // Format "HH:mm" ex: "09:00"
  final String end; // Format "HH:mm" ex: "18:00"
  final bool enabled; // true si travaille ce jour

  const DaySchedule({
    required this.start,
    required this.end,
    required this.enabled,
  });

  /// Horaire par défaut : 9h-18h, activé
  factory DaySchedule.defaultEnabled() {
    return const DaySchedule(start: '09:00', end: '18:00', enabled: true);
  }

  /// Jour de repos par défaut
  factory DaySchedule.defaultDisabled() {
    return const DaySchedule(start: '09:00', end: '18:00', enabled: false);
  }

  /// Parse l'heure de début en TimeOfDay-like (heures, minutes)
  (int hours, int minutes) get startTime {
    final parts = start.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Parse l'heure de fin en TimeOfDay-like
  (int hours, int minutes) get endTime {
    final parts = end.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Vérifie si une heure donnée est dans ce créneau
  bool containsTime(int hour, int minute) {
    if (!enabled) return false;

    final (startH, startM) = startTime;
    final (endH, endM) = endTime;

    final timeMinutes = hour * 60 + minute;
    final startMinutes = startH * 60 + startM;
    final endMinutes = endH * 60 + endM;

    return timeMinutes >= startMinutes && timeMinutes < endMinutes;
  }

  Map<String, dynamic> toMap() {
    return {
      'start': start,
      'end': end,
      'enabled': enabled,
    };
  }

  factory DaySchedule.fromMap(Map<String, dynamic>? map) {
    if (map == null) return DaySchedule.defaultDisabled();
    return DaySchedule(
      start: map['start'] as String? ?? '09:00',
      end: map['end'] as String? ?? '18:00',
      enabled: map['enabled'] as bool? ?? false,
    );
  }

  DaySchedule copyWith({String? start, String? end, bool? enabled}) {
    return DaySchedule(
      start: start ?? this.start,
      end: end ?? this.end,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props => [start, end, enabled];
}

/// Représente les horaires de travail hebdomadaires d'un ingénieur
class WorkingHours extends Equatable {
  final DaySchedule monday;
  final DaySchedule tuesday;
  final DaySchedule wednesday;
  final DaySchedule thursday;
  final DaySchedule friday;
  final DaySchedule saturday;
  final DaySchedule sunday;

  const WorkingHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  /// Horaires par défaut : Lun-Ven 9h-18h, Sam-Dim repos
  factory WorkingHours.defaultSchedule() {
    return WorkingHours(
      monday: DaySchedule.defaultEnabled(),
      tuesday: DaySchedule.defaultEnabled(),
      wednesday: DaySchedule.defaultEnabled(),
      thursday: DaySchedule.defaultEnabled(),
      friday: DaySchedule.defaultEnabled(),
      saturday: DaySchedule.defaultDisabled(),
      sunday: DaySchedule.defaultDisabled(),
    );
  }

  /// Récupère le schedule pour un jour de la semaine (1=lundi, 7=dimanche)
  DaySchedule getScheduleForDay(int weekday) {
    return switch (weekday) {
      1 => monday,
      2 => tuesday,
      3 => wednesday,
      4 => thursday,
      5 => friday,
      6 => saturday,
      7 => sunday,
      _ => monday,
    };
  }

  /// Vérifie si l'ingénieur travaille à un moment donné
  bool isWorkingAt(DateTime dateTime) {
    final schedule = getScheduleForDay(dateTime.weekday);
    return schedule.containsTime(dateTime.hour, dateTime.minute);
  }

  /// Vérifie si l'ingénieur travaille pendant toute une période
  bool isWorkingDuring(DateTime start, DateTime end) {
    // Vérifier que start et end sont le même jour
    if (start.year != end.year || start.month != end.month || start.day != end.day) {
      // Pour les sessions multi-jours, on vérifie chaque jour
      DateTime current = start;
      while (current.isBefore(end)) {
        if (!isWorkingAt(current)) return false;
        current = current.add(const Duration(hours: 1));
      }
      return true;
    }

    // Même jour : vérifier début et fin
    return isWorkingAt(start) && isWorkingAt(end.subtract(const Duration(minutes: 1)));
  }

  /// Liste des jours avec leurs noms en français
  static const List<String> dayNames = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  /// Récupère le nom du jour (1=lundi)
  static String getDayName(int weekday) => dayNames[weekday - 1];

  Map<String, dynamic> toMap() {
    return {
      'monday': monday.toMap(),
      'tuesday': tuesday.toMap(),
      'wednesday': wednesday.toMap(),
      'thursday': thursday.toMap(),
      'friday': friday.toMap(),
      'saturday': saturday.toMap(),
      'sunday': sunday.toMap(),
    };
  }

  factory WorkingHours.fromMap(Map<String, dynamic>? map) {
    if (map == null) return WorkingHours.defaultSchedule();
    return WorkingHours(
      monday: DaySchedule.fromMap(map['monday'] as Map<String, dynamic>?),
      tuesday: DaySchedule.fromMap(map['tuesday'] as Map<String, dynamic>?),
      wednesday: DaySchedule.fromMap(map['wednesday'] as Map<String, dynamic>?),
      thursday: DaySchedule.fromMap(map['thursday'] as Map<String, dynamic>?),
      friday: DaySchedule.fromMap(map['friday'] as Map<String, dynamic>?),
      saturday: DaySchedule.fromMap(map['saturday'] as Map<String, dynamic>?),
      sunday: DaySchedule.fromMap(map['sunday'] as Map<String, dynamic>?),
    );
  }

  WorkingHours copyWithDay(int weekday, DaySchedule schedule) {
    return WorkingHours(
      monday: weekday == 1 ? schedule : monday,
      tuesday: weekday == 2 ? schedule : tuesday,
      wednesday: weekday == 3 ? schedule : wednesday,
      thursday: weekday == 4 ? schedule : thursday,
      friday: weekday == 5 ? schedule : friday,
      saturday: weekday == 6 ? schedule : saturday,
      sunday: weekday == 7 ? schedule : sunday,
    );
  }

  @override
  List<Object?> get props => [monday, tuesday, wednesday, thursday, friday, saturday, sunday];
}
