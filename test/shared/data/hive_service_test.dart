import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';
import 'package:local_community_connect_app/shared/models/hive_adapters.dart';

void main() {
  late HiveService hiveService;

  setUpAll(() async {
    // Initialize Hive with a temp directory for testing
    Hive.init('./test_hive');

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
    hiveService = HiveService();

    // Delete any existing data first
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
  });

  tearDown(() async {
    // Just clear the boxes, don't close them
    await Hive.box(HiveService.favoritesBox).clear();
  });

  group('HiveService Favorites', () {
    test('getFavoriteIds returns empty set when no favorites exist', () {
      final favorites = hiveService.getFavoriteIds('events');
      expect(favorites, isEmpty);
    });

    test('toggleFavorite adds an id to favorites', () async {
      await hiveService.toggleFavorite('events', 'event-1');

      final favorites = hiveService.getFavoriteIds('events');
      expect(favorites, contains('event-1'));
    });

    test('toggleFavorite removes an id when called twice', () async {
      await hiveService.toggleFavorite('events', 'event-1');
      await hiveService.toggleFavorite('events', 'event-1');

      final favorites = hiveService.getFavoriteIds('events');
      expect(favorites, isNot(contains('event-1')));
    });

    test('favorites are isolated by type', () async {
      await hiveService.toggleFavorite('events', 'id-1');
      await hiveService.toggleFavorite('news', 'id-2');

      final eventFavorites = hiveService.getFavoriteIds('events');
      final newsFavorites = hiveService.getFavoriteIds('news');

      expect(eventFavorites, contains('id-1'));
      expect(eventFavorites, isNot(contains('id-2')));
      expect(newsFavorites, contains('id-2'));
      expect(newsFavorites, isNot(contains('id-1')));
    });
  });
}
