// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NewsNotifier)
const newsProvider = NewsNotifierProvider._();

final class NewsNotifierProvider
    extends $AsyncNotifierProvider<NewsNotifier, List<NewsItem>> {
  const NewsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'newsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$newsNotifierHash();

  @$internal
  @override
  NewsNotifier create() => NewsNotifier();
}

String _$newsNotifierHash() => r'a80e8f15b51493c903e7328ea4561ee3e3cf79bc';

abstract class _$NewsNotifier extends $AsyncNotifier<List<NewsItem>> {
  FutureOr<List<NewsItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<NewsItem>>, List<NewsItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<NewsItem>>, List<NewsItem>>,
              AsyncValue<List<NewsItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(newsById)
const newsByIdProvider = NewsByIdFamily._();

final class NewsByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<NewsItem?>,
          NewsItem?,
          FutureOr<NewsItem?>
        >
    with $FutureModifier<NewsItem?>, $FutureProvider<NewsItem?> {
  const NewsByIdProvider._({
    required NewsByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'newsByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$newsByIdHash();

  @override
  String toString() {
    return r'newsByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<NewsItem?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<NewsItem?> create(Ref ref) {
    final argument = this.argument as String;
    return newsById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NewsByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$newsByIdHash() => r'9c0d770a741b34b5ba4e813d4974ae0e46129d7e';

final class NewsByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<NewsItem?>, String> {
  const NewsByIdFamily._()
    : super(
        retry: null,
        name: r'newsByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NewsByIdProvider call(String id) =>
      NewsByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'newsByIdProvider';
}
