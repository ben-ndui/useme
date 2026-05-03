import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/core/models/user_contact.dart';
import 'package:uzme/widgets/network/contact_detail_header.dart';

import '../../helpers/widget_test_helpers.dart';

UserContact _makeContact({
  String name = 'Jane Doe',
  bool isOnPlatform = false,
  String category = 'artist',
  String? photoUrl,
}) {
  return UserContact.fromMap({
    'ownerId': 'owner1',
    'contactName': name,
    'category': category,
    'isOnPlatform': isOnPlatform,
    'tags': <String>[],
    'createdAt': DateTime.now().toIso8601String(),
    if (photoUrl != null) 'contactPhotoUrl': photoUrl,
  }, 'c1');
}

void main() {
  group('ContactDetailHeader', () {
    testWidgets('displays contact name', (tester) async {
      final contact = _makeContact(name: 'Alice');
      await tester.pumpWidget(buildTestApp(
        child: ContactDetailHeader(contact: contact),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('displays category label', (tester) async {
      final contact = _makeContact(category: 'engineer');
      await tester.pumpWidget(buildTestApp(
        child: ContactDetailHeader(contact: contact),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ingénieur'), findsOneWidget);
    });

    testWidgets('shows platform badge when on platform', (tester) async {
      final contact = _makeContact(isOnPlatform: true);
      await tester.pumpWidget(buildTestApp(
        child: ContactDetailHeader(contact: contact),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) =>
            w is FaIcon && w.icon == FontAwesomeIcons.solidCircleCheck),
        findsOneWidget,
      );
    });

    testWidgets('hides platform badge when off platform', (tester) async {
      final contact = _makeContact(isOnPlatform: false);
      await tester.pumpWidget(buildTestApp(
        child: ContactDetailHeader(contact: contact),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) =>
            w is FaIcon && w.icon == FontAwesomeIcons.solidCircleCheck),
        findsNothing,
      );
    });

    testWidgets('shows initial letter when no photo', (tester) async {
      final contact = _makeContact(name: 'Bob');
      await tester.pumpWidget(buildTestApp(
        child: ContactDetailHeader(contact: contact),
      ));
      await tester.pumpAndSettle();

      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('shows ? for empty name', (tester) async {
      final contact = _makeContact(name: '');
      await tester.pumpWidget(buildTestApp(
        child: ContactDetailHeader(contact: contact),
      ));
      await tester.pumpAndSettle();

      expect(find.text('?'), findsOneWidget);
    });
  });
}
