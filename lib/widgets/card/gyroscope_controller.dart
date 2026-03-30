import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Provides smoothed device tilt as a normalized Offset (-1 to 1)
/// using the accelerometer (gravity-based, no drift).
class GyroscopeController {
  final ValueNotifier<Offset> tilt = ValueNotifier(Offset.zero);
  StreamSubscription<AccelerometerEvent>? _subscription;

  static const double _smoothing = 0.65;
  static const double _sensitivity = 0.25;

  void init() {
    try {
      _subscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        _onAccelerometerEvent,
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {
      // Sensor not available (web, desktop, simulator)
    }
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Accelerometer: x = left/right tilt, y = forward/back tilt
    // Gravity is ~9.8 on the z axis when flat
    // Normalize by dividing by gravity (~9.8)
    final rawX = (event.x * _sensitivity).clamp(-1.0, 1.0);
    final rawY = (event.y * _sensitivity).clamp(-1.0, 1.0);

    // Smooth with exponential moving average
    final current = tilt.value;
    final smoothedX = current.dx * _smoothing + rawX * (1 - _smoothing);
    final smoothedY = current.dy * _smoothing + rawY * (1 - _smoothing);

    tilt.value = Offset(smoothedX, smoothedY);
  }

  void reset() {
    tilt.value = Offset.zero;
  }

  void dispose() {
    _subscription?.cancel();
    tilt.dispose();
  }
}
