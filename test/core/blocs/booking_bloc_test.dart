import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:uzme/core/blocs/booking/booking_bloc.dart';
import 'package:uzme/core/blocs/booking/booking_event.dart';
import 'package:uzme/core/blocs/booking/booking_state.dart';
import 'package:uzme/core/models/models_exports.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockBookingService mockBookingService;

  final testBooking = BookingFactory.create(
    id: 'booking-1',
    status: BookingStatus.draft,
    totalAmount: 200.0,
  );
  final testBookings = [testBooking];

  setUpAll(() {
    registerFallbackValue(FakeBooking());
  });

  setUp(() {
    mockBookingService = MockBookingService();
  });

  BookingBloc buildBloc() =>
      BookingBloc(bookingService: mockBookingService);

  group('LoadBookingsEvent', () {
    blocTest<BookingBloc, BookingState>(
      'emits [loading, loaded] on success',
      build: () {
        when(() => mockBookingService.getBookingsByStudioId('studio-1'))
            .thenAnswer((_) async => testBookings);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadBookingsEvent(studioId: 'studio-1')),
      expect: () => [
        isA<BookingLoadingState>(),
        isA<BookingsLoadedState>()
            .having((s) => s.bookings.length, 'count', 1),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits [loading, error] on failure',
      build: () {
        when(() => mockBookingService.getBookingsByStudioId('studio-1'))
            .thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadBookingsEvent(studioId: 'studio-1')),
      expect: () => [
        isA<BookingLoadingState>(),
        isA<BookingErrorState>(),
      ],
    );
  });

  group('LoadArtistBookingsEvent', () {
    blocTest<BookingBloc, BookingState>(
      'emits [loading, loaded] from artist stream',
      build: () {
        when(() => mockBookingService.streamBookingsByArtistId('artist-1'))
            .thenAnswer((_) => Stream.value(testBookings));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadArtistBookingsEvent(artistId: 'artist-1')),
      expect: () => [
        isA<BookingLoadingState>(),
        isA<BookingsLoadedState>(),
      ],
    );
  });

  group('CreateBookingEvent', () {
    blocTest<BookingBloc, BookingState>(
      'emits [loading, created] on success',
      build: () {
        when(() => mockBookingService.createBooking(any()))
            .thenAnswer((_) async => SmoothResponse(
                  code: 200,
                  message: 'OK',
                  data: testBooking,
                ));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(CreateBookingEvent(booking: testBooking)),
      expect: () => [
        isA<BookingLoadingState>(),
        isA<BookingCreatedState>()
            .having((s) => s.createdBooking.id, 'id', 'booking-1'),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits [loading, error] on failure (code 500)',
      build: () {
        when(() => mockBookingService.createBooking(any()))
            .thenAnswer((_) async => const SmoothResponse(
                  code: 500,
                  message: 'Server error',
                ));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(CreateBookingEvent(booking: testBooking)),
      expect: () => [
        isA<BookingLoadingState>(),
        isA<BookingErrorState>()
            .having((s) => s.errorMessage, 'msg', 'Server error'),
      ],
    );
  });

  group('DeleteBookingEvent', () {
    blocTest<BookingBloc, BookingState>(
      'emits [loading, deleted] and removes from list',
      build: () {
        when(() => mockBookingService.deleteBooking('booking-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK'));
        return buildBloc();
      },
      seed: () => BookingsLoadedState(bookings: testBookings),
      act: (bloc) =>
          bloc.add(const DeleteBookingEvent(bookingId: 'booking-1')),
      expect: () => [
        isA<BookingLoadingState>(),
        isA<BookingDeletedState>()
            .having((s) => s.bookings, 'empty', isEmpty),
      ],
    );
  });

  group('ConfirmBookingEvent', () {
    blocTest<BookingBloc, BookingState>(
      'emits confirmed state with updated status',
      build: () {
        when(() => mockBookingService.confirmBooking('booking-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => BookingsLoadedState(bookings: testBookings),
      act: (bloc) =>
          bloc.add(const ConfirmBookingEvent(bookingId: 'booking-1')),
      expect: () => [
        isA<BookingConfirmedState>().having(
          (s) => s.bookings.first.status,
          'status',
          BookingStatus.confirmed,
        ),
      ],
    );
  });

  group('CompleteBookingEvent', () {
    blocTest<BookingBloc, BookingState>(
      'emits completed state with updated status',
      build: () {
        when(() => mockBookingService.completeBooking('booking-1'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => BookingsLoadedState(bookings: testBookings),
      act: (bloc) =>
          bloc.add(const CompleteBookingEvent(bookingId: 'booking-1')),
      expect: () => [
        isA<BookingCompletedState>().having(
          (s) => s.bookings.first.status,
          'status',
          BookingStatus.completed,
        ),
      ],
    );
  });

  group('CancelBookingEvent', () {
    blocTest<BookingBloc, BookingState>(
      'emits cancelled state with updated status',
      build: () {
        when(() => mockBookingService.cancelBooking('booking-1', 'No show'))
            .thenAnswer((_) async =>
                const SmoothResponse(code: 200, message: 'OK', data: true));
        return buildBloc();
      },
      seed: () => BookingsLoadedState(bookings: testBookings),
      act: (bloc) => bloc.add(const CancelBookingEvent(
        bookingId: 'booking-1',
        reason: 'No show',
      )),
      expect: () => [
        isA<BookingCancelledState>().having(
          (s) => s.bookings.first.status,
          'status',
          BookingStatus.cancelled,
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits error when cancel fails',
      build: () {
        when(() => mockBookingService.cancelBooking('booking-1', null))
            .thenAnswer((_) async => throw Exception('fail'));
        return buildBloc();
      },
      seed: () => BookingsLoadedState(bookings: testBookings),
      act: (bloc) =>
          bloc.add(const CancelBookingEvent(bookingId: 'booking-1')),
      expect: () => [
        isA<BookingErrorState>(),
      ],
    );
  });
}
