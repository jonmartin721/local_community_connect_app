// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocationSetup)
const locationSetupProvider = LocationSetupProvider._();

final class LocationSetupProvider
    extends $NotifierProvider<LocationSetup, LocationSetupState> {
  const LocationSetupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationSetupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationSetupHash();

  @$internal
  @override
  LocationSetup create() => LocationSetup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationSetupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationSetupState>(value),
    );
  }
}

String _$locationSetupHash() => r'1680db04ec60453dfea319322596f54607405035';

abstract class _$LocationSetup extends $Notifier<LocationSetupState> {
  LocationSetupState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LocationSetupState, LocationSetupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocationSetupState, LocationSetupState>,
              LocationSetupState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CurrentLocation)
const currentLocationProvider = CurrentLocationProvider._();

final class CurrentLocationProvider
    extends $AsyncNotifierProvider<CurrentLocation, UserLocation?> {
  const CurrentLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentLocationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentLocationHash();

  @$internal
  @override
  CurrentLocation create() => CurrentLocation();
}

String _$currentLocationHash() => r'b6097da0e41aab72856731140a2688eac89996ad';

abstract class _$CurrentLocation extends $AsyncNotifier<UserLocation?> {
  FutureOr<UserLocation?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<UserLocation?>, UserLocation?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserLocation?>, UserLocation?>,
              AsyncValue<UserLocation?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
