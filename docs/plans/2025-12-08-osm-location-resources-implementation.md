# OSM Location-Based Resources Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Auto-populate Resources with real data from OpenStreetMap when user enters their city/zip code.

**Architecture:** LocationService handles Nominatim geocoding and Overpass queries. HiveService stores location preferences. Location setup screen accessible from settings. Resources provider checks for real data before falling back to samples.

**Tech Stack:** Flutter, Riverpod, Hive, HTTP (dart:io/http package), OpenStreetMap Overpass API, Nominatim API

---

## Task 1: Add HTTP Dependency

**Files:**
- Modify: `pubspec.yaml:23` (after url_launcher)

**Step 1: Add http package**

Add to dependencies section after `url_launcher`:

```yaml
  http: ^1.2.2
```

**Step 2: Install dependencies**

Run: `flutter pub get`
Expected: Resolving dependencies... Got dependencies!

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "Add http package for API calls"
```

---

## Task 2: Create Location Model

**Files:**
- Create: `lib/shared/models/user_location.dart`
- Modify: `lib/shared/models/models.dart`

**Step 1: Create UserLocation model**

Create `lib/shared/models/user_location.dart`:

```dart
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
```

**Step 2: Export from models barrel**

Add to `lib/shared/models/models.dart`:

```dart
export 'user_location.dart';
```

**Step 3: Commit**

```bash
git add lib/shared/models/user_location.dart lib/shared/models/models.dart
git commit -m "Add UserLocation model for geocoding results"
```

---

## Task 3: Create LocationService

**Files:**
- Create: `lib/shared/services/location_service.dart`

**Step 1: Create the service**

Create `lib/shared/services/location_service.dart`:

```dart
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
```

**Step 2: Commit**

```bash
git add lib/shared/services/location_service.dart
git commit -m "Add LocationService for geocoding and OSM queries"
```

---

## Task 4: Extend HiveService with Location Settings

**Files:**
- Modify: `lib/shared/data/hive_service.dart`

**Step 1: Add location getters/setters**

Add after line 105 (after `setSeenOnboarding`), before the closing brace:

```dart
  // Location settings
  String? get locationName => Hive.box(settingsBox).get('locationName');
  double? get locationLat => Hive.box(settingsBox).get('locationLat');
  double? get locationLon => Hive.box(settingsBox).get('locationLon');
  bool get hasLocation => locationName != null && locationLat != null && locationLon != null;
  bool get isUsingRealData => Hive.box(settingsBox).get('isUsingRealData', defaultValue: false);

  Future<void> setLocation({
    required String name,
    required double lat,
    required double lon,
  }) async {
    final box = Hive.box(settingsBox);
    await box.put('locationName', name);
    await box.put('locationLat', lat);
    await box.put('locationLon', lon);
  }

  Future<void> clearLocation() async {
    final box = Hive.box(settingsBox);
    await box.delete('locationName');
    await box.delete('locationLat');
    await box.delete('locationLon');
    await box.put('isUsingRealData', false);
  }

  // Resources management for real data
  Future<void> setResources(List<LocalResource> resources) async {
    final box = Hive.box<LocalResource>(resourcesBox);
    await box.clear();
    for (final resource in resources) {
      await box.put(resource.id, resource);
    }
    await Hive.box(settingsBox).put('isUsingRealData', true);
  }

  Future<void> resetToSampleData() async {
    await clearLocation();
    final resources = Hive.box<LocalResource>(resourcesBox);
    await resources.clear();
    for (final resource in SampleData.resources) {
      await resources.put(resource.id, resource);
    }
  }
```

**Step 2: Commit**

```bash
git add lib/shared/data/hive_service.dart
git commit -m "Add location settings and resource management to HiveService"
```

---

## Task 5: Create Location Provider

**Files:**
- Create: `lib/features/settings/providers/location_provider.dart`

**Step 1: Create the provider**

Create `lib/features/settings/providers/location_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/data/hive_service.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/services/location_service.dart';

part 'location_provider.g.dart';

enum LocationSetupStatus {
  idle,
  searching,
  selectingLocation,
  fetchingResources,
  success,
  error,
}

class LocationSetupState {
  final LocationSetupStatus status;
  final List<UserLocation> searchResults;
  final String? errorMessage;

  const LocationSetupState({
    this.status = LocationSetupStatus.idle,
    this.searchResults = const [],
    this.errorMessage,
  });

  LocationSetupState copyWith({
    LocationSetupStatus? status,
    List<UserLocation>? searchResults,
    String? errorMessage,
  }) {
    return LocationSetupState(
      status: status ?? this.status,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class LocationSetup extends _$LocationSetup {
  late final LocationService _locationService;
  late final HiveService _hiveService;

  @override
  LocationSetupState build() {
    _locationService = LocationService();
    return const LocationSetupState();
  }

  Future<void> initHiveService() async {
    _hiveService = await ref.read(hiveServiceProvider.future);
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(
      status: LocationSetupStatus.searching,
      errorMessage: null,
    );

    try {
      final results = await _locationService.geocode(query);
      if (results.isEmpty) {
        state = state.copyWith(
          status: LocationSetupStatus.error,
          errorMessage: 'No locations found. Try a different search.',
        );
      } else {
        state = state.copyWith(
          status: LocationSetupStatus.selectingLocation,
          searchResults: results,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: LocationSetupStatus.error,
        errorMessage: 'Could not search. Check your internet connection.',
      );
    }
  }

  Future<bool> selectLocation(UserLocation location) async {
    state = state.copyWith(
      status: LocationSetupStatus.fetchingResources,
      errorMessage: null,
    );

    try {
      await initHiveService();

      // Save location
      await _hiveService.setLocation(
        name: location.displayName,
        lat: location.lat,
        lon: location.lon,
      );

      // Fetch and save resources
      final resources = await _locationService.fetchResources(location);
      if (resources.isEmpty) {
        state = state.copyWith(
          status: LocationSetupStatus.error,
          errorMessage: 'No resources found nearby. Try a different location.',
        );
        return false;
      }

      await _hiveService.setResources(resources);

      // Invalidate resources provider to refresh data
      ref.invalidate(resourcesProvider);

      state = state.copyWith(status: LocationSetupStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: LocationSetupStatus.error,
        errorMessage: 'Could not fetch resources. Please try again.',
      );
      return false;
    }
  }

  void reset() {
    state = const LocationSetupState();
  }
}

@riverpod
class CurrentLocation extends _$CurrentLocation {
  @override
  Future<UserLocation?> build() async {
    final hive = await ref.watch(hiveServiceProvider.future);
    if (!hive.hasLocation) return null;
    return UserLocation(
      displayName: hive.locationName!,
      lat: hive.locationLat!,
      lon: hive.locationLon!,
    );
  }
}
```

**Step 2: Generate provider code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Build completed successfully

**Step 3: Commit**

```bash
git add lib/features/settings/providers/
git commit -m "Add location setup and current location providers"
```

---

## Task 6: Create Location Setup Screen

**Files:**
- Create: `lib/features/settings/screens/location_setup_screen.dart`

**Step 1: Create the screen**

Create `lib/features/settings/screens/location_setup_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../shared/models/models.dart';
import '../providers/location_provider.dart';

class LocationSetupScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;

  const LocationSetupScreen({
    super.key,
    this.isOnboarding = false,
  });

  @override
  ConsumerState<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends ConsumerState<LocationSetupScreen> {
  final _controller = TextEditingController();
  UserLocation? _selectedLocation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(locationSetupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Location'),
        actions: widget.isOnboarding
            ? [
                TextButton(
                  onPressed: () => context.go('/events'),
                  child: const Text('Skip'),
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your city or zip code to find local resources',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Portland, OR or 97201',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: setupState.status == LocationSetupStatus.searching
                      ? null
                      : _search,
                  child: setupState.status == LocationSetupStatus.searching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (setupState.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        setupState.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (setupState.status == LocationSetupStatus.selectingLocation) ...[
              Text(
                'Select your location:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: setupState.searchResults.length,
                  itemBuilder: (context, index) {
                    final location = setupState.searchResults[index];
                    final isSelected = _selectedLocation == location;
                    return RadioListTile<UserLocation>(
                      value: location,
                      groupValue: _selectedLocation,
                      onChanged: (value) {
                        setState(() => _selectedLocation = value);
                      },
                      title: Text(
                        location.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: isSelected,
                      activeColor: AppColors.primary,
                    );
                  },
                ),
              ),
            ],
            if (setupState.status == LocationSetupStatus.fetchingResources)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Finding local resources...'),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            if (setupState.status == LocationSetupStatus.selectingLocation)
              FilledButton(
                onPressed: _selectedLocation != null ? _confirmSelection : null,
                child: const Text('Continue'),
              ),
          ],
        ),
      ),
    );
  }

  void _search() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() => _selectedLocation = null);
    ref.read(locationSetupProvider.notifier).search(query);
  }

  Future<void> _confirmSelection() async {
    if (_selectedLocation == null) return;
    final success = await ref
        .read(locationSetupProvider.notifier)
        .selectLocation(_selectedLocation!);
    if (success && mounted) {
      if (widget.isOnboarding) {
        context.go('/events');
      } else {
        context.pop();
      }
    }
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/settings/screens/location_setup_screen.dart
git commit -m "Add LocationSetupScreen for city/zip entry"
```

---

## Task 7: Add Route to Router

**Files:**
- Modify: `lib/app/router.dart`

**Step 1: Add import**

Add after line 11 (after settings_screen import):

```dart
import '../features/settings/screens/location_setup_screen.dart';
```

**Step 2: Add route**

Add after line 32 (after settings route), before ShellRoute:

```dart
    GoRoute(
      path: '/location-setup',
      builder: (context, state) {
        final isOnboarding = state.uri.queryParameters['onboarding'] == 'true';
        return LocationSetupScreen(isOnboarding: isOnboarding);
      },
    ),
```

**Step 3: Commit**

```bash
git add lib/app/router.dart
git commit -m "Add location setup route"
```

---

## Task 8: Add Location Section to Settings Screen

**Files:**
- Modify: `lib/features/settings/screens/settings_screen.dart`

**Step 1: Add imports**

Add after line 4:

```dart
import 'package:go_router/go_router.dart';
import '../providers/location_provider.dart';
```

**Step 2: Add Location section**

Add after line 40 (after the Display section closing bracket), before Notifications section:

```dart
          // Location Section
          _SettingsSection(
            title: 'Location',
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final locationAsync = ref.watch(currentLocationProvider);
                  return locationAsync.when(
                    data: (location) => _SettingsTile(
                      icon: Icons.location_on_outlined,
                      label: 'Your Location',
                      subtitle: location?.displayName ?? 'Not set - using sample data',
                      onTap: () => context.push('/location-setup'),
                    ),
                    loading: () => const _SettingsTile(
                      icon: Icons.location_on_outlined,
                      label: 'Your Location',
                      subtitle: 'Loading...',
                    ),
                    error: (_, __) => _SettingsTile(
                      icon: Icons.location_on_outlined,
                      label: 'Your Location',
                      subtitle: 'Error loading location',
                      onTap: () => context.push('/location-setup'),
                    ),
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final locationAsync = ref.watch(currentLocationProvider);
                  final hasLocation = locationAsync.valueOrNull != null;
                  if (!hasLocation) return const SizedBox.shrink();
                  return _SettingsTile(
                    icon: Icons.refresh,
                    label: 'Reset to Sample Data',
                    subtitle: 'Clear location and use demo data',
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset to Sample Data?'),
                          content: const Text(
                            'This will clear your location and replace resources with sample data.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        final hive = await ref.read(hiveServiceProvider.future);
                        await hive.resetToSampleData();
                        ref.invalidate(currentLocationProvider);
                        ref.invalidate(resourcesProvider);
                      }
                    },
                  );
                },
              ),
            ],
          ),
```

**Step 3: Add missing imports for providers**

Add after existing imports:

```dart
import '../../../shared/providers/providers.dart';
import '../../../features/resources/providers/resources_provider.dart';
```

**Step 4: Commit**

```bash
git add lib/features/settings/screens/settings_screen.dart
git commit -m "Add location section to settings screen"
```

---

## Task 9: Invalidate Resources on Location Change

**Files:**
- Modify: `lib/features/resources/providers/resources_provider.dart`

**Step 1: Check current provider implementation**

Read the file to understand current structure, then ensure it properly refreshes when location changes.

The provider already reads from HiveService, which now returns real data when available. No changes needed - the `ref.invalidate(resourcesProvider)` calls in Task 5 and Task 8 handle refresh.

**Step 2: Commit (if changes made)**

Skip if no changes needed.

---

## Task 10: Run and Test

**Step 1: Generate all providers**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Build completed successfully

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found!

**Step 3: Run the app**

Run: `flutter run -d chrome`

**Step 4: Manual test checklist**

1. Go to Settings > Your Location
2. Enter a city name (e.g., "Portland, OR")
3. Verify search results appear
4. Select a location and tap Continue
5. Verify "Finding local resources..." loading state
6. Verify navigation back to settings
7. Go to Resources tab - verify real data appears
8. Go to Settings > Reset to Sample Data
9. Confirm reset
10. Verify Resources shows sample data again

**Step 5: Final commit**

```bash
git add -A
git commit -m "Complete OSM location-based resources feature"
```

---

## Summary

**Files created:**
- `lib/shared/models/user_location.dart`
- `lib/shared/services/location_service.dart`
- `lib/features/settings/providers/location_provider.dart`
- `lib/features/settings/screens/location_setup_screen.dart`

**Files modified:**
- `pubspec.yaml` (add http dependency)
- `lib/shared/models/models.dart` (export UserLocation)
- `lib/shared/data/hive_service.dart` (location settings)
- `lib/app/router.dart` (location-setup route)
- `lib/features/settings/screens/settings_screen.dart` (location section)

**Total commits:** 9 small, focused commits
