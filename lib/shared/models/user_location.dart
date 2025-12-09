class UserLocation {
  final String displayName;
  final double lat;
  final double lon;

  const UserLocation({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory UserLocation.fromNominatim(Map<String, dynamic> json) {
    return UserLocation(
      displayName: json['display_name'] as String,
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'lat': lat,
        'lon': lon,
      };

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      displayName: json['displayName'] as String,
      lat: json['lat'] as double,
      lon: json['lon'] as double,
    );
  }
}
