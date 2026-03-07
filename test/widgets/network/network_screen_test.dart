import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/user_contact.dart';
import 'package:useme/screens/shared/network_screen.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  late MockNetworkBloc mockNetworkBloc;

  setUp(() {
    mockNetworkBloc = MockNetworkBloc();
  });

  Widget buildScreen({NetworkState? state}) {
    when(() => mockNetworkBloc.state)
        .thenReturn(state ?? const NetworkState());

    return buildTestApp(
      networkBloc: mockNetworkBloc,
      child: const NetworkScreen(),
    );
  }

  group('NetworkScreen', () {
    testWidgets('shows empty state when no contacts', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('No contacts yet'), findsOneWidget);
      expect(find.text('Add contact'), findsOneWidget);
    });

    testWidgets('shows add button in app bar', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(FontAwesomeIcons.userPlus), findsOneWidget);
    });

    testWidgets('shows My network title', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('My network'), findsOneWidget);
    });

    testWidgets('shows contact list when contacts exist', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: NetworkState(contacts: [
          UserContact(
            id: '1',
            ownerId: 'o',
            contactName: 'Alice',
            category: ContactCategory.artist,
            isOnPlatform: true,
            createdAt: DateTime(2024),
          ),
          UserContact(
            id: '2',
            ownerId: 'o',
            contactName: 'Bob',
            category: ContactCategory.engineer,
            isOnPlatform: false,
            createdAt: DateTime(2024),
          ),
        ]),
      ));
      await tester.pumpAndSettle();

      // Tab bar with "All" should show
      expect(find.text('All (2)'), findsOneWidget);
      // Contact names should be visible in the "All" tab
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows category tabs', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: NetworkState(contacts: [
          UserContact(
            id: '1',
            ownerId: 'o',
            contactName: 'A',
            category: ContactCategory.artist,
            createdAt: DateTime(2024),
          ),
        ]),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Artists (1)'), findsOneWidget);
      expect(find.text('Engineers (0)'), findsOneWidget);
    });

    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const NetworkState(isLoading: true),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows user group icon in empty state', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(FontAwesomeIcons.userGroup), findsOneWidget);
    });
  });
}
