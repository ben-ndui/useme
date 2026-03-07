import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:useme/core/services/pro_profile_service.dart';
import 'pro_profile_event.dart';
import 'pro_profile_state.dart';

class ProProfileBloc extends Bloc<ProProfileEvent, ProProfileState> {
  final ProProfileService _service;

  ProProfileBloc({ProProfileService? service})
      : _service = service ?? ProProfileService(),
        super(const ProProfileState()) {
    on<LoadProProfileEvent>(_onLoad);
    on<ActivateProProfileEvent>(_onActivate);
    on<UpdateProProfileEvent>(_onUpdate);
    on<SetProAvailabilityEvent>(_onSetAvailability);
    on<DeactivateProProfileEvent>(_onDeactivate);
    on<DeleteProProfileEvent>(_onDelete);
    on<SearchProsEvent>(_onSearch);
    on<ClearProProfileEvent>(_onClear);
  }

  Future<void> _onLoad(
    LoadProProfileEvent event,
    Emitter<ProProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final profile = await _service.getProProfile(event.userId);
    emit(state.copyWith(
      profile: profile,
      isLoading: false,
      clearProfile: profile == null,
    ));
  }

  Future<void> _onActivate(
    ActivateProProfileEvent event,
    Emitter<ProProfileState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await _service.activateProProfile(
      userId: event.userId,
      profile: event.profile,
    );

    if (result.code == 200) {
      emit(state.copyWith(
        profile: result.data,
        isSaving: false,
        successMessage: result.message,
      ));
    } else {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: result.message,
      ));
    }
  }

  Future<void> _onUpdate(
    UpdateProProfileEvent event,
    Emitter<ProProfileState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await _service.updateProProfile(
      userId: event.userId,
      profile: event.profile,
    );

    if (result.data == true) {
      emit(state.copyWith(
        profile: event.profile,
        isSaving: false,
        successMessage: result.message,
      ));
    } else {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: result.message,
      ));
    }
  }

  Future<void> _onSetAvailability(
    SetProAvailabilityEvent event,
    Emitter<ProProfileState> emit,
  ) async {
    final result = await _service.setAvailability(
      userId: event.userId,
      isAvailable: event.isAvailable,
    );

    if (result.data == true && state.profile != null) {
      emit(state.copyWith(
        profile: state.profile!.copyWith(isAvailable: event.isAvailable),
      ));
    } else {
      emit(state.copyWith(errorMessage: result.message));
    }
  }

  Future<void> _onDeactivate(
    DeactivateProProfileEvent event,
    Emitter<ProProfileState> emit,
  ) async {
    final result = await _service.deactivateProProfile(event.userId);

    if (result.data == true && state.profile != null) {
      emit(state.copyWith(
        profile: state.profile!.copyWith(isAvailable: false),
        successMessage: result.message,
      ));
    } else {
      emit(state.copyWith(errorMessage: result.message));
    }
  }

  Future<void> _onDelete(
    DeleteProProfileEvent event,
    Emitter<ProProfileState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    final result = await _service.deleteProProfile(event.userId);

    if (result.data == true) {
      emit(state.copyWith(
        clearProfile: true,
        isSaving: false,
        successMessage: result.message,
      ));
    } else {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: result.message,
      ));
    }
  }

  Future<void> _onSearch(
    SearchProsEvent event,
    Emitter<ProProfileState> emit,
  ) async {
    emit(state.copyWith(isSearching: true, clearError: true));

    var results = await _service.searchPros(
      types: event.types,
      city: event.city,
      remoteOnly: event.remoteOnly,
    );

    // Appliquer le filtre texte si présent
    if (event.textQuery != null && event.textQuery!.isNotEmpty) {
      results = _service.filterProsByText(results, event.textQuery!);
    }

    emit(state.copyWith(
      searchResults: results,
      isSearching: false,
    ));
  }

  void _onClear(
    ClearProProfileEvent event,
    Emitter<ProProfileState> emit,
  ) {
    emit(const ProProfileState());
  }
}
