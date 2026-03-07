import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/widgets/network/phone_contacts_banner.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('PhoneContactsBanner', () {
    testWidgets('displays count text', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const PhoneContactsBanner(count: 5),
      ));
      await tester.pumpAndSettle();

      expect(find.text('5 of your contacts are on UZME!'), findsOneWidget);
    });

    testWidgets('shows user group icon', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const PhoneContactsBanner(count: 3),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) =>
            w is FaIcon && w.icon == FontAwesomeIcons.userGroup),
        findsOneWidget,
      );
    });

    testWidgets('uses primaryContainer color', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const PhoneContactsBanner(count: 1),
      ));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });
  });
}
