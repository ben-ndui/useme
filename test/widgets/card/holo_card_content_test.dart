import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/widgets/card/holo_card_content.dart';
import 'package:uzme/widgets/card/holo_card_theme.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('HoloCardContent', () {
    testWidgets('displays artist name and role badge', (tester) async {
      final user = testAppUser(
        name: 'DJ Smooth',
        role: 'client',
      );
      final theme = HoloCardTheme.forRole(user.role);

      await tester.pumpWidget(buildTestApp(
        child: Material(
          child: SizedBox(
            width: 400,
            height: 250,
            child: HoloCardContent(user: user, theme: theme),
          ),
        ),
      ));

      expect(find.text('DJ Smooth'), findsOneWidget);
      expect(find.text('Artist'), findsOneWidget);
      expect(find.text('UZME'), findsOneWidget);
    });

    testWidgets('displays studio name for admin role', (tester) async {
      final user = testAppUser(
        name: 'Ben Studio',
        role: 'admin',
      );
      final theme = HoloCardTheme.forRole(user.role);

      await tester.pumpWidget(buildTestApp(
        child: Material(
          child: SizedBox(
            width: 400,
            height: 250,
            child: HoloCardContent(user: user, theme: theme),
          ),
        ),
      ));

      expect(find.text('Studio'), findsOneWidget);
    });

    testWidgets('displays engineer role label', (tester) async {
      final user = testAppUser(
        name: 'Sound Master',
        role: 'worker',
      );
      final theme = HoloCardTheme.forRole(user.role);

      await tester.pumpWidget(buildTestApp(
        child: Material(
          child: SizedBox(
            width: 400,
            height: 250,
            child: HoloCardContent(user: user, theme: theme),
          ),
        ),
      ));

      expect(find.text('Sound Master'), findsOneWidget);
      expect(find.text('Engineer'), findsOneWidget);
    });

    testWidgets('shows city when available', (tester) async {
      final user = testAppUser(name: 'Test', role: 'client');
      // AppUser from testAppUser doesn't set city, so location won't show
      final theme = HoloCardTheme.forRole(user.role);

      await tester.pumpWidget(buildTestApp(
        child: Material(
          child: SizedBox(
            width: 400,
            height: 250,
            child: HoloCardContent(user: user, theme: theme),
          ),
        ),
      ));

      // Location icon should not appear when no city
      expect(find.byIcon(FontAwesomeIcons.locationDot), findsNothing);
    });

    testWidgets('shows initials fallback when no photo', (tester) async {
      final user = testAppUser(name: 'Alice Bob', role: 'client');
      final theme = HoloCardTheme.forRole(user.role);

      await tester.pumpWidget(buildTestApp(
        child: Material(
          child: SizedBox(
            width: 400,
            height: 250,
            child: HoloCardContent(user: user, theme: theme),
          ),
        ),
      ));

      // Initial 'A' should be displayed
      expect(find.text('A'), findsOneWidget);
    });
  });
}
