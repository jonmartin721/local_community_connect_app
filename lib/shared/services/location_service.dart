import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class LocationService {
  static const String _nominatimBase = 'https://nominatim.openstreetmap.org';
  static const String _overpassBase = 'https://overpass-api.de/api/interpreter';
  static const int _searchRadius = 10000; // 10km in meters

  /// Geocode a search query (city name or zip code) to coordinates
  Future<List<UserLocation>> geocode(String query) async {
    final uri = Uri.parse('$_nominatimBase/search').replace(
      queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '5',
        'addressdetails': '1',
      },
    );

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'LocalCommunityConnectApp/1.0'},
    );

    if (response.statusCode != 200) {
      throw Exception('Geocoding failed: ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => UserLocation.fromNominatim(e)).toList();
  }

  /// Fetch local resources from OpenStreetMap for a location
  Future<List<LocalResource>> fetchResources(UserLocation location) async {
    final query = _buildOverpassQuery(location.lat, location.lon);

    final response = await http.post(
      Uri.parse(_overpassBase),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'data': query},
    );

    if (response.statusCode != 200) {
      throw Exception('Overpass query failed: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final elements = data['elements'] as List<dynamic>;

    return elements
        .map((e) => _elementToResource(e))
        .whereType<LocalResource>()
        .toList();
  }

  String _buildOverpassQuery(double lat, double lon) {
    return '''
[out:json][timeout:30];
(
  node["amenity"="library"](around:$_searchRadius,$lat,$lon);
  node["amenity"="school"](around:$_searchRadius,$lat,$lon);
  node["amenity"="community_centre"](around:$_searchRadius,$lat,$lon);
  node["leisure"="sports_centre"](around:$_searchRadius,$lat,$lon);
  node["office"="government"](around:$_searchRadius,$lat,$lon);
  node["amenity"="townhall"](around:$_searchRadius,$lat,$lon);
  node["amenity"="post_office"](around:$_searchRadius,$lat,$lon);
  node["amenity"="police"](around:$_searchRadius,$lat,$lon);
  node["amenity"="fire_station"](around:$_searchRadius,$lat,$lon);
  node["amenity"="hospital"](around:$_searchRadius,$lat,$lon);
  node["leisure"="park"](around:$_searchRadius,$lat,$lon);
  node["amenity"="clinic"](around:$_searchRadius,$lat,$lon);
  node["amenity"="pharmacy"](around:$_searchRadius,$lat,$lon);
  way["amenity"="library"](around:$_searchRadius,$lat,$lon);
  way["amenity"="school"](around:$_searchRadius,$lat,$lon);
  way["amenity"="community_centre"](around:$_searchRadius,$lat,$lon);
  way["leisure"="sports_centre"](around:$_searchRadius,$lat,$lon);
  way["office"="government"](around:$_searchRadius,$lat,$lon);
  way["amenity"="townhall"](around:$_searchRadius,$lat,$lon);
  way["amenity"="police"](around:$_searchRadius,$lat,$lon);
  way["amenity"="fire_station"](around:$_searchRadius,$lat,$lon);
  way["amenity"="hospital"](around:$_searchRadius,$lat,$lon);
  way["leisure"="park"](around:$_searchRadius,$lat,$lon);
);
out center tags;
''';
  }

  LocalResource? _elementToResource(Map<String, dynamic> element) {
    final tags = element['tags'] as Map<String, dynamic>?;
    if (tags == null) return null;

    final name = tags['name'] as String?;
    if (name == null) return null;

    final id = 'osm-${element['id']}';
    final category = _determineCategory(tags);

    // Build address from components
    String? address;
    final street = tags['addr:street'] as String?;
    final houseNumber = tags['addr:housenumber'] as String?;
    final city = tags['addr:city'] as String?;
    if (street != null) {
      address = houseNumber != null ? '$houseNumber $street' : street;
      if (city != null) address = '$address, $city';
    }

    return LocalResource(
      id: id,
      name: name,
      category: category,
      address: address,
      phoneNumber: tags['phone'] as String? ?? tags['contact:phone'] as String?,
      websiteUrl: tags['website'] as String? ?? tags['contact:website'] as String?,
      description: tags['description'] as String?,
    );
  }

  String _determineCategory(Map<String, dynamic> tags) {
    final amenity = tags['amenity'] as String?;
    final leisure = tags['leisure'] as String?;
    final office = tags['office'] as String?;

    if (amenity == 'library' || amenity == 'school') return 'Education';
    if (amenity == 'community_centre' || leisure == 'sports_centre') {
      return 'Recreation';
    }
    if (office == 'government' || amenity == 'townhall' || amenity == 'post_office') {
      return 'Government';
    }
    if (amenity == 'police' || amenity == 'fire_station') {
      return 'Emergency Services';
    }
    if (amenity == 'hospital' || amenity == 'clinic' || amenity == 'pharmacy') {
      return 'Health';
    }
    if (leisure == 'park') return 'Parks';

    return 'Community Services';
  }
}
