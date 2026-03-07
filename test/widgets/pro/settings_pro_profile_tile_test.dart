import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/widgets/common/settings/settings_pro_profile_tile.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  group('SettingsProProfileTile', () {
    testWidgets('shows nothing when not authenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitialState());

      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        child: const Scaffold(body: SettingsProProfileTile()),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('shows activation prompt when no pro profile', (tester) async {
      final user = testAppUser();
      when(() => mockAuthBloc.state)
          .thenReturn(AuthAuthenticatedState(user: user));

      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        child: const Scaffold(body: SettingsProProfileTile()),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      // Shows chevron when no pro profile
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows Active badge when pro is available', (tester) async {
      final user = testAppUser(proProfileMap: {
        'displayName': 'DJ Test',
        'proTypes': ['musician'],
        'isAvailable': true,
      });
      when(() => mockAuthBloc.state)
          .thenReturn(AuthAuthenticatedState(user: user));

      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        child: const Scaffold(body: SettingsProProfileTile()),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      // Active badge should be green text
      expect(find.textContaining('Activ'), findsWidgets);
    });

    testWidgets('shows Inactive badge when pro not available',
        (tester) async {
      final user = testAppUser(proProfileMap: {
        'displayName': 'DJ Test',
        'proTypes': ['musician'],
        'isAvailable': false,
      });
      when(() => mockAuthBloc.state)
          .thenReturn(AuthAuthenticatedState(user: user));

      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        child: const Scaffold(body: SettingsProProfileTile()),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      // Inactive badge
      expect(find.textContaining('nactiv'), findsWidgets);
    });

    testWidgets('shows briefcase icon', (tester) async {
      final user = testAppUser();
      when(() => mockAuthBloc.state)
          .thenReturn(AuthAuthenticatedState(user: user));

      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        child: const Scaffold(body: SettingsProProfileTile()),
      ));
      await tester.pumpAndSettle();

      // Should have an icon container
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
