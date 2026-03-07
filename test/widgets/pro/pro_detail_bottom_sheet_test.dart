import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/widgets/pro/pro_detail_bottom_sheet.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockMessagingBloc mockMessagingBloc;
  late MockFavoriteBloc mockFavoriteBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockMessagingBloc = MockMessagingBloc();
    mockFavoriteBloc = MockFavoriteBloc();
    when(() => mockAuthBloc.state).thenReturn(
      AuthAuthenticatedState(user: testAppUser()),
    );
    when(() => mockMessagingBloc.state).thenReturn(MessagingInitialState());
    when(() => mockFavoriteBloc.state).thenReturn(
      const FavoriteState(favorites: []),
    );
  });

  AppUser makeUser({
    String displayName = 'DJ Test',
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
      },
    });
  }

  Widget buildSheet(AppUser user) {
    return buildTestApp(
      authBloc: mockAuthBloc,
      messagingBloc: mockMessagingBloc,
      favoriteBloc: mockFavoriteBloc,
      child: Scaffold(body: ProDetailBottomSheet(user: user)),
    );
  }

  group('ProDetailBottomSheet', () {
    testWidgets('renders name and type', (tester) async {
      await tester.pumpWidget(buildSheet(makeUser()));
      await tester.pumpAndSettle();

      expect(find.text('DJ Test'), findsOneWidget);
      expect(find.text('Musicien'), findsOneWidget);
    });

    testWidgets('shows bio when available', (tester) async {
      await tester.pumpWidget(buildSheet(makeUser(bio: 'Expert in mixing')));
      await tester.pumpAndSettle();

      expect(find.text('Expert in mixing'), findsOneWidget);
    });

    testWidgets('shows city badge', (tester) async {
      await tester.pumpWidget(buildSheet(makeUser(city: 'Lyon')));
      await tester.pumpAndSettle();

      expect(find.text('Lyon'), findsOneWidget);
    });

    testWidgets('shows remote badge', (tester) async {
      await tester.pumpWidget(buildSheet(makeUser(remote: true)));
      await tester.pumpAndSettle();

      expect(find.text('Remote'), findsOneWidget);
    });

    testWidgets('shows rate stat', (tester) async {
      await tester.pumpWidget(buildSheet(makeUser(hourlyRate: 75.0)));
      await tester.pumpAndSettle();

      expect(find.text('75 EUR/h'), findsOneWidget);
    });

    testWidgets('shows "On quote" when no rate', (tester) async {
      await tester.pumpWidget(buildSheet(makeUser()));
      await tester.pumpAndSettle();

      expect(find.text('On quote'), findsOneWidget);
    });

    testWidgets('shows specialties tags', (tester) async {
      await tester
          .pumpWidget(buildSheet(makeUser(specialties: ['Mixing', 'Mastering'])));
      await tester.pumpAndSettle();

      expect(find.text('Specialties'), findsOneWidget);
      expect(find.text('Mixing'), findsOneWidget);
      expect(find.text('Mastering'), findsOneWidget);
    });

    testWidgets('shows genres tags', (tester) async {
      await tester
          .pumpWidget(buildSheet(makeUser(genres: ['Hip-Hop', 'R&B'])));
      await tester.pumpAndSettle();

      expect(find.text('Genres'), findsOneWidget);
      expect(find.text('Hip-Hop'), findsOneWidget);
    });

    testWidgets('shows contact button', (tester) async {
      await tester.pumpWidget(buildTestApp(
        authBloc: mockAuthBloc,
        messagingBloc: mockMessagingBloc,
        favoriteBloc: mockFavoriteBloc,
        child: Scaffold(
          body: SizedBox(
            height: 800,
            child: ProDetailBottomSheet(user: makeUser()),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Contact'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Contact'), findsOneWidget);
    });

    testWidgets('shows verified badge when verified', (tester) async {
      await tester.pumpWidget(buildSheet(makeUser(isVerified: true)));
      await tester.pumpAndSettle();

      expect(find.text('DJ Test'), findsOneWidget);
    });
  });
}
