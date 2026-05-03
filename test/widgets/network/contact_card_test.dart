import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/core/models/user_contact.dart';
import 'package:uzme/widgets/network/contact_card.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ContactCard', () {
    testWidgets('displays contact name', (tester) async {
      final contact = UserContact(
        id: '1',
        ownerId: 'o',
        contactName: 'John Doe',
        category: ContactCategory.artist,
        createdAt: DateTime(2024),
      );

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ContactCard(contact: contact, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays category label', (tester) async {
      final contact = UserContact(
        id: '1',
        ownerId: 'o',
        contactName: 'Jane',
        category: ContactCategory.engineer,
        createdAt: DateTime(2024),
      );

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ContactCard(contact: contact, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ingénieur'), findsOneWidget);
    });

    testWidgets('shows check icon for on-platform contacts', (tester) async {
      final contact = UserContact(
        id: '1',
        ownerId: 'o',
        contactName: 'On Platform',
        category: ContactCategory.artist,
        isOnPlatform: true,
        createdAt: DateTime(2024),
      );

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ContactCard(contact: contact, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(
          find.byIcon(FontAwesomeIcons.solidCircleCheck), findsOneWidget);
    });

    testWidgets('hides check icon for off-platform contacts', (tester) async {
      final contact = UserContact(
        id: '1',
        ownerId: 'o',
        contactName: 'Off Platform',
        category: ContactCategory.artist,
        isOnPlatform: false,
        createdAt: DateTime(2024),
      );

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ContactCard(contact: contact, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(FontAwesomeIcons.solidCircleCheck), findsNothing);
    });

    testWidgets('shows first tag as chip', (tester) async {
      final contact = UserContact(
        id: '1',
        ownerId: 'o',
        contactName: 'Tagged',
        category: ContactCategory.artist,
        tags: ['vocalist', 'rapper'],
        createdAt: DateTime(2024),
      );

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ContactCard(contact: contact, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('vocalist'), findsOneWidget);
    });

    testWidgets('shows initial letter avatar when no photo', (tester) async {
      final contact = UserContact(
        id: '1',
        ownerId: 'o',
        contactName: 'Alice',
        category: ContactCategory.artist,
        createdAt: DateTime(2024),
      );

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ContactCard(contact: contact, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final contact = UserContact(
        id: '1',
        ownerId: 'o',
        contactName: 'Tappable',
        category: ContactCategory.artist,
        createdAt: DateTime(2024),
      );

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ContactCard(contact: contact, onTap: () => tapped = true),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tappable'));
      expect(tapped, true);
    });
  });
}
