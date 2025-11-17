// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hiveService)
const hiveServiceProvider = HiveServiceProvider._();

final class HiveServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<HiveService>,
          HiveService,
          FutureOr<HiveService>
        >
    with $FutureModifier<HiveService>, $FutureProvider<HiveService> {
  const HiveServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiveServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiveServiceHash();

  @$internal
  @override
  $FutureProviderElement<HiveService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HiveService> create(Ref ref) {
    return hiveService(ref);
  }
}

String _$hiveServiceHash() => r'5775c3d29a0cb970e8d318f3e6f7aae3c905068a';
