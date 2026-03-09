import 'dart:ui' show Brightness;

/// Custom Google Maps styles matching UZME brand colors.
/// Light: subtle blue tint on water/roads, muted landmarks.
/// Dark: deep dark surfaces with UZME blue accents.
class MapStyles {
  MapStyles._();

  /// Light map style — clean, subtle blue accents
  static const String light = '''
[
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#c5d4f5"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#0B38BF"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#dce3f4"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#b8c6e8"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#e8ecf6"}]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#f0f2f8"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [{"saturation": -40}, {"lightness": 10}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#d4ecd8"}]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#f5f6fa"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#eef0f5"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels.icon",
    "stylers": [{"saturation": -50}]
  }
]
''';

  /// Dark map style — deep UZME dark surfaces with blue accents
  static const String dark = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#0D0D0F"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8B8B95"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#0D0D0F"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#252529"}]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#45454D"}]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#151518"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#121214"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#1C1C20"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6E6E78"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#0F1A12"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#3a6b44"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#1C1C20"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#252529"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6E6E78"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#1A2B5E"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#0B38BF", "weight": 0.5}]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [{"color": "#151518"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#5B7FE8"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#080C1A"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#3B5FC7"}]
  }
]
''';

  /// Returns the appropriate style based on brightness.
  static String forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}
