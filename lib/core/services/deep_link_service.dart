import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Service to handle deep links (OAuth callbacks, etc.)
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Callback for calendar OAuth result
  void Function(bool success, String? error)? onCalendarCallback;

  /// Initialize deep link listener
  Future<void> initialize() async {
    // Handle initial link (app opened via deep link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('DeepLinkService: Error getting initial link: $e');
    }

    // Listen for subsequent links (app already running)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (e) => debugPrint('DeepLinkService: Stream error: $e'),
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('DeepLinkService: Received deep link: $uri');

    // Handle calendar OAuth callback
    if (uri.scheme == 'useme' && uri.host == 'calendar-callback') {
      final success = uri.queryParameters['success'] == 'true';
      final error = uri.queryParameters['error'];

      debugPrint('DeepLinkService: Calendar callback - success: $success');

      onCalendarCallback?.call(success, error);
    }
  }

  /// Dispose the service
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
