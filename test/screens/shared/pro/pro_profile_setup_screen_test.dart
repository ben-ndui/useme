import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/screens/shared/pro/pro_profile_setup_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

class FakeProProfileEvent extends Fake implements ProProfileEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockProProfileBloc mockProProfileBloc;

  setUpAll(() {
    registerFallbackValue(FakeProProfileEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockProProfileBloc = MockProProfileBloc();
    when(() => mockProProfileBloc.state).thenReturn(const ProProfileState());
  });

  Widget buildScreen() {
    return buildTestApp(
      authBloc: mockAuthBloc,
      proProfileBloc: mockProProfileBloc,
      child: const ProProfileSetupScreen(),
    );
  }

  void setAuthState({Map<String, dynamic>? proProfileMap}) {
    final user = testAppUser(proProfileMap: proProfileMap);
    when(() => mockAuthBloc.state)
        .thenReturn(AuthAuthenticatedState(user: user));
  }

  /// Sets a tall viewport so that responsive Center+ConstrainedBox
  /// wrapping doesn't push form fields off-screen in tests.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(2400, 9000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('ProProfileSetupScreen - creation mode', () {
    setUp(() => setAuthState());

    testWidgets('shows setup title and description', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Become a Pro'), findsAtLeastNWidgets(1));
      expect(
        find.textContaining('Offer your services'),
        findsOneWidget,
      );
    });

    testWidgets('shows ProTypeSelector chips', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsNWidgets(ProType.values.length));
    });

    testWidgets('shows form fields', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsAtLeastNWidgets(4));
    });

    testWidgets('shows activate button', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Activate my pro profile'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Activate my pro profile'), findsOneWidget);
    });

    testWidgets('submit with empty name shows validation error',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Select a type first so it's not blocked by type check
      await tester.tap(find.byType(FilterChip).first);
      await tester.pumpAndSettle();

      // Scroll to and tap submit
      await tester.scrollUntilVisible(
        find.text('Activate my pro profile'),
        200,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 50,
      );
      await tester.tap(find.text('Activate my pro profile'));
      await tester.pumpAndSettle();

      // Scroll back up to see the validation error
      await tester.scrollUntilVisible(
        find.text('This field is required'),
        -200,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 50,
      );
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('submit with valid data dispatches ActivateProProfileEvent',
        (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Select a type
      await tester.tap(find.byType(FilterChip).first);
      await tester.pumpAndSettle();

      // Fill display name
      await tester.enterText(
        find.byType(TextFormField).first,
        'DJ TestPro',
      );

      // Scroll to and tap submit
      await tester.scrollUntilVisible(
        find.text('Activate my pro profile'),
        200,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 50,
      );
      await tester.tap(find.text('Activate my pro profile'));
      await tester.pumpAndSettle();

      verify(() => mockProProfileBloc.add(any(
        that: isA<ActivateProProfileEvent>(),
      ))).called(1);
    });

    testWidgets('shows loading indicator when saving', (tester) async {
      when(() => mockProProfileBloc.state)
          .thenReturn(const ProProfileState(isSaving: true));

      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      await tester.pump();

      // The CircularProgressIndicator is in the submit button (offstage)
      expect(
        find.byType(CircularProgressIndicator, skipOffstage: false),
        findsOneWidget,
      );
    });
  });

  group('ProProfileSetupScreen - edit mode', () {
    setUp(() {
      setAuthState(proProfileMap: {
        'displayName': 'DJ Existing',
        'proTypes': ['musician', 'producer'],
        'bio': 'My bio text',
        'hourlyRate': 50.0,
        'city': 'Paris',
        'website': 'https://dj.com',
        'phone': '+33600000000',
        'remote': true,
        'isAvailable': true,
        'specialties': ['Mixing'],
        'genres': ['Jazz'],
        'instruments': ['Piano'],
        'daws': ['Logic'],
      });
    });

    testWidgets('shows edit title', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Edit my pro profile'), findsAtLeastNWidgets(1));
    });

    testWidgets('pre-fills display name', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('DJ Existing'), findsOneWidget);
    });

    testWidgets('pre-fills bio', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('My bio text'), findsOneWidget);
    });

    testWidgets('pre-fills rate', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('pre-fills city', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('shows save button instead of activate', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Save'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('submit dispatches UpdateProProfileEvent', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Scroll to and tap save
      await tester.scrollUntilVisible(
        find.text('Save'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(() => mockProProfileBloc.add(any(
        that: isA<UpdateProProfileEvent>(),
      ))).called(1);
    });

    testWidgets('pre-selects existing pro types', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Musician and producer should be selected
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final selectedCount = chips.where((c) => c.selected).length;
      expect(selectedCount, 2);
    });
  });

  group('ProProfileSetupScreen - unauthenticated', () {
    testWidgets('renders without crash when not authenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitialState());

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Should show creation mode (no profile loaded)
      expect(find.text('Become a Pro'), findsAtLeastNWidgets(1));
    });
  });
}
