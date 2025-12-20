import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:useme/core/blocs/engineer_availability/engineer_availability_event.dart';
import 'package:useme/core/blocs/engineer_availability/engineer_availability_state.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/services_exports.dart';

/// BLoC pour gérer les disponibilités des ingénieurs
class EngineerAvailabilityBloc
    extends Bloc<EngineerAvailabilityEvent, EngineerAvailabilityState> {
  final EngineerAvailabilityService _service;
  StreamSubscription? _workingHoursSubscription;
  StreamSubscription? _timeOffsSubscription;

  EngineerAvailabilityBloc({EngineerAvailabilityService? service})
      : _service = service ?? EngineerAvailabilityService(),
        super(const EngineerAvailabilityInitialState()) {
    on<LoadEngineerAvailabilityEvent>(_onLoadAvailability);
    on<UpdateWorkingHoursEvent>(_onUpdateWorkingHours);
    on<UpdateDayScheduleEvent>(_onUpdateDaySchedule);
    on<AddTimeOffEvent>(_onAddTimeOff);
    on<DeleteTimeOffEvent>(_onDeleteTimeOff);
    on<_TimeOffsUpdatedInternalEvent>(_onTimeOffsUpdated);
  }

  void _onTimeOffsUpdated(
    _TimeOffsUpdatedInternalEvent event,
    Emitter<EngineerAvailabilityState> emit,
  ) {
    emit(EngineerAvailabilityLoadedState(
      engineerId: state.engineerId!,
      workingHours: state.workingHours!,
      timeOffs: event.timeOffs,
    ));
  }

  Future<void> _onLoadAvailability(
    LoadEngineerAvailabilityEvent event,
    Emitter<EngineerAvailabilityState> emit,
  ) async {
    emit(EngineerAvailabilityLoadingState(
      engineerId: event.engineerId,
      workingHours: state.workingHours,
      timeOffs: state.timeOffs,
    ));

    try {
      // Annuler les anciens streams
      await _workingHoursSubscription?.cancel();
      await _timeOffsSubscription?.cancel();

      // Charger les données initiales
      final workingHours = await _service.getWorkingHours(event.engineerId);

      emit(EngineerAvailabilityLoadedState(
        engineerId: event.engineerId,
        workingHours: workingHours,
        timeOffs: state.timeOffs,
      ));

      // Écouter les time-offs en temps réel
      _timeOffsSubscription = _service
          .streamFutureTimeOffs(event.engineerId)
          .listen((timeOffs) {
        if (!isClosed) {
          add(_TimeOffsUpdatedInternalEvent(timeOffs: timeOffs));
        }
      });
    } catch (e) {
      emit(EngineerAvailabilityErrorState(
        errorMessage: 'Erreur lors du chargement: $e',
        engineerId: event.engineerId,
        workingHours: state.workingHours,
        timeOffs: state.timeOffs,
      ));
    }
  }

  Future<void> _onUpdateWorkingHours(
    UpdateWorkingHoursEvent event,
    Emitter<EngineerAvailabilityState> emit,
  ) async {
    try {
      final response = await _service.setWorkingHours(
        event.engineerId,
        event.workingHours,
      );

      if (response.code == 200) {
        emit(WorkingHoursUpdatedState(
          engineerId: event.engineerId,
          workingHours: event.workingHours,
          timeOffs: state.timeOffs,
        ));
      } else {
        emit(EngineerAvailabilityErrorState(
          errorMessage: response.message,
          engineerId: state.engineerId,
          workingHours: state.workingHours,
          timeOffs: state.timeOffs,
        ));
      }
    } catch (e) {
      emit(EngineerAvailabilityErrorState(
        errorMessage: 'Erreur: $e',
        engineerId: state.engineerId,
        workingHours: state.workingHours,
        timeOffs: state.timeOffs,
      ));
    }
  }

  Future<void> _onUpdateDaySchedule(
    UpdateDayScheduleEvent event,
    Emitter<EngineerAvailabilityState> emit,
  ) async {
    if (state.workingHours == null) return;

    try {
      final updatedHours = state.workingHours!.copyWithDay(
        event.weekday,
        event.schedule,
      );

      final response = await _service.setWorkingHours(
        event.engineerId,
        updatedHours,
      );

      if (response.code == 200) {
        emit(WorkingHoursUpdatedState(
          engineerId: event.engineerId,
          workingHours: updatedHours,
          timeOffs: state.timeOffs,
        ));
      } else {
        emit(EngineerAvailabilityErrorState(
          errorMessage: response.message,
          engineerId: state.engineerId,
          workingHours: state.workingHours,
          timeOffs: state.timeOffs,
        ));
      }
    } catch (e) {
      emit(EngineerAvailabilityErrorState(
        errorMessage: 'Erreur: $e',
        engineerId: state.engineerId,
        workingHours: state.workingHours,
        timeOffs: state.timeOffs,
      ));
    }
  }

  Future<void> _onAddTimeOff(
    AddTimeOffEvent event,
    Emitter<EngineerAvailabilityState> emit,
  ) async {
    try {
      final response = await _service.addTimeOff(event.timeOff);

      if (response.code == 201 && response.data != null) {
        final updatedTimeOffs = [...state.timeOffs, response.data!];
        updatedTimeOffs.sort((a, b) => a.start.compareTo(b.start));

        emit(TimeOffAddedState(
          addedTimeOff: response.data!,
          engineerId: state.engineerId,
          workingHours: state.workingHours,
          timeOffs: updatedTimeOffs,
        ));
      } else {
        emit(EngineerAvailabilityErrorState(
          errorMessage: response.message,
          engineerId: state.engineerId,
          workingHours: state.workingHours,
          timeOffs: state.timeOffs,
        ));
      }
    } catch (e) {
      emit(EngineerAvailabilityErrorState(
        errorMessage: 'Erreur: $e',
        engineerId: state.engineerId,
        workingHours: state.workingHours,
        timeOffs: state.timeOffs,
      ));
    }
  }

  Future<void> _onDeleteTimeOff(
    DeleteTimeOffEvent event,
    Emitter<EngineerAvailabilityState> emit,
  ) async {
    try {
      final response = await _service.deleteTimeOff(event.timeOffId);

      if (response.code == 200) {
        final updatedTimeOffs = state.timeOffs
            .where((t) => t.id != event.timeOffId)
            .toList();

        emit(TimeOffDeletedState(
          deletedTimeOffId: event.timeOffId,
          engineerId: state.engineerId,
          workingHours: state.workingHours,
          timeOffs: updatedTimeOffs,
        ));
      } else {
        emit(EngineerAvailabilityErrorState(
          errorMessage: response.message,
          engineerId: state.engineerId,
          workingHours: state.workingHours,
          timeOffs: state.timeOffs,
        ));
      }
    } catch (e) {
      emit(EngineerAvailabilityErrorState(
        errorMessage: 'Erreur: $e',
        engineerId: state.engineerId,
        workingHours: state.workingHours,
        timeOffs: state.timeOffs,
      ));
    }
  }

  @override
  Future<void> close() {
    _workingHoursSubscription?.cancel();
    _timeOffsSubscription?.cancel();
    return super.close();
  }
}

/// Événement interne pour les mises à jour du stream
class _TimeOffsUpdatedInternalEvent extends EngineerAvailabilityEvent {
  final List<TimeOff> timeOffs;

  const _TimeOffsUpdatedInternalEvent({required this.timeOffs});

  @override
  List<Object?> get props => [timeOffs];
}
