// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchNotifier)
const searchProvider = SearchNotifierFamily._();

final class SearchNotifierProvider
    extends $AsyncNotifierProvider<SearchNotifier, SearchResults> {
  const SearchNotifierProvider._({
    required SearchNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchNotifierHash();

  @override
  String toString() {
    return r'searchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchNotifier create() => SearchNotifier();

  @override
  bool operator ==(Object other) {
    return other is SearchNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchNotifierHash() => r'8ebf9c472b35b7c3ae3fb150370687a12e971fc5';

final class SearchNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchNotifier,
          AsyncValue<SearchResults>,
          SearchResults,
          FutureOr<SearchResults>,
          String
        > {
  const SearchNotifierFamily._()
    : super(
        retry: null,
        name: r'searchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchNotifierProvider call(String query) =>
      SearchNotifierProvider._(argument: query, from: this);

  @override
  String toString() => r'searchProvider';
}

abstract class _$SearchNotifier extends $AsyncNotifier<SearchResults> {
  late final _$args = ref.$arg as String;
  String get query => _$args;

  FutureOr<SearchResults> build(String query);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<SearchResults>, SearchResults>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SearchResults>, SearchResults>,
              AsyncValue<SearchResults>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
