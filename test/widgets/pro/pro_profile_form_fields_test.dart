import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/screens/shared/pro/pro_profile_form_fields.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  late TextEditingController displayNameCtrl;
  late TextEditingController bioCtrl;
  late TextEditingController rateCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController websiteCtrl;
  late TextEditingController phoneCtrl;

  setUp(() {
    displayNameCtrl = TextEditingController();
    bioCtrl = TextEditingController();
    rateCtrl = TextEditingController();
    cityCtrl = TextEditingController();
    websiteCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
  });

  tearDown(() {
    displayNameCtrl.dispose();
    bioCtrl.dispose();
    rateCtrl.dispose();
    cityCtrl.dispose();
    websiteCtrl.dispose();
    phoneCtrl.dispose();
  });

  Widget buildFields({
    List<ProType> selectedTypes = const [],
    List<String> specialties = const [],
    List<String> instruments = const [],
    List<String> genres = const [],
    List<String> daws = const [],
    bool remote = false,
    bool isAvailable = true,
    ValueChanged<List<String>>? onSpecialtiesChanged,
    ValueChanged<List<String>>? onInstrumentsChanged,
    ValueChanged<List<String>>? onGenresChanged,
    ValueChanged<List<String>>? onDawsChanged,
    ValueChanged<bool>? onRemoteChanged,
    ValueChanged<bool>? onAvailabilityChanged,
  }) {
    return buildTestApp(
      child: Scaffold(
        body: SingleChildScrollView(
          child: ProProfileFormFields(
            displayNameController: displayNameCtrl,
            bioController: bioCtrl,
            hourlyRateController: rateCtrl,
            cityController: cityCtrl,
            websiteController: websiteCtrl,
            phoneController: phoneCtrl,
            specialties: specialties,
            instruments: instruments,
            genres: genres,
            daws: daws,
            remote: remote,
            isAvailable: isAvailable,
            selectedTypes: selectedTypes,
            onSpecialtiesChanged: onSpecialtiesChanged ?? (_) {},
            onInstrumentsChanged: onInstrumentsChanged ?? (_) {},
            onGenresChanged: onGenresChanged ?? (_) {},
            onDawsChanged: onDawsChanged ?? (_) {},
            onRemoteChanged: onRemoteChanged ?? (_) {},
            onAvailabilityChanged: onAvailabilityChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('ProProfileFormFields', () {
    testWidgets('renders base fields', (tester) async {
      await tester.pumpWidget(buildFields());
      await tester.pumpAndSettle();

      // displayName, bio, rate, city, website, phone = 6
      expect(find.byType(TextFormField), findsNWidgets(6));
      // + tag text fields (specialties, genres)
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows instruments field for musician', (tester) async {
      await tester.pumpWidget(buildFields(
        selectedTypes: [ProType.musician],
      ));
      await tester.pumpAndSettle();

      // Scroll down to reveal instruments field
      await tester.scrollUntilVisible(
        find.text('Instruments'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Instruments'), findsOneWidget);
    });

    testWidgets('hides instruments field without musician/composer',
        (tester) async {
      await tester.pumpWidget(buildFields(
        selectedTypes: [ProType.producer],
      ));
      await tester.pumpAndSettle();

      // instruments section not visible, but DAWs should be
      // Look for the instruments label specifically
      expect(
        find.textContaining('Instruments'),
        findsNothing,
      );
    });

    testWidgets('shows DAWs field for sound engineer', (tester) async {
      await tester.pumpWidget(buildFields(
        selectedTypes: [ProType.soundEngineer],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('DAW'), findsWidgets);
    });

    testWidgets('shows DAWs field for producer', (tester) async {
      await tester.pumpWidget(buildFields(
        selectedTypes: [ProType.producer],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('DAW'), findsWidgets);
    });

    testWidgets('hides DAWs for vocalist', (tester) async {
      await tester.pumpWidget(buildFields(
        selectedTypes: [ProType.vocalist],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('DAW'), findsNothing);
    });

    testWidgets('displays existing tags as chips', (tester) async {
      await tester.pumpWidget(buildFields(
        specialties: ['Mixing', 'Mastering'],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Mixing'), findsOneWidget);
      expect(find.text('Mastering'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));
    });

    testWidgets('remote switch toggles', (tester) async {
      bool remoteValue = false;

      await tester.pumpWidget(buildFields(
        remote: false,
        onRemoteChanged: (v) => remoteValue = v,
      ));
      await tester.pumpAndSettle();

      // Scroll down to reveal the remote switch
      await tester.scrollUntilVisible(
        find.byType(SwitchListTile).first,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      expect(remoteValue, isTrue);
    });

    testWidgets('can enter text in displayName', (tester) async {
      await tester.pumpWidget(buildFields());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'DJ Producer');
      expect(displayNameCtrl.text, 'DJ Producer');
    });
  });
}
