import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:useme/core/blocs/session/session_state.dart';
import 'package:useme/core/models/session.dart';
import 'package:useme/screens/shared/pro/pro_bookings_received_screen.dart';
import 'package:useme/widgets/common/app_loader.dart';

import '../../../helpers/test_factories.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  late MockSessionBloc mockSessionBloc;

  setUp(() {
    mockSessionBloc = MockSessionBloc();
  });

  Session makeProSession({
    String id = 'ps-1',
    SessionStatus status = SessionStatus.pending,
    String artistName = 'John Doe',
    String? notes,
  }) {
    final start = DateTime(2026, 4, 10, 14, 0);
    return SessionFactory.create(
      id: id,
      studioId: '',
      status: status,
      artistNames: [artistName],
      scheduledStart: start,
      scheduledEnd: start.add(const Duration(hours: 2)),
      durationMinutes: 120,
      notes: notes,
    ).copyWith(proId: 'pro-1', proName: 'DJ Alpha');
  }

  Widget buildScreen() {
    return buildTestApp(
      sessionBloc: mockSessionBloc,
      child: const ProBookingsReceivedScreen(),
    );
  }

  group('ProBookingsReceivedScreen', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      when(() => mockSessionBloc.state)
          .thenReturn(const SessionLoadingState());
      await tester.pumpWidget(buildScreen());

      expect(find.byType(AppLoader), findsOneWidget);
    });

    testWidgets('shows empty state when no pro sessions', (tester) async {
      when(() => mockSessionBloc.state)
          .thenReturn(const SessionsLoadedState(sessions: []));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('No requests yet'), findsOneWidget);
      expect(find.text('Your booking requests will appear here'),
          findsOneWidget);
    });

    testWidgets('shows empty state when sessions exist but none are pro',
        (tester) async {
      final studioSession = SessionFactory.future();
      when(() => mockSessionBloc.state)
          .thenReturn(SessionsLoadedState(sessions: [studioSession]));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('No requests yet'), findsOneWidget);
    });

    testWidgets('shows booking card for pro session', (tester) async {
      final session = makeProSession();
      when(() => mockSessionBloc.state)
          .thenReturn(SessionsLoadedState(sessions: [session]));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Request from John Doe'), findsOneWidget);
    });

    testWidgets('shows date and time info', (tester) async {
      final session = makeProSession();
      when(() => mockSessionBloc.state)
          .thenReturn(SessionsLoadedState(sessions: [session]));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Time range (2h)
      expect(find.textContaining('(2h)'), findsOneWidget);
    });

    testWidgets('shows notes when present', (tester) async {
      final session = makeProSession(notes: 'Mix my track please');
      when(() => mockSessionBloc.state)
          .thenReturn(SessionsLoadedState(sessions: [session]));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Mix my track please'), findsOneWidget);
    });

    testWidgets('shows accept and decline buttons for pending session',
        (tester) async {
      final session = makeProSession(status: SessionStatus.pending);
      when(() => mockSessionBloc.state)
          .thenReturn(SessionsLoadedState(sessions: [session]));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('hides action buttons for confirmed session',
        (tester) async {
      final session = makeProSession(status: SessionStatus.confirmed);
      when(() => mockSessionBloc.state)
          .thenReturn(SessionsLoadedState(sessions: [session]));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
    });

    testWidgets('shows pending status chip', (tester) async {
      final session = makeProSession(status: SessionStatus.pending);
      when(() => mockSessionBloc.state)
          .thenReturn(SessionsLoadedState(sessions: [session]));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows confirmed status chip', (tester) async {
      final session = makeProSession(status: SessionStatus.confirmed);
      when(() => mockSessionBloc.state)
          .thenReturn(SessionsLoadedState(sessions: [session]));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('shows cancelled status chip', (tester) async {
      final session = makeProSession(status: SessionStatus.cancelled);
      when(() => mockSessionBloc.state)
          .thenReturn(SessionsLoadedState(sessions: [session]));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('shows AppBar title', (tester) async {
      when(() => mockSessionBloc.state)
          .thenReturn(const SessionsLoadedState(sessions: []));
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Requests received'), findsOneWidget);
    });
  });
}
