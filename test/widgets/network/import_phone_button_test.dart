import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/widgets/network/import_phone_button.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ImportPhoneButton', () {
    testWidgets('displays import contacts text', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: ImportPhoneButton(onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Import from phone'), findsOneWidget);
    });

    testWidgets('displays description text', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: ImportPhoneButton(onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Find your contacts already on UZME'), findsOneWidget);
    });

    testWidgets('shows address book icon', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: ImportPhoneButton(onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) =>
            w is FaIcon && w.icon == FontAwesomeIcons.addressBook),
        findsOneWidget,
      );
    });

    testWidgets('shows chevron right icon', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: ImportPhoneButton(onTap: () {}),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) =>
            w is FaIcon && w.icon == FontAwesomeIcons.chevronRight),
        findsOneWidget,
      );
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestApp(
        child: ImportPhoneButton(onTap: () => tapped = true),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ImportPhoneButton));
      expect(tapped, isTrue);
    });
  });
}
