import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/widgets/card/holo_card_theme.dart';
import 'package:useme/widgets/card/holo_gradient_overlay.dart';

void main() {
  group('HoloGradientOverlay', () {
    Widget buildOverlay(Offset tilt) {
      return MaterialApp(
        home: SizedBox(
          width: 400,
          height: 250,
          child: HoloGradientOverlay(
            tilt: tilt,
            theme: HoloCardTheme.forRole(BaseUserRole.client),
          ),
        ),
      );
    }

    testWidgets('renders without error at zero tilt', (tester) async {
      await tester.pumpWidget(buildOverlay(Offset.zero));
      expect(find.byType(HoloGradientOverlay), findsOneWidget);
    });

    testWidgets('renders without error at max tilt', (tester) async {
      await tester.pumpWidget(buildOverlay(const Offset(1.0, 1.0)));
      expect(find.byType(HoloGradientOverlay), findsOneWidget);
    });

    testWidgets('renders at negative tilt values', (tester) async {
      await tester.pumpWidget(buildOverlay(const Offset(-1.0, -1.0)));
      expect(find.byType(HoloGradientOverlay), findsOneWidget);
    });

    testWidgets('does not intercept pointer events', (tester) async {
      await tester.pumpWidget(buildOverlay(const Offset(0.5, 0.3)));
      // The overlay wraps content in IgnorePointer(ignoring: true)
      final ignoringWidgets = tester
          .widgetList<IgnorePointer>(find.byType(IgnorePointer))
          .where((w) => w.ignoring);
      expect(ignoringWidgets, isNotEmpty);
    });
  });
}
