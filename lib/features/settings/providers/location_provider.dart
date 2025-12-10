import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/data/hive_service.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/services/location_service.dart';
import '../../resources/providers/resources_provider.dart';

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

      // Invalidate providers to refresh data
      ref.invalidate(resourcesProvider);
      ref.invalidate(currentLocationProvider);

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
