import 'package:equatable/equatable.dart';
import 'package:uzme/core/models/pro_profile.dart';

abstract class ProProfileEvent extends Equatable {
  const ProProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Active un profil pro pour l'utilisateur courant.
class ActivateProProfileEvent extends ProProfileEvent {
  final String userId;
  final ProProfile profile;

  const ActivateProProfileEvent({
    required this.userId,
    required this.profile,
  });

  @override
  List<Object?> get props => [userId, profile];
}

/// Met à jour le profil pro.
class UpdateProProfileEvent extends ProProfileEvent {
  final String userId;
  final ProProfile profile;

  const UpdateProProfileEvent({
    required this.userId,
    required this.profile,
  });

  @override
  List<Object?> get props => [userId, profile];
}

/// Change la disponibilité du pro.
class SetProAvailabilityEvent extends ProProfileEvent {
  final String userId;
  final bool isAvailable;

  const SetProAvailabilityEvent({
    required this.userId,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [userId, isAvailable];
}

/// Désactive le profil pro (garde les données).
class DeactivateProProfileEvent extends ProProfileEvent {
  final String userId;

  const DeactivateProProfileEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Supprime complètement le profil pro.
class DeleteProProfileEvent extends ProProfileEvent {
  final String userId;

  const DeleteProProfileEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Charge le profil pro d'un utilisateur.
class LoadProProfileEvent extends ProProfileEvent {
  final String userId;

  const LoadProProfileEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Recherche des pros disponibles.
class SearchProsEvent extends ProProfileEvent {
  final List<ProType>? types;
  final String? city;
  final bool remoteOnly;
  final String? textQuery;

  const SearchProsEvent({
    this.types,
    this.city,
    this.remoteOnly = false,
    this.textQuery,
  });

  @override
  List<Object?> get props => [types, city, remoteOnly, textQuery];
}

/// Clear l'état (déconnexion).
class ClearProProfileEvent extends ProProfileEvent {
  const ClearProProfileEvent();
}
