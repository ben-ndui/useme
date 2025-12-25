import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:useme/core/services/studio_room_service.dart';
import 'package:useme/core/services/subscription_config_service.dart';

import 'studio_room_event.dart';
import 'studio_room_state.dart';

class StudioRoomBloc extends Bloc<StudioRoomEvent, StudioRoomState> {
  final StudioRoomService _roomService;
  final SubscriptionConfigService _subscriptionService;

  StudioRoomBloc({
    StudioRoomService? roomService,
    SubscriptionConfigService? subscriptionService,
  })  : _roomService = roomService ?? StudioRoomService(),
        _subscriptionService = subscriptionService ?? SubscriptionConfigService(),
        super(const StudioRoomState()) {
    on<LoadStudioRoomsEvent>(_onLoadRooms);
    on<CreateRoomEvent>(_onCreateRoom);
    on<UpdateRoomEvent>(_onUpdateRoom);
    on<DeleteRoomEvent>(_onDeleteRoom);
    on<ToggleRoomStatusEvent>(_onToggleStatus);
    on<ClearStudioRoomsEvent>(_onClearRooms);
  }

  Future<void> _onLoadRooms(
    LoadStudioRoomsEvent event,
    Emitter<StudioRoomState> emit,
  ) async {
    emit(state.copyWith(status: StudioRoomStatus.loading, studioId: event.studioId));

    try {
      final rooms = await _roomService.getRoomsByStudio(event.studioId);
      emit(state.copyWith(status: StudioRoomStatus.loaded, rooms: rooms));
    } catch (e) {
      emit(state.copyWith(
        status: StudioRoomStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateRoom(
    CreateRoomEvent event,
    Emitter<StudioRoomState> emit,
  ) async {
    try {
      // Check subscription limits if tier info is provided
      if (event.subscriptionTierId != null && event.currentRoomCount != null) {
        final canCreate = await _subscriptionService.canCreateRoom(
          tierId: event.subscriptionTierId!,
          currentRoomsCount: event.currentRoomCount!,
        );

        if (!canCreate) {
          final tier =
              await _subscriptionService.getTier(event.subscriptionTierId!);
          emit(state.copyWith(
            status: StudioRoomStatus.limitReached,
            currentCount: event.currentRoomCount,
            maxAllowed: tier?.maxRooms ?? 0,
            tierId: event.subscriptionTierId,
          ));
          return;
        }
      }

      final created = await _roomService.createRoom(event.room);
      if (created != null) {
        final updatedRooms = [...state.rooms, created];
        emit(state.copyWith(status: StudioRoomStatus.loaded, rooms: updatedRooms));
      }
    } catch (e) {
      emit(state.copyWith(
        status: StudioRoomStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateRoom(
    UpdateRoomEvent event,
    Emitter<StudioRoomState> emit,
  ) async {
    try {
      final success = await _roomService.updateRoom(event.room);
      if (success) {
        final updatedRooms = state.rooms.map((r) {
          return r.id == event.room.id ? event.room : r;
        }).toList();
        emit(state.copyWith(rooms: updatedRooms));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteRoom(
    DeleteRoomEvent event,
    Emitter<StudioRoomState> emit,
  ) async {
    try {
      final success = await _roomService.deleteRoom(event.roomId);
      if (success) {
        final updatedRooms = state.rooms.where((r) => r.id != event.roomId).toList();
        emit(state.copyWith(rooms: updatedRooms));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleStatus(
    ToggleRoomStatusEvent event,
    Emitter<StudioRoomState> emit,
  ) async {
    try {
      final success = await _roomService.toggleRoomStatus(event.roomId, event.isActive);
      if (success) {
        final updatedRooms = state.rooms.map((r) {
          return r.id == event.roomId ? r.copyWith(isActive: event.isActive) : r;
        }).toList();
        emit(state.copyWith(rooms: updatedRooms));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onClearRooms(
    ClearStudioRoomsEvent event,
    Emitter<StudioRoomState> emit,
  ) {
    emit(const StudioRoomState());
  }
}
