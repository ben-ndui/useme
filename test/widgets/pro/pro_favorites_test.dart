import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/favorite.dart';
import 'package:uzme/widgets/favorite/favorite_button.dart';
import 'package:uzme/widgets/pro/pro_card.dart';

import '../../helpers/widget_test_helpers.dart';

class _FakeFavoriteEvent extends Fake implements FavoriteEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockFavoriteBloc mockFavoriteBloc;

  setUpAll(() {
    registerFallbackValue(_FakeFavoriteEvent());
  });

  final proProfileMap = {
    'displayName': 'Pro User',
    'proTypes': ['mixingEngineer'],
    'isAvailable': true,
    'isVerified': false,
    'remote': true,
    'rate': 50.0,
    'rateUnit': 'hour',
    'specialties': ['Mixing'],
    'genres': ['Hip-Hop'],
    'instruments': [],
    'daws': ['Pro Tools'],
  };

  final proUser = testAppUser(
    uid: 'pro-1',
    name: 'Pro User',
    proProfileMap: proProfileMap,
  );

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockFavoriteBloc = MockFavoriteBloc();

    when(() => mockAuthBloc.state).thenReturn(
      AuthAuthenticatedState(
        user: testAppUser(uid: 'current-user'),
      ),
    );

    when(() => mockFavoriteBloc.state).thenReturn(
      const FavoriteState(favorites: []),
    );
  });

  group('ProCard favorite button', () {
    testWidgets('shows favorite heart icon', (tester) async {
      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        favoriteBloc: mockFavoriteBloc,
        child: Scaffold(
          body: ProCard(user: proUser, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(FontAwesomeIcons.heart), findsWidgets);
    });

    testWidgets('shows filled heart when pro is favorited', (tester) async {
      when(() => mockFavoriteBloc.state).thenReturn(
        FavoriteState(favorites: [
          Favorite(
            id: 'fav-1',
            userId: 'current-user',
            targetId: 'pro-1',
            type: FavoriteType.pro,
            createdAt: DateTime.now(),
            targetName: 'Pro User',
          ),
        ]),
      );

      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        favoriteBloc: mockFavoriteBloc,
        child: Scaffold(
          body: ProCard(user: proUser, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(FontAwesomeIcons.solidHeart), findsWidgets);
    });

    testWidgets('dispatches ToggleFavoriteEvent on tap', (tester) async {
      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        favoriteBloc: mockFavoriteBloc,
        child: Scaffold(
          body: ProCard(user: proUser, onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      // Find the FavoriteButtonCompact's GestureDetector
      final heartIcon = find.byIcon(FontAwesomeIcons.heart);
      expect(heartIcon, findsWidgets);

      // Tap the first heart (the compact one in the card)
      await tester.tap(heartIcon.first);
      await tester.pump();

      verify(() => mockFavoriteBloc.add(
            any(that: isA<ToggleFavoriteEvent>()),
          )).called(1);
    });
  });

  group('FavoriteButtonCompact with pro type', () {
    testWidgets('renders with FavoriteType.pro', (tester) async {
      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        favoriteBloc: mockFavoriteBloc,
        child: const Scaffold(
          body: FavoriteButtonCompact(
            targetId: 'pro-1',
            type: FavoriteType.pro,
            targetName: 'Test Pro',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(FontAwesomeIcons.heart), findsOneWidget);
    });

    testWidgets('hides when user not authenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitialState());

      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        favoriteBloc: mockFavoriteBloc,
        child: const Scaffold(
          body: FavoriteButtonCompact(
            targetId: 'pro-1',
            type: FavoriteType.pro,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Should not show any heart icon when not authenticated
      expect(find.byIcon(FontAwesomeIcons.heart), findsNothing);
      expect(find.byIcon(FontAwesomeIcons.solidHeart), findsNothing);
    });
  });

  group('FavoriteType.pro', () {
    test('can be parsed from string', () {
      expect(FavoriteType.fromString('pro'), FavoriteType.pro);
    });

    test('has correct name', () {
      expect(FavoriteType.pro.name, 'pro');
    });

    test('getFavoritesByType filters pro favorites', () {
      final state = FavoriteState(favorites: [
        Favorite(
          id: 'fav-1',
          userId: 'u1',
          targetId: 'studio-1',
          type: FavoriteType.studio,
          createdAt: DateTime.now(),
        ),
        Favorite(
          id: 'fav-2',
          userId: 'u1',
          targetId: 'pro-1',
          type: FavoriteType.pro,
          createdAt: DateTime.now(),
        ),
        Favorite(
          id: 'fav-3',
          userId: 'u1',
          targetId: 'pro-2',
          type: FavoriteType.pro,
          createdAt: DateTime.now(),
        ),
      ]);

      final proFavs = state.getFavoritesByType(FavoriteType.pro);
      expect(proFavs.length, 2);
      expect(proFavs.every((f) => f.type == FavoriteType.pro), isTrue);
    });
  });
}
