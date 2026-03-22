import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service to launch native map apps for turn-by-turn directions.
/// Supports Apple Maps (iOS), Google Maps, and web fallback.
class NavigationService {
  /// Opens native maps with directions to the given coordinates.
  ///
  /// On iOS: tries Apple Maps first, then Google Maps app, then web.
  /// On Android: opens Google Maps directly.
  /// On web: opens Google Maps in browser.
  static Future<bool> openDirections({
    required LatLng destination,
    String? destinationName,
  }) async {
    final lat = destination.latitude;
    final lng = destination.longitude;
    final name = destinationName != null
        ? Uri.encodeComponent(destinationName)
        : '';

    // iOS: try Apple Maps first
    if (!kIsWeb && Platform.isIOS) {
      final appleUrl = Uri.parse(
        'maps://maps.apple.com/?daddr=$lat,$lng&dirflg=d${name.isNotEmpty ? '&dname=$name' : ''}',
      );
      if (await canLaunchUrl(appleUrl)) {
        return launchUrl(appleUrl);
      }
    }

    // Try Google Maps app
    final googleAppUrl = Uri.parse(
      'comgooglemaps://?daddr=$lat,$lng&directionsmode=driving',
    );
    if (!kIsWeb && await canLaunchUrl(googleAppUrl)) {
      return launchUrl(googleAppUrl);
    }

    // Fallback: Google Maps web
    final webUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng${name.isNotEmpty ? '&destination_name=$name' : ''}',
    );
    return launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }

  /// Opens the location on the map (view only, no directions).
  static Future<bool> openLocation({
    required LatLng position,
    String? name,
  }) async {
    final lat = position.latitude;
    final lng = position.longitude;
    final label = name != null ? Uri.encodeComponent(name) : '';

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng${label.isNotEmpty ? '&query_place_id=$label' : ''}',
    );
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// Makes a phone call.
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    return launchUrl(uri);
  }

  /// Opens a website.
  static Future<bool> openWebsite(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
