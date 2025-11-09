// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoritesNotifier)
const favoritesProvider = FavoritesNotifierProvider._();

final class FavoritesNotifierProvider
    extends
        $NotifierProvider<FavoritesNotifier, Map<FavoriteType, Set<String>>> {
  const FavoritesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesNotifierHash();

  @$internal
  @override
  FavoritesNotifier create() => FavoritesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<FavoriteType, Set<String>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<FavoriteType, Set<String>>>(
        value,
      ),
    );
  }
}

String _$favoritesNotifierHash() => r'812deede1cca4dfecf0ec932e5b3e26fa3fa3f8d';

abstract class _$FavoritesNotifier
    extends $Notifier<Map<FavoriteType, Set<String>>> {
  Map<FavoriteType, Set<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              Map<FavoriteType, Set<String>>,
              Map<FavoriteType, Set<String>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<FavoriteType, Set<String>>,
                Map<FavoriteType, Set<String>>
              >,
              Map<FavoriteType, Set<String>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
