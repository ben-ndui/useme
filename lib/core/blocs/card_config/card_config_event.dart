import 'package:equatable/equatable.dart';
import 'package:uzme/core/models/card_config.dart';

abstract class CardConfigEvent extends Equatable {
  const CardConfigEvent();

  @override
  List<Object?> get props => [];
}

/// Load the card config for a user.
class LoadCardConfigEvent extends CardConfigEvent {
  final String userId;

  const LoadCardConfigEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Save updated card config.
class SaveCardConfigEvent extends CardConfigEvent {
  final String userId;
  final CardConfig config;

  const SaveCardConfigEvent({required this.userId, required this.config});

  @override
  List<Object?> get props => [userId, config];
}

/// Reset card config to defaults.
class ResetCardConfigEvent extends CardConfigEvent {
  final String userId;

  const ResetCardConfigEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Clear state (logout).
class ClearCardConfigEvent extends CardConfigEvent {
  const ClearCardConfigEvent();
}
