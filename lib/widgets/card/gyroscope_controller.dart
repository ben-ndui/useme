import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Provides smoothed device tilt as a normalized Offset (-1 to 1).
/// Falls back to Offset.zero when gyroscope is unavailable (simulator).
class GyroscopeController {
  final ValueNotifier<Offset> tilt = ValueNotifier(Offset.zero);
  StreamSubscription<GyroscopeEvent>? _subscription;

  // Accumulated rotation in radians
  double _rotX = 0;
  double _rotY = 0;

  // Smoothing factor (0 = no smoothing, 1 = frozen)
  static const double _smoothing = 0.85;
  static const double _sensitivity = 0.4;
  static const double _maxTilt = 1.0;

  void init() {
    try {
      _subscription = gyroscopeEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        _onGyroscopeEvent,
        onError: (_) {}, // Silently ignore if unavailable
        cancelOnError: false,
      );
    } catch (_) {
      // Gyroscope not available (web, desktop, simulator)
    }
  }

  void _onGyroscopeEvent(GyroscopeEvent event) {
    // Integrate angular velocity to get rotation
    _rotX += event.x * 0.016 * _sensitivity;
    _rotY += event.y * 0.016 * _sensitivity;

    // Clamp to max tilt
    _rotX = _rotX.clamp(-_maxTilt, _maxTilt);
    _rotY = _rotY.clamp(-_maxTilt, _maxTilt);

    // Apply exponential moving average smoothing
    final current = tilt.value;
    final smoothedX = current.dx * _smoothing + _rotY * (1 - _smoothing);
    final smoothedY = current.dy * _smoothing + _rotX * (1 - _smoothing);

    tilt.value = Offset(smoothedX, smoothedY);

    // Slowly decay towards center when device is still
    _rotX *= 0.98;
    _rotY *= 0.98;
  }

  /// Reset tilt to center.
  void reset() {
    _rotX = 0;
    _rotY = 0;
    tilt.value = Offset.zero;
  }

  void dispose() {
    _subscription?.cancel();
    tilt.dispose();
  }
}
