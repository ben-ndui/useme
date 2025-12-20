import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:useme/core/blocs/booking/booking_event.dart';
import 'package:useme/core/blocs/booking/booking_state.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/services_exports.dart';

/// Booking BLoC - Manages booking state
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingService _bookingService = BookingService();

  BookingBloc() : super(const BookingInitialState()) {
    on<LoadBookingsEvent>(_onLoadBookings);
    on<LoadArtistBookingsEvent>(_onLoadArtistBookings);
    on<CreateBookingEvent>(_onCreateBooking);
    on<UpdateBookingEvent>(_onUpdateBooking);
    on<DeleteBookingEvent>(_onDeleteBooking);
    on<ConfirmBookingEvent>(_onConfirmBooking);
    on<CompleteBookingEvent>(_onCompleteBooking);
    on<CancelBookingEvent>(_onCancelBooking);
  }

  Future<void> _onLoadBookings(
      LoadBookingsEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoadingState(bookings: state.bookings));
    try {
      final bookings =
          await _bookingService.getBookingsByStudioId(event.studioId);
      emit(BookingsLoadedState(bookings: bookings));
    } catch (e) {
      emit(BookingErrorState(
        errorMessage: 'Erreur lors du chargement: $e',
        bookings: state.bookings,
      ));
    }
  }

  Future<void> _onLoadArtistBookings(
      LoadArtistBookingsEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoadingState(bookings: state.bookings));
    try {
      final bookings = await _bookingService
          .streamBookingsByArtistId(event.artistId)
          .first;
      emit(BookingsLoadedState(bookings: bookings));
    } catch (e) {
      emit(BookingErrorState(
        errorMessage: 'Erreur: $e',
        bookings: state.bookings,
      ));
    }
  }

  Future<void> _onCreateBooking(
      CreateBookingEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoadingState(bookings: state.bookings));
    try {
      final response = await _bookingService.createBooking(event.booking);
      if (response.code == 200 && response.data != null) {
        final updatedBookings = [response.data!, ...state.bookings];
        emit(BookingCreatedState(
          createdBooking: response.data!,
          bookings: updatedBookings,
        ));
      } else {
        emit(BookingErrorState(
          errorMessage: response.message,
          bookings: state.bookings,
        ));
      }
    } catch (e) {
      emit(BookingErrorState(
        errorMessage: 'Erreur: $e',
        bookings: state.bookings,
      ));
    }
  }

  Future<void> _onUpdateBooking(
      UpdateBookingEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoadingState(bookings: state.bookings));
    try {
      await _bookingService.updateBooking(event.bookingId, event.updates);
      final updatedBooking =
          await _bookingService.getBookingById(event.bookingId);
      if (updatedBooking != null) {
        final updatedBookings = state.bookings.map((b) {
          return b.id == event.bookingId ? updatedBooking : b;
        }).toList();
        emit(BookingUpdatedState(
          updatedBooking: updatedBooking,
          bookings: updatedBookings,
        ));
      }
    } catch (e) {
      emit(BookingErrorState(
        errorMessage: 'Erreur: $e',
        bookings: state.bookings,
      ));
    }
  }

  Future<void> _onDeleteBooking(
      DeleteBookingEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoadingState(bookings: state.bookings));
    try {
      final response = await _bookingService.deleteBooking(event.bookingId);
      if (response.code == 200) {
        final updatedBookings =
            state.bookings.where((b) => b.id != event.bookingId).toList();
        emit(BookingDeletedState(
          deletedBookingId: event.bookingId,
          bookings: updatedBookings,
        ));
      } else {
        emit(BookingErrorState(
          errorMessage: response.message,
          bookings: state.bookings,
        ));
      }
    } catch (e) {
      emit(BookingErrorState(
        errorMessage: 'Erreur: $e',
        bookings: state.bookings,
      ));
    }
  }

  Future<void> _onConfirmBooking(
      ConfirmBookingEvent event, Emitter<BookingState> emit) async {
    try {
      await _bookingService.confirmBooking(event.bookingId);
      final updatedBookings = state.bookings.map((b) {
        return b.id == event.bookingId
            ? b.copyWith(status: BookingStatus.confirmed)
            : b;
      }).toList();
      emit(BookingConfirmedState(
        bookingId: event.bookingId,
        bookings: updatedBookings,
      ));
    } catch (e) {
      emit(BookingErrorState(
        errorMessage: 'Erreur: $e',
        bookings: state.bookings,
      ));
    }
  }

  Future<void> _onCompleteBooking(
      CompleteBookingEvent event, Emitter<BookingState> emit) async {
    try {
      await _bookingService.completeBooking(event.bookingId);
      final updatedBookings = state.bookings.map((b) {
        return b.id == event.bookingId
            ? b.copyWith(status: BookingStatus.completed)
            : b;
      }).toList();
      emit(BookingCompletedState(
        bookingId: event.bookingId,
        bookings: updatedBookings,
      ));
    } catch (e) {
      emit(BookingErrorState(
        errorMessage: 'Erreur: $e',
        bookings: state.bookings,
      ));
    }
  }

  Future<void> _onCancelBooking(
      CancelBookingEvent event, Emitter<BookingState> emit) async {
    try {
      await _bookingService.cancelBooking(event.bookingId, event.reason);
      final updatedBookings = state.bookings.map((b) {
        return b.id == event.bookingId
            ? b.copyWith(status: BookingStatus.cancelled)
            : b;
      }).toList();
      emit(BookingCancelledState(
        bookingId: event.bookingId,
        bookings: updatedBookings,
      ));
    } catch (e) {
      emit(BookingErrorState(
        errorMessage: 'Erreur: $e',
        bookings: state.bookings,
      ));
    }
  }
}
