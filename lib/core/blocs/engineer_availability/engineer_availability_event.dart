import 'package:equatable/equatable.dart';
import 'package:useme/core/models/models_exports.dart';

/// Base event pour les disponibilités ingénieur
abstract class EngineerAvailabilityEvent extends Equatable {
  const EngineerAvailabilityEvent();

  @override
  List<Object?> get props => [];
}

/// Charge les disponibilités d'un ingénieur
class LoadEngineerAvailabilityEvent extends EngineerAvailabilityEvent {
  final String engineerId;

  const LoadEngineerAvailabilityEvent({required this.engineerId});

  @override
  List<Object?> get props => [engineerId];
}

/// Met à jour les horaires de travail
class UpdateWorkingHoursEvent extends EngineerAvailabilityEvent {
  final String engineerId;
  final WorkingHours workingHours;

  const UpdateWorkingHoursEvent({
    required this.engineerId,
    required this.workingHours,
  });

  @override
  List<Object?> get props => [engineerId, workingHours];
}

/// Met à jour un jour spécifique des horaires
class UpdateDayScheduleEvent extends EngineerAvailabilityEvent {
  final String engineerId;
  final int weekday;
  final DaySchedule schedule;

  const UpdateDayScheduleEvent({
    required this.engineerId,
    required this.weekday,
    required this.schedule,
  });

  @override
  List<Object?> get props => [engineerId, weekday, schedule];
}

/// Ajoute une indisponibilité
class AddTimeOffEvent extends EngineerAvailabilityEvent {
  final TimeOff timeOff;

  const AddTimeOffEvent({required this.timeOff});

  @override
  List<Object?> get props => [timeOff];
}

/// Supprime une indisponibilité
class DeleteTimeOffEvent extends EngineerAvailabilityEvent {
  final String timeOffId;

  const DeleteTimeOffEvent({required this.timeOffId});

  @override
  List<Object?> get props => [timeOffId];
}
