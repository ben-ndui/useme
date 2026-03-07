import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/widgets/pro/pro_filter_sheet.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ProFilterSheet', () {
    Widget buildSheet({
      List<ProType> selectedTypes = const [],
      bool remoteOnly = false,
      ValueChanged<ProFilterParams>? onApply,
    }) {
      return buildTestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: ProFilterSheet(
              selectedTypes: selectedTypes,
              remoteOnly: remoteOnly,
              onApply: onApply ?? (_) {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders all ProType filter chips', (tester) async {
      await tester.pumpWidget(buildSheet());
      await tester.pumpAndSettle();

      for (final type in ProType.values) {
        await tester.scrollUntilVisible(
          find.text(type.label),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(type.label), findsOneWidget);
      }
    });

    testWidgets('renders remote toggle', (tester) async {
      await tester.pumpWidget(buildSheet());
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('renders city text field', (tester) async {
      await tester.pumpWidget(buildSheet());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('pre-selects given types', (tester) async {
      await tester.pumpWidget(buildSheet(
        selectedTypes: [ProType.musician],
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text(ProType.musician.label),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      final chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, ProType.musician.label),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('apply returns filter params', (tester) async {
      ProFilterParams? result;

      await tester.pumpWidget(buildSheet(
        selectedTypes: [ProType.producer],
        remoteOnly: true,
        onApply: (params) => result = params,
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Apply'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.types, contains(ProType.producer));
      expect(result!.remoteOnly, isTrue);
    });

    testWidgets('clear returns empty params', (tester) async {
      ProFilterParams? result;

      await tester.pumpWidget(buildSheet(
        selectedTypes: [ProType.musician],
        remoteOnly: true,
        onApply: (params) => result = params,
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Clear'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.types, isEmpty);
      expect(result!.remoteOnly, isFalse);
      expect(result!.city, isNull);
    });
  });

  group('ProFilterParams', () {
    test('hasActiveFilters with types', () {
      const params = ProFilterParams(types: [ProType.musician]);
      expect(params.hasActiveFilters, isTrue);
    });

    test('hasActiveFilters with city', () {
      const params = ProFilterParams(city: 'Paris');
      expect(params.hasActiveFilters, isTrue);
    });

    test('hasActiveFilters with remote', () {
      const params = ProFilterParams(remoteOnly: true);
      expect(params.hasActiveFilters, isTrue);
    });

    test('hasActiveFilters false when empty', () {
      const params = ProFilterParams();
      expect(params.hasActiveFilters, isFalse);
    });
  });
}
