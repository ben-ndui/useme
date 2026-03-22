/// Travel mode for directions API.
enum TravelMode {
  driving,
  walking,
  transit,
  bicycling;

  String get apiValue => name;

  String get label {
    switch (this) {
      case TravelMode.driving:
        return 'Voiture';
      case TravelMode.walking:
        return 'À pied';
      case TravelMode.transit:
        return 'Transports';
      case TravelMode.bicycling:
        return 'Vélo';
    }
  }
}
