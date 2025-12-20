import 'package:equatable/equatable.dart';
import 'package:useme/core/models/models_exports.dart';

/// Base booking event
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Load all bookings for a studio
class LoadBookingsEvent extends BookingEvent {
  final String studioId;

  const LoadBookingsEvent({required this.studioId});

  @override
  List<Object?> get props => [studioId];
}

/// Load bookings for an artist
class LoadArtistBookingsEvent extends BookingEvent {
  final String artistId;

  const LoadArtistBookingsEvent({required this.artistId});

  @override
  List<Object?> get props => [artistId];
}

/// Create new booking
class CreateBookingEvent extends BookingEvent {
  final Booking booking;

  const CreateBookingEvent({required this.booking});

  @override
  List<Object?> get props => [booking];
}

/// Update existing booking
class UpdateBookingEvent extends BookingEvent {
  final String bookingId;
  final Map<String, dynamic> updates;

  const UpdateBookingEvent({required this.bookingId, required this.updates});

  @override
  List<Object?> get props => [bookingId, updates];
}

/// Delete booking
class DeleteBookingEvent extends BookingEvent {
  final String bookingId;

  const DeleteBookingEvent({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

/// Confirm booking
class ConfirmBookingEvent extends BookingEvent {
  final String bookingId;

  const ConfirmBookingEvent({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

/// Complete booking
class CompleteBookingEvent extends BookingEvent {
  final String bookingId;

  const CompleteBookingEvent({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

/// Cancel booking
class CancelBookingEvent extends BookingEvent {
  final String bookingId;
  final String? reason;

  const CancelBookingEvent({required this.bookingId, this.reason});

  @override
  List<Object?> get props => [bookingId, reason];
}
