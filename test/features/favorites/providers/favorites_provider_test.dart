import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/features/favorites/providers/favorites_provider.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';
import 'package:local_community_connect_app/shared/models/hive_adapters.dart';
import 'package:local_community_connect_app/shared/providers/hive_provider.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    // Initialize Hive with a temp directory for testing
    Hive.init('./test_hive_provider');

    // Register adapters manually for testing
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EventAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NewsItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(LocalResourceAdapter());
    }
  });

  setUp(() async {
    // Create a fresh HiveService instance
    final hiveService = HiveService();

    // Clear any existing boxes
    if (Hive.isBoxOpen(HiveService.eventsBox)) await Hive.box(HiveService.eventsBox).clear();
    if (Hive.isBoxOpen(HiveService.newsBox)) await Hive.box(HiveService.newsBox).clear();
    if (Hive.isBoxOpen(HiveService.resourcesBox)) await Hive.box(HiveService.resourcesBox).clear();
    if (Hive.isBoxOpen(HiveService.favoritesBox)) await Hive.box(HiveService.favoritesBox).clear();
    if (Hive.isBoxOpen(HiveService.settingsBox)) await Hive.box(HiveService.settingsBox).clear();

    // Open boxes directly instead of calling init() which uses initFlutter
    if (!Hive.isBoxOpen(HiveService.eventsBox)) await Hive.openBox(HiveService.eventsBox);
    if (!Hive.isBoxOpen(HiveService.newsBox)) await Hive.openBox(HiveService.newsBox);
    if (!Hive.isBoxOpen(HiveService.resourcesBox)) await Hive.openBox(HiveService.resourcesBox);
    if (!Hive.isBoxOpen(HiveService.favoritesBox)) await Hive.openBox(HiveService.favoritesBox);
    if (!Hive.isBoxOpen(HiveService.settingsBox)) await Hive.openBox(HiveService.settingsBox);

    // Create ProviderContainer with override
    container = ProviderContainer(
      overrides: [
        hiveServiceProvider.overrideWith((ref) async => hiveService),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    // Clear boxes but don't close them
    await Hive.box(HiveService.favoritesBox).clear();
  });

  group('FavoritesNotifier', () {
    test('initial state has empty sets for all types', () async {
      // Wait for async initialization
      await container.read(hiveServiceProvider.future);

      final favorites = container.read(favoritesProvider);

      expect(favorites[FavoriteType.events], isEmpty);
      expect(favorites[FavoriteType.news], isEmpty);
      expect(favorites[FavoriteType.resources], isEmpty);
    });

    test('toggle adds and removes favorites', () async {
      await container.read(hiveServiceProvider.future);
      final notifier = container.read(favoritesProvider.notifier);

      await notifier.toggle(FavoriteType.events, 'event-1');
      expect(
        container.read(favoritesProvider)[FavoriteType.events],
        contains('event-1'),
      );

      await notifier.toggle(FavoriteType.events, 'event-1');
      expect(
        container.read(favoritesProvider)[FavoriteType.events],
        isNot(contains('event-1')),
      );
    });

    test('isFavorite returns correct state', () async {
      await container.read(hiveServiceProvider.future);
      final notifier = container.read(favoritesProvider.notifier);

      expect(notifier.isFavorite(FavoriteType.news, 'news-1'), isFalse);

      await notifier.toggle(FavoriteType.news, 'news-1');
      expect(notifier.isFavorite(FavoriteType.news, 'news-1'), isTrue);
    });
  });
}
