// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resources_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ResourcesNotifier)
const resourcesProvider = ResourcesNotifierProvider._();

final class ResourcesNotifierProvider
    extends $AsyncNotifierProvider<ResourcesNotifier, List<LocalResource>> {
  const ResourcesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resourcesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resourcesNotifierHash();

  @$internal
  @override
  ResourcesNotifier create() => ResourcesNotifier();
}

String _$resourcesNotifierHash() => r'4989c2598114c7a75b0a0b6f3c3b38d0d3acdf6e';

abstract class _$ResourcesNotifier extends $AsyncNotifier<List<LocalResource>> {
  FutureOr<List<LocalResource>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<LocalResource>>, List<LocalResource>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<LocalResource>>, List<LocalResource>>,
              AsyncValue<List<LocalResource>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(resourceById)
const resourceByIdProvider = ResourceByIdFamily._();

final class ResourceByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<LocalResource?>,
          LocalResource?,
          FutureOr<LocalResource?>
        >
    with $FutureModifier<LocalResource?>, $FutureProvider<LocalResource?> {
  const ResourceByIdProvider._({
    required ResourceByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'resourceByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$resourceByIdHash();

  @override
  String toString() {
    return r'resourceByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LocalResource?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LocalResource?> create(Ref ref) {
    final argument = this.argument as String;
    return resourceById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ResourceByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$resourceByIdHash() => r'6bb3ea0c20f175c4e49ed11d600d7d03346c4b1d';

final class ResourceByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LocalResource?>, String> {
  const ResourceByIdFamily._()
    : super(
        retry: null,
        name: r'resourceByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ResourceByIdProvider call(String id) =>
      ResourceByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'resourceByIdProvider';
}
