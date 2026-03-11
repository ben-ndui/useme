import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/screens/shared/pro/pro_booking_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthInitialState());
  });

  AppUser makeProUser({
    String displayName = 'DJ Alpha',
    List<ProType> proTypes = const [ProType.soundEngineer],
    double? hourlyRate,
    bool remote = false,
  }) {
    return AppUser.fromMap({
      'uid': 'pro1',
      'name': 'Pro',
      'email': 'pro@test.com',
      'role': 'client',
      'proProfile': {
        'displayName': displayName,
        'proTypes': proTypes.map((t) => t.name).toList(),
        'isAvailable': true,
        'remote': remote,
        'hourlyRate': hourlyRate,
      },
    });
  }

  Widget buildScreen(AppUser proUser) {
    return buildTestApp(
      authBloc: mockAuthBloc,
      child: ProBookingScreen(proUser: proUser),
    );
  }

  group('ProBookingScreen', () {
    testWidgets('renders pro name in AppBar title', (tester) async {
      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      expect(find.textContaining('DJ Alpha'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders pro header with name and type', (tester) async {
      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      expect(find.text('DJ Alpha'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows rate badge when pro has rate', (tester) async {
      await tester
          .pumpWidget(buildScreen(makeProUser(hourlyRate: 50.0)));
      await tester.pumpAndSettle();

      expect(find.text('50 EUR/h'), findsOneWidget);
    });

    testWidgets('hides rate badge when no rate', (tester) async {
      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      expect(find.text('50 EUR/h'), findsNothing);
    });

    testWidgets('shows date picker field', (tester) async {
      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      expect(find.text('Please select a date'), findsOneWidget);
    });

    testWidgets('shows time picker field', (tester) async {
      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      expect(find.text('Please select a time slot'), findsOneWidget);
    });

    testWidgets('shows duration chips', (tester) async {
      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      expect(find.text('1h'), findsOneWidget);
      expect(find.text('2h'), findsOneWidget);
      expect(find.text('4h'), findsOneWidget);
      expect(find.text('8h'), findsOneWidget);
    });

    testWidgets('2h duration is selected by default', (tester) async {
      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      final chip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, '2h'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('shows remote switch when pro accepts remote',
        (tester) async {
      await tester
          .pumpWidget(buildScreen(makeProUser(remote: true)));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(SwitchListTile),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('hides remote switch when pro does not accept remote',
        (tester) async {
      await tester
          .pumpWidget(buildScreen(makeProUser(remote: false)));
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsNothing);
    });

    testWidgets('shows notes text field', (tester) async {
      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(TextFormField),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('submit button is disabled initially', (tester) async {
      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      // Scroll to the submit button
      await tester.scrollUntilVisible(
        find.text('Send request'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Send request'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('can change duration selection', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, '4h'));
      await tester.pumpAndSettle();

      final chip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, '4h'),
      );
      expect(chip.selected, isTrue);

      final oldChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, '2h'),
      );
      expect(oldChip.selected, isFalse);
    });

    testWidgets('shows initial letter avatar when no photo', (tester) async {
      await tester.pumpWidget(buildScreen(makeProUser()));
      await tester.pumpAndSettle();

      expect(find.text('D'), findsOneWidget);
    });
  });
}
