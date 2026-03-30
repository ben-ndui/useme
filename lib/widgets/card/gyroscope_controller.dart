import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Provides smoothed device tilt as a normalized Offset (-1 to 1).
///
/// Auto-calibrates on init: the position when the card opens = "flat".
/// This means however the user holds their phone, the card starts centered.
class GyroscopeController {
  final ValueNotifier<Offset> tilt = ValueNotifier(Offset.zero);
  StreamSubscription<AccelerometerEvent>? _subscription;

  // Calibration: average of first N readings = reference "flat" position
  double? _refX;
  double? _refY;
  int _calibrationSamples = 0;
  static const int _calibrationCount = 10;

  // Tuning
  static const double _sensitivity = 0.15;
  static const double _smoothing = 0.70;
  static const double _deadZone = 0.02;

  void init() {
    try {
      _subscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        _onEvent,
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {
      // Sensor not available
    }
  }

  void _onEvent(AccelerometerEvent event) {
    // Auto-calibrate: average the first N readings as reference
    if (_calibrationSamples < _calibrationCount) {
      _refX = ((_refX ?? 0) * _calibrationSamples + event.x) /
          (_calibrationSamples + 1);
      _refY = ((_refY ?? 0) * _calibrationSamples + event.y) /
          (_calibrationSamples + 1);
      _calibrationSamples++;
      return;
    }

    // Delta from calibrated reference position
    final deltaX = (event.x - (_refX ?? 0)) * _sensitivity;
    final deltaY = (event.y - (_refY ?? 0)) * _sensitivity;

    // Dead zone: ignore tiny jitter
    final rawX = deltaX.abs() < _deadZone ? 0.0 : deltaX;
    final rawY = deltaY.abs() < _deadZone ? 0.0 : deltaY;

    // Clamp and smooth
    final current = tilt.value;
    final smoothedX =
        current.dx * _smoothing + rawX.clamp(-1.0, 1.0) * (1 - _smoothing);
    final smoothedY =
        current.dy * _smoothing + rawY.clamp(-1.0, 1.0) * (1 - _smoothing);

    tilt.value = Offset(smoothedX, smoothedY);
  }

  /// Re-calibrate: current position becomes the new "flat".
  void recalibrate() {
    _refX = null;
    _refY = null;
    _calibrationSamples = 0;
    tilt.value = Offset.zero;
  }

  void reset() {
    tilt.value = Offset.zero;
  }

  void dispose() {
    _subscription?.cancel();
    tilt.dispose();
  }
}
