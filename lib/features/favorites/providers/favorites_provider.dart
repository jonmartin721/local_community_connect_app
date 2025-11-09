import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/providers/hive_provider.dart';

part 'favorites_provider.g.dart';

enum FavoriteType { events, news, resources }

@Riverpod(keepAlive: true)
class FavoritesNotifier extends _$FavoritesNotifier {
  @override
  Map<FavoriteType, Set<String>> build() {
    final hiveAsync = ref.watch(hiveServiceProvider);
    return hiveAsync.when(
      data: (hive) => {
        FavoriteType.events: hive.getFavoriteIds('events'),
        FavoriteType.news: hive.getFavoriteIds('news'),
        FavoriteType.resources: hive.getFavoriteIds('resources'),
      },
      loading: () => {for (final type in FavoriteType.values) type: {}},
      error: (_, __) => {for (final type in FavoriteType.values) type: {}},
    );
  }

  Future<void> toggle(FavoriteType type, String id) async {
    final hive = await ref.read(hiveServiceProvider.future);
    final typeKey = type.name;
    await hive.toggleFavorite(typeKey, id);

    final current = Map<FavoriteType, Set<String>>.from(state);
    final set = Set<String>.from(current[type]!);
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    current[type] = set;
    state = current;
  }

  bool isFavorite(FavoriteType type, String id) {
    return state[type]?.contains(id) ?? false;
  }
}
