import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/widgets/pro/pro_discovery_carousel.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockProProfileBloc mockProProfileBloc;
  late MockFavoriteBloc mockFavoriteBloc;

  final proUsers = List.generate(
    3,
    (i) => testAppUser(
      uid: 'pro-$i',
      name: 'Pro $i',
      proProfileMap: {
        'displayName': 'Pro $i',
        'proTypes': ['mixingEngineer'],
        'isAvailable': true,
        'isVerified': false,
        'remote': true,
        'city': 'Paris',
        'specialties': [],
        'genres': [],
        'instruments': [],
        'daws': [],
      },
    ),
  );

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockProProfileBloc = MockProProfileBloc();
    mockFavoriteBloc = MockFavoriteBloc();

    when(() => mockAuthBloc.state).thenReturn(
      AuthAuthenticatedState(user: testAppUser()),
    );
    when(() => mockFavoriteBloc.state).thenReturn(
      const FavoriteState(favorites: []),
    );
  });

  Widget buildCarousel({List<AppUser> results = const []}) {
    when(() => mockProProfileBloc.state).thenReturn(
      ProProfileState(searchResults: results),
    );

    return buildTestApp(
      authBloc: mockAuthBloc,
      proProfileBloc: mockProProfileBloc,
      favoriteBloc: mockFavoriteBloc,
      child: Scaffold(
        body: ProDiscoveryCarousel(onProTap: (_) {}),
      ),
    );
  }

  group('ProDiscoveryCarousel', () {
    testWidgets('hides when no pros available', (tester) async {
      await tester.pumpWidget(buildCarousel());
      await tester.pumpAndSettle();

      expect(find.byType(ProDiscoveryCarousel), findsOneWidget);
      // Should render SizedBox.shrink
      expect(find.text('Find a pro'), findsNothing);
    });

    testWidgets('shows header when pros available', (tester) async {
      await tester.pumpWidget(buildCarousel(results: proUsers));
      await tester.pumpAndSettle();

      expect(find.text('Find a pro'), findsOneWidget);
    });

    testWidgets('shows "See all" button', (tester) async {
      await tester.pumpWidget(buildCarousel(results: proUsers));
      await tester.pumpAndSettle();

      expect(find.text('See all'), findsOneWidget);
    });

    testWidgets('shows pro cards in carousel', (tester) async {
      await tester.pumpWidget(buildCarousel(results: proUsers));
      await tester.pumpAndSettle();

      expect(find.text('Pro 0'), findsOneWidget);
      expect(find.text('Pro 1'), findsOneWidget);
    });

    testWidgets('shows briefcase icon in header', (tester) async {
      await tester.pumpWidget(buildCarousel(results: proUsers));
      await tester.pumpAndSettle();

      expect(find.byIcon(FontAwesomeIcons.briefcase), findsOneWidget);
    });

    testWidgets('hides during search with no results', (tester) async {
      when(() => mockProProfileBloc.state).thenReturn(
        const ProProfileState(isSearching: true, searchResults: []),
      );

      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        proProfileBloc: mockProProfileBloc,
        favoriteBloc: mockFavoriteBloc,
        child: Scaffold(
          body: ProDiscoveryCarousel(onProTap: (_) {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Find a pro'), findsNothing);
    });
  });
}
