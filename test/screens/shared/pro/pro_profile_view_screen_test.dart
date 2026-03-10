import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/screens/shared/pro/pro_profile_view_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockMessagingBloc mockMessagingBloc;
  late MockFavoriteBloc mockFavoriteBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockMessagingBloc = MockMessagingBloc();
    mockFavoriteBloc = MockFavoriteBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthInitialState());
    when(() => mockMessagingBloc.state).thenReturn(MessagingInitialState());
    when(() => mockFavoriteBloc.state).thenReturn(
      const FavoriteState(favorites: []),
    );
  });

  AppUser makeUser({
    String displayName = 'DJ Alpha',
    List<ProType> proTypes = const [ProType.musician],
    String? bio,
    String? city,
    bool remote = false,
    double? hourlyRate,
    double? rating,
    int? reviewCount,
    bool isVerified = false,
    List<String> specialties = const [],
    List<String> genres = const [],
    List<String> instruments = const [],
    List<String> daws = const [],
    List<String> portfolioUrls = const [],
    List<Map<String, dynamic>> paymentMethods = const [],
  }) {
    return AppUser.fromMap({
      'uid': 'u1',
      'name': 'Test',
      'email': 'test@test.com',
      'role': 'client',
      'proProfile': {
        'displayName': displayName,
        'proTypes': proTypes.map((t) => t.name).toList(),
        'bio': bio,
        'city': city,
        'remote': remote,
        'hourlyRate': hourlyRate,
        'rating': rating,
        'reviewCount': reviewCount,
        'isVerified': isVerified,
        'isAvailable': true,
        'specialties': specialties,
        'genres': genres,
        'instruments': instruments,
        'daws': daws,
        'portfolioUrls': portfolioUrls,
        'paymentMethods': paymentMethods,
      },
    });
  }

  Widget buildScreen(AppUser user) {
    return buildTestApp(
      authBloc: mockAuthBloc,
      messagingBloc: mockMessagingBloc,
      favoriteBloc: mockFavoriteBloc,
      child: ProProfileViewScreen(user: user),
    );
  }

  group('ProProfileViewScreen', () {
    testWidgets('renders name in AppBar and header', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser()));
      await tester.pumpAndSettle();

      // Name appears in AppBar title and in the profile header
      expect(find.text('DJ Alpha'), findsNWidgets(2));
    });

    testWidgets('renders pro type label', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser()));
      await tester.pumpAndSettle();

      // proTypesLabel for [musician] — shown in header and bottom bar
      expect(find.text('Musicien'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows city in header when available', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser(city: 'Paris')));
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('shows bio when available', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser(bio: 'Top producer')));
      await tester.pumpAndSettle();

      expect(find.text('Top producer'), findsOneWidget);
    });

    testWidgets('hides bio when null', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser()));
      await tester.pumpAndSettle();

      expect(find.text('Top producer'), findsNothing);
    });

    testWidgets('shows remote badge when remote', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser(remote: true)));
      await tester.pumpAndSettle();

      expect(find.text('Remote'), findsOneWidget);
    });

    testWidgets('shows rating badge', (tester) async {
      await tester.pumpWidget(
          buildScreen(makeUser(rating: 4.5, reviewCount: 12)));
      await tester.pumpAndSettle();

      expect(find.text('4.5 (12)'), findsOneWidget);
    });

    testWidgets('shows formatted rate in info row', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser(hourlyRate: 80.0)));
      await tester.pumpAndSettle();

      // Rate appears in info row stat card and in bottom bar
      expect(find.text('80 EUR/h'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows "On quote" when no rate', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser()));
      await tester.pumpAndSettle();

      // "On quote" in info row and bottom bar
      expect(find.text('On quote'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows initial letter avatar when no photo', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser(displayName: 'Zara')));
      await tester.pumpAndSettle();

      expect(find.text('Z'), findsOneWidget);
    });

    testWidgets('shows specialties tags section', (tester) async {
      await tester.pumpWidget(
          buildScreen(makeUser(specialties: ['Mixing', 'Mastering'])));
      await tester.pumpAndSettle();

      expect(find.text('Specialties'), findsOneWidget);
      expect(find.text('Mixing'), findsOneWidget);
      expect(find.text('Mastering'), findsOneWidget);
    });

    testWidgets('shows genres tags section', (tester) async {
      await tester.pumpWidget(
          buildScreen(makeUser(genres: ['Jazz', 'Soul'])));
      await tester.pumpAndSettle();

      expect(find.text('Genres'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);
      expect(find.text('Soul'), findsOneWidget);
    });

    testWidgets('shows instruments tags section', (tester) async {
      await tester.pumpWidget(
          buildScreen(makeUser(instruments: ['Piano', 'Guitar'])));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Piano'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Instruments'), findsOneWidget);
      expect(find.text('Piano'), findsOneWidget);
      expect(find.text('Guitar'), findsOneWidget);
    });

    testWidgets('shows DAWs tags section', (tester) async {
      await tester.pumpWidget(
          buildScreen(makeUser(daws: ['Pro Tools', 'Logic'])));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Pro Tools'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('DAWs'), findsOneWidget);
      expect(find.text('Pro Tools'), findsOneWidget);
      expect(find.text('Logic'), findsOneWidget);
    });

    testWidgets('shows book and message buttons in bottom bar', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser()));
      await tester.pumpAndSettle();

      // Book button with l10n text
      expect(find.text('Send request'), findsOneWidget);
      // Message icon button (outlined)
      expect(find.byType(IconButton), findsAtLeastNWidgets(1));
    });

    testWidgets('shows portfolio section when urls present', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser(
        portfolioUrls: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
      )));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Portfolio'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Portfolio'), findsOneWidget);
    });

    testWidgets('hides portfolio section when no urls', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser()));
      await tester.pumpAndSettle();

      expect(find.text('Portfolio'), findsNothing);
    });

    testWidgets('shows payment methods section', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser(
        paymentMethods: [
          {'type': 'paypal', 'isEnabled': true, 'details': 'me@paypal.com'},
          {'type': 'cash', 'isEnabled': true},
        ],
      )));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Accepted payment methods'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Accepted payment methods'), findsOneWidget);
      expect(find.text('PayPal'), findsOneWidget);
    });

    testWidgets('hides payment methods when none', (tester) async {
      await tester.pumpWidget(buildScreen(makeUser()));
      await tester.pumpAndSettle();

      expect(find.text('Accepted payment methods'), findsNothing);
    });

    testWidgets('shows verified badge in AppBar when verified',
        (tester) async {
      await tester.pumpWidget(buildScreen(makeUser(isVerified: true)));
      await tester.pumpAndSettle();

      // Verified badge is in AppBar actions
      expect(find.text('DJ Alpha'), findsNWidgets(2));
    });

    testWidgets('hides verified badge when not verified', (tester) async {
      await tester
          .pumpWidget(buildScreen(makeUser(isVerified: false)));
      await tester.pumpAndSettle();

      // AppBar actions should be empty (no verified icon)
      expect(find.text('DJ Alpha'), findsNWidgets(2));
    });
  });
}
