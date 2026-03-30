import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:useme/widgets/card/gyroscope_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GyroscopeController', () {
    late GyroscopeController controller;

    setUp(() {
      controller = GyroscopeController();
    });

    test('initial tilt is Offset.zero', () {
      expect(controller.tilt.value, Offset.zero);
    });

    test('reset sets tilt back to zero', () {
      controller.tilt.value = const Offset(0.5, 0.3);
      controller.reset();
      expect(controller.tilt.value, Offset.zero);
      controller.dispose();
    });

    test('recalibrate resets tilt and calibration state', () {
      controller.tilt.value = const Offset(0.5, 0.3);
      controller.recalibrate();
      expect(controller.tilt.value, Offset.zero);
      controller.dispose();
    });

    test('tilt value is a ValueNotifier', () {
      expect(controller.tilt, isA<ValueNotifier>());
      controller.dispose();
    });
  });
}
