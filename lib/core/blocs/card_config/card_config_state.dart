import 'package:equatable/equatable.dart';
import 'package:useme/core/models/card_config.dart';

class CardConfigState extends Equatable {
  final CardConfig config;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const CardConfigState({
    this.config = const CardConfig(),
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoaded => !isLoading;

  CardConfigState copyWith({
    CardConfig? config,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CardConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        config,
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
      ];
}
