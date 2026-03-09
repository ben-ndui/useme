import 'package:flutter/foundation.dart';

/// Debug-only logger that wraps debugPrint with kDebugMode check.
/// In release builds, calls are compiled out entirely.
void appLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
