import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/widgets/pro/pro_card.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  AppUser makeUser({
    String displayName = 'DJ Test',
    List<ProType> proTypes = const [ProType.musician],
    String? city,
    bool remote = false,
    double? rating,
    double? hourlyRate,
    bool isVerified = false,
  }) {
    return AppUser.fromMap({
      'uid': 'u1',
      'name': 'Test',
      'email': 'test@test.com',
      'role': 'client',
      'proProfile': {
        'displayName': displayName,
        'proTypes': proTypes.map((t) => t.name).toList(),
        'city': city,
        'remote': remote,
        'rating': rating,
        'hourlyRate': hourlyRate,
        'isVerified': isVerified,
        'isAvailable': true,
      },
    });
  }

  group('ProCard', () {
    testWidgets('renders pro name and type', (tester) async {
      final user = makeUser();

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProCard(user: user, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('DJ Test'), findsOneWidget);
      expect(find.text('Musicien'), findsOneWidget);
    });

    testWidgets('shows city chip when city is set', (tester) async {
      final user = makeUser(city: 'Paris');

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProCard(user: user, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('shows Remote chip when remote', (tester) async {
      final user = makeUser(remote: true);

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProCard(user: user, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Remote'), findsOneWidget);
    });

    testWidgets('shows rating when available', (tester) async {
      final user = makeUser(rating: 4.5);

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProCard(user: user, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('shows formatted rate', (tester) async {
      final user = makeUser(hourlyRate: 50.0);

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProCard(user: user, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('50 EUR/h'), findsOneWidget);
    });

    testWidgets('shows "Sur devis" when no rate', (tester) async {
      final user = makeUser();

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProCard(user: user, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sur devis'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final user = makeUser();
      bool tapped = false;

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProCard(user: user, onTap: () => tapped = true),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ProCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows initial when no photo', (tester) async {
      final user = makeUser(displayName: 'Mix Master');

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProCard(user: user, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('M'), findsOneWidget);
    });
  });
}
