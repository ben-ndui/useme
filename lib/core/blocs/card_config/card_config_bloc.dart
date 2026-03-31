import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:useme/core/models/card_config.dart';
import 'package:useme/core/services/card_config_service.dart';
import 'card_config_event.dart';
import 'card_config_state.dart';

class CardConfigBloc extends Bloc<CardConfigEvent, CardConfigState> {
  final CardConfigService _service;

  CardConfigBloc({CardConfigService? service})
      : _service = service ?? CardConfigService(),
        super(const CardConfigState()) {
    on<LoadCardConfigEvent>(_onLoad);
    on<SaveCardConfigEvent>(_onSave);
    on<ResetCardConfigEvent>(_onReset);
    on<ClearCardConfigEvent>(_onClear);
  }

  Future<void> _onLoad(
    LoadCardConfigEvent event,
    Emitter<CardConfigState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final config = await _service.load(event.userId);
    emit(state.copyWith(config: config, isLoading: false));
  }

  Future<void> _onSave(
    SaveCardConfigEvent event,
    Emitter<CardConfigState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final success = await _service.save(event.userId, event.config);

    if (success) {
      emit(state.copyWith(
        config: event.config,
        isSaving: false,
        successMessage: 'Card saved',
      ));
    } else {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save card config',
      ));
    }
  }

  Future<void> _onReset(
    ResetCardConfigEvent event,
    Emitter<CardConfigState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final success = await _service.save(event.userId, const CardConfig());

    if (success) {
      emit(state.copyWith(
        config: const CardConfig(),
        isSaving: false,
        successMessage: 'Card reset',
      ));
    } else {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to reset card config',
      ));
    }
  }

  void _onClear(
    ClearCardConfigEvent event,
    Emitter<CardConfigState> emit,
  ) {
    emit(const CardConfigState());
  }
}
