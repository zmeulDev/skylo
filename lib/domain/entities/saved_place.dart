class SavedPlace {
  final String id;
  final String name;
  final String? state;
  final String? country;
  final double lat;
  final double lon;
  final bool isCurrentLocation;

  const SavedPlace({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    this.state,
    this.country,
    this.isCurrentLocation = false,
  });

  factory SavedPlace.current() => const SavedPlace(
        id: 'current',
        name: 'Current location',
        lat: 0,
        lon: 0,
        isCurrentLocation: true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
        'country': country,
        'lat': lat,
        'lon': lon,
      };

  factory SavedPlace.fromJson(Map<String, dynamic> json) => SavedPlace(
        id: json['id'] as String,
        name: json['name'] as String,
        state: json['state'] as String?,
        country: json['country'] as String?,
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
      );

  String get label => isCurrentLocation || state == null || state == name
      ? name
      : '$name, $state';
}