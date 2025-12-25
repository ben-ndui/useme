import 'package:equatable/equatable.dart';
import 'package:useme/core/models/studio_room.dart';

abstract class StudioRoomEvent extends Equatable {
  const StudioRoomEvent();

  @override
  List<Object?> get props => [];
}

/// Load rooms for a studio
class LoadStudioRoomsEvent extends StudioRoomEvent {
  final String studioId;

  const LoadStudioRoomsEvent({required this.studioId});

  @override
  List<Object?> get props => [studioId];
}

/// Create a new room (with subscription limit check)
class CreateRoomEvent extends StudioRoomEvent {
  final StudioRoom room;
  final String? subscriptionTierId;
  final int? currentRoomCount;

  const CreateRoomEvent({
    required this.room,
    this.subscriptionTierId,
    this.currentRoomCount,
  });

  @override
  List<Object?> get props => [room, subscriptionTierId, currentRoomCount];
}

/// Update an existing room
class UpdateRoomEvent extends StudioRoomEvent {
  final StudioRoom room;

  const UpdateRoomEvent({required this.room});

  @override
  List<Object?> get props => [room];
}

/// Delete a room
class DeleteRoomEvent extends StudioRoomEvent {
  final String roomId;

  const DeleteRoomEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

/// Toggle room active status
class ToggleRoomStatusEvent extends StudioRoomEvent {
  final String roomId;
  final bool isActive;

  const ToggleRoomStatusEvent({required this.roomId, required this.isActive});

  @override
  List<Object?> get props => [roomId, isActive];
}

/// Clear rooms state
class ClearStudioRoomsEvent extends StudioRoomEvent {
  const ClearStudioRoomsEvent();
}
