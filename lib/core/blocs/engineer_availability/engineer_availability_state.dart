import 'package:equatable/equatable.dart';
import 'package:useme/core/models/models_exports.dart';

/// État des disponibilités ingénieur
class EngineerAvailabilityState extends Equatable {
  final String? engineerId;
  final WorkingHours? workingHours;
  final List<TimeOff> timeOffs;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const EngineerAvailabilityState({
    this.engineerId,
    this.workingHours,
    this.timeOffs = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  @override
  List<Object?> get props => [
        engineerId,
        workingHours,
        timeOffs,
        isLoading,
        errorMessage,
        successMessage,
      ];

  EngineerAvailabilityState copyWith({
    String? engineerId,
    WorkingHours? workingHours,
    List<TimeOff>? timeOffs,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return EngineerAvailabilityState(
      engineerId: engineerId ?? this.engineerId,
      workingHours: workingHours ?? this.workingHours,
      timeOffs: timeOffs ?? this.timeOffs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// État initial
class EngineerAvailabilityInitialState extends EngineerAvailabilityState {
  const EngineerAvailabilityInitialState() : super();
}

/// Chargement en cours
class EngineerAvailabilityLoadingState extends EngineerAvailabilityState {
  const EngineerAvailabilityLoadingState({
    super.engineerId,
    super.workingHours,
    super.timeOffs,
  }) : super(isLoading: true);
}

/// Disponibilités chargées
class EngineerAvailabilityLoadedState extends EngineerAvailabilityState {
  const EngineerAvailabilityLoadedState({
    required super.engineerId,
    required super.workingHours,
    required super.timeOffs,
  }) : super(isLoading: false);
}

/// Horaires mis à jour
class WorkingHoursUpdatedState extends EngineerAvailabilityState {
  const WorkingHoursUpdatedState({
    required super.engineerId,
    required super.workingHours,
    required super.timeOffs,
  }) : super(
          isLoading: false,
          successMessage: 'Horaires mis à jour',
        );
}

/// Time-off ajouté
class TimeOffAddedState extends EngineerAvailabilityState {
  final TimeOff addedTimeOff;

  const TimeOffAddedState({
    required this.addedTimeOff,
    required super.engineerId,
    required super.workingHours,
    required super.timeOffs,
  }) : super(
          isLoading: false,
          successMessage: 'Indisponibilité ajoutée',
        );

  @override
  List<Object?> get props => [...super.props, addedTimeOff];
}

/// Time-off supprimé
class TimeOffDeletedState extends EngineerAvailabilityState {
  final String deletedTimeOffId;

  const TimeOffDeletedState({
    required this.deletedTimeOffId,
    required super.engineerId,
    required super.workingHours,
    required super.timeOffs,
  }) : super(
          isLoading: false,
          successMessage: 'Indisponibilité supprimée',
        );

  @override
  List<Object?> get props => [...super.props, deletedTimeOffId];
}

/// État d'erreur
class EngineerAvailabilityErrorState extends EngineerAvailabilityState {
  const EngineerAvailabilityErrorState({
    required super.errorMessage,
    super.engineerId,
    super.workingHours,
    super.timeOffs,
  }) : super(isLoading: false);
}
