import 'package:equatable/equatable.dart';
import 'package:useme/core/models/models_exports.dart';

/// Base booking state
class BookingState extends Equatable {
  final List<Booking> bookings;
  final Booking? selectedBooking;
  final bool isLoading;
  final String? errorMessage;

  const BookingState({
    this.bookings = const [],
    this.selectedBooking,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [bookings, selectedBooking, isLoading, errorMessage];

  BookingState copyWith({
    List<Booking>? bookings,
    Booking? selectedBooking,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      selectedBooking: selectedBooking ?? this.selectedBooking,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Initial state
class BookingInitialState extends BookingState {
  const BookingInitialState() : super();
}

/// Loading state
class BookingLoadingState extends BookingState {
  const BookingLoadingState({super.bookings, super.selectedBooking})
      : super(isLoading: true);
}

/// Bookings loaded successfully
class BookingsLoadedState extends BookingState {
  const BookingsLoadedState({required super.bookings}) : super(isLoading: false);
}

/// Booking created successfully
class BookingCreatedState extends BookingState {
  final Booking createdBooking;

  const BookingCreatedState({
    required this.createdBooking,
    required super.bookings,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [createdBooking, bookings, isLoading];
}

/// Booking updated successfully
class BookingUpdatedState extends BookingState {
  final Booking updatedBooking;

  const BookingUpdatedState({
    required this.updatedBooking,
    required super.bookings,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [updatedBooking, bookings, isLoading];
}

/// Booking deleted successfully
class BookingDeletedState extends BookingState {
  final String deletedBookingId;

  const BookingDeletedState({
    required this.deletedBookingId,
    required super.bookings,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [deletedBookingId, bookings, isLoading];
}

/// Booking confirmed
class BookingConfirmedState extends BookingState {
  final String bookingId;

  const BookingConfirmedState({
    required this.bookingId,
    required super.bookings,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [bookingId, bookings, isLoading];
}

/// Booking completed
class BookingCompletedState extends BookingState {
  final String bookingId;

  const BookingCompletedState({
    required this.bookingId,
    required super.bookings,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [bookingId, bookings, isLoading];
}

/// Booking cancelled
class BookingCancelledState extends BookingState {
  final String bookingId;

  const BookingCancelledState({
    required this.bookingId,
    required super.bookings,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [bookingId, bookings, isLoading];
}

/// Error state
class BookingErrorState extends BookingState {
  const BookingErrorState({
    required super.errorMessage,
    super.bookings,
    super.selectedBooking,
  }) : super(isLoading: false);
}
