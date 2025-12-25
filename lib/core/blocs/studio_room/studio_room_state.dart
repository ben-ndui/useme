import 'package:equatable/equatable.dart';
import 'package:useme/core/models/studio_room.dart';

enum StudioRoomStatus { initial, loading, loaded, error, limitReached }

class StudioRoomState extends Equatable {
  final StudioRoomStatus status;
  final List<StudioRoom> rooms;
  final String? errorMessage;
  final String? studioId;
  // Limit info (used when status == limitReached)
  final int? currentCount;
  final int? maxAllowed;
  final String? tierId;

  const StudioRoomState({
    this.status = StudioRoomStatus.initial,
    this.rooms = const [],
    this.errorMessage,
    this.studioId,
    this.currentCount,
    this.maxAllowed,
    this.tierId,
  });

  /// Get only active rooms
  List<StudioRoom> get activeRooms => rooms.where((r) => r.isActive).toList();

  /// Get rooms that require an engineer
  List<StudioRoom> get roomsWithEngineer =>
      rooms.where((r) => r.requiresEngineer && r.isActive).toList();

  /// Get self-service rooms
  List<StudioRoom> get selfServiceRooms =>
      rooms.where((r) => !r.requiresEngineer && r.isActive).toList();

  StudioRoomState copyWith({
    StudioRoomStatus? status,
    List<StudioRoom>? rooms,
    String? errorMessage,
    String? studioId,
    int? currentCount,
    int? maxAllowed,
    String? tierId,
  }) {
    return StudioRoomState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage ?? this.errorMessage,
      studioId: studioId ?? this.studioId,
      currentCount: currentCount ?? this.currentCount,
      maxAllowed: maxAllowed ?? this.maxAllowed,
      tierId: tierId ?? this.tierId,
    );
  }

  @override
  List<Object?> get props =>
      [status, rooms, errorMessage, studioId, currentCount, maxAllowed, tierId];
}
