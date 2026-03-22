import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:useme/core/models/navigation/navigation_exports.dart';
import 'package:useme/core/services/env_service.dart';

/// Fetches turn-by-turn directions from the Google Directions API.
class DirectionsService {
  final http.Client _client;

  DirectionsService({http.Client? client})
      : _client = client ?? http.Client();

  /// Gets directions between two points.
  /// Returns null if the API call fails or no route is found.
  Future<DirectionsResult?> getDirections({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.driving,
  }) async {
    try {
      final apiKey = EnvService.googleMapsApiKey;
      if (apiKey.isEmpty) {
        debugPrint('[Directions] No API key');
        return null;
      }

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json',
      ).replace(queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': mode.apiValue,
        'key': apiKey,
        'language': 'fr',
      });

      debugPrint('[Directions] GET $uri');
      final response = await _client.get(uri);
      debugPrint('[Directions] status=${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[Directions] HTTP error: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('[Directions] API status=${data['status']}');

      if (data['status'] != 'OK' ||
          (data['routes'] as List).isEmpty) {
        debugPrint('[Directions] Error: ${data['status']} - ${data['error_message'] ?? 'no routes'}');
        return null;
      }

      return DirectionsResult.fromMap(
        data['routes'][0] as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('[Directions] Error: $e');
      return null;
    }
  }
}
