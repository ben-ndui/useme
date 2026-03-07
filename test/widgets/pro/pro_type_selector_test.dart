import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/screens/shared/pro/pro_type_selector.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ProTypeSelector', () {
    testWidgets('renders all ProType chips', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProTypeSelector(
            selectedTypes: const [],
            onChanged: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      for (final type in ProType.values) {
        expect(find.text(type.label), findsOneWidget);
      }
    });

    testWidgets('renders 6 FilterChips', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProTypeSelector(
            selectedTypes: const [],
            onChanged: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsNWidgets(6));
    });

    testWidgets('shows label and hint text', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProTypeSelector(
            selectedTypes: const [],
            onChanged: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('What do you offer?'), findsOneWidget);
      expect(find.text('Select one or more roles'), findsOneWidget);
    });

    testWidgets('tapping chip adds it to selection', (tester) async {
      List<ProType> result = [];

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProTypeSelector(
            selectedTypes: const [],
            onChanged: (types) => result = types,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(ProType.musician.label));
      await tester.pumpAndSettle();

      expect(result, contains(ProType.musician));
    });

    testWidgets('tapping selected chip removes it', (tester) async {
      List<ProType> result = [ProType.musician];

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProTypeSelector(
            selectedTypes: const [ProType.musician],
            onChanged: (types) => result = types,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(ProType.musician.label));
      await tester.pumpAndSettle();

      expect(result, isNot(contains(ProType.musician)));
    });

    testWidgets('multiple chips can be selected', (tester) async {
      List<ProType> result = [ProType.musician];

      await tester.pumpWidget(buildTestApp(
        child: Scaffold(
          body: ProTypeSelector(
            selectedTypes: const [ProType.musician],
            onChanged: (types) => result = types,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(ProType.producer.label));
      await tester.pumpAndSettle();

      expect(result, contains(ProType.musician));
      expect(result, contains(ProType.producer));
    });
  });
}
