import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/features/search/providers/search_provider.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';
import 'package:local_community_connect_app/shared/models/hive_adapters.dart';
import 'package:local_community_connect_app/shared/models/models.dart';
import 'package:local_community_connect_app/shared/providers/hive_provider.dart';

void main() {
  late ProviderContainer container;
  late HiveService hiveService;

  setUpAll(() async {
    Hive.init('./test_hive_search');

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

    // Open typed boxes for model storage
    if (Hive.isBoxOpen(HiveService.eventsBox)) {
      await Hive.box<Event>(HiveService.eventsBox).clear();
    } else {
      await Hive.openBox<Event>(HiveService.eventsBox);
    }
    if (Hive.isBoxOpen(HiveService.newsBox)) {
      await Hive.box<NewsItem>(HiveService.newsBox).clear();
    } else {
      await Hive.openBox<NewsItem>(HiveService.newsBox);
    }
    if (Hive.isBoxOpen(HiveService.resourcesBox)) {
      await Hive.box<LocalResource>(HiveService.resourcesBox).clear();
    } else {
      await Hive.openBox<LocalResource>(HiveService.resourcesBox);
    }

    // Dynamic boxes for favorites and settings
    for (final boxName in [
      HiveService.favoritesBox,
      HiveService.settingsBox,
    ]) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      } else {
        await Hive.openBox(boxName);
      }
    }

    container = ProviderContainer(
      overrides: [
        hiveServiceProvider.overrideWith((ref) async => hiveService),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    if (Hive.isBoxOpen(HiveService.eventsBox)) {
      await Hive.box<Event>(HiveService.eventsBox).clear();
    }
    if (Hive.isBoxOpen(HiveService.newsBox)) {
      await Hive.box<NewsItem>(HiveService.newsBox).clear();
    }
    if (Hive.isBoxOpen(HiveService.resourcesBox)) {
      await Hive.box<LocalResource>(HiveService.resourcesBox).clear();
    }
    if (Hive.isBoxOpen(HiveService.favoritesBox)) {
      await Hive.box(HiveService.favoritesBox).clear();
    }
    if (Hive.isBoxOpen(HiveService.settingsBox)) {
      await Hive.box(HiveService.settingsBox).clear();
    }
  });

  Future<void> addEvent(Event event) async {
    final box = Hive.box<Event>(HiveService.eventsBox);
    await box.put(event.id, event);
  }

  Future<void> addNewsItem(NewsItem item) async {
    final box = Hive.box<NewsItem>(HiveService.newsBox);
    await box.put(item.id, item);
  }

  Future<void> addResource(LocalResource resource) async {
    final box = Hive.box<LocalResource>(HiveService.resourcesBox);
    await box.put(resource.id, resource);
  }

  Future<void> seedTestData() async {
    await addEvent(Event(
      id: 'event-1',
      title: 'Community Festival',
      date: DateTime(2025, 6, 15),
      category: 'Community',
      description: 'Annual summer celebration',
      location: 'Central Park',
    ));
    await addEvent(Event(
      id: 'event-2',
      title: 'Art Exhibition',
      date: DateTime(2025, 7, 20),
      category: 'Arts',
      description: 'Local artists showcase',
      location: 'Gallery Downtown',
    ));

    await addNewsItem(NewsItem(
      id: 'news-1',
      title: 'New Library Opens',
      summary: 'A state-of-the-art library opens downtown',
      content: 'The community celebrates the opening of a new public library.',
      publishedDate: DateTime(2025, 5, 10),
    ));
    await addNewsItem(NewsItem(
      id: 'news-2',
      title: 'Park Renovation Complete',
      summary: 'Central Park renovation finished',
      publishedDate: DateTime(2025, 5, 15),
    ));

    await addResource(LocalResource(
      id: 'resource-1',
      name: 'City Library',
      category: 'Education',
      address: '100 Main Street',
      description: 'Public library with free wifi',
    ));
    await addResource(LocalResource(
      id: 'resource-2',
      name: 'Health Clinic',
      category: 'Health',
      address: '200 Oak Avenue',
    ));
  }

  group('SearchResults', () {
    test('isEmpty returns true when all lists are empty', () {
      final results = SearchResults(events: [], news: [], resources: []);
      expect(results.isEmpty, isTrue);
    });

    test('isEmpty returns false when events are present', () {
      final results = SearchResults(
        events: [
          Event(
            id: 'e1',
            title: 'Test',
            date: DateTime.now(),
            category: 'Test',
            description: 'Test',
          )
        ],
        news: [],
        resources: [],
      );
      expect(results.isEmpty, isFalse);
    });

    test('isEmpty returns false when news is present', () {
      final results = SearchResults(
        events: [],
        news: [
          NewsItem(
            id: 'n1',
            title: 'Test',
            summary: 'Test',
            publishedDate: DateTime.now(),
          )
        ],
        resources: [],
      );
      expect(results.isEmpty, isFalse);
    });

    test('isEmpty returns false when resources are present', () {
      final results = SearchResults(
        events: [],
        news: [],
        resources: [LocalResource(id: 'r1', name: 'Test', category: 'Test')],
      );
      expect(results.isEmpty, isFalse);
    });
  });

  group('SearchNotifier', () {
    test('empty query returns empty results', () async {
      await seedTestData();

      final results = await container.read(searchProvider('').future);

      expect(results.isEmpty, isTrue);
      expect(results.events, isEmpty);
      expect(results.news, isEmpty);
      expect(results.resources, isEmpty);
    });

    test('finds events by title', () async {
      await seedTestData();

      final results = await container.read(searchProvider('Festival').future);

      expect(results.events.length, equals(1));
      expect(results.events[0].title, contains('Festival'));
    });

    test('finds events by description', () async {
      await seedTestData();

      final results =
          await container.read(searchProvider('summer celebration').future);

      expect(results.events.length, equals(1));
      expect(results.events[0].id, equals('event-1'));
    });

    test('finds events by category', () async {
      await seedTestData();

      final results = await container.read(searchProvider('Arts').future);

      expect(results.events.length, equals(1));
      expect(results.events[0].category, equals('Arts'));
    });

    test('finds events by location', () async {
      await seedTestData();

      final results =
          await container.read(searchProvider('Central Park').future);

      expect(results.events.length, equals(1));
      expect(results.events[0].location, equals('Central Park'));
    });

    test('finds news by title', () async {
      await seedTestData();

      final results = await container.read(searchProvider('Library').future);

      expect(results.news.length, equals(1));
      expect(results.news[0].title, contains('Library'));
    });

    test('finds news by summary', () async {
      await seedTestData();

      final results =
          await container.read(searchProvider('state-of-the-art').future);

      expect(results.news.length, equals(1));
      expect(results.news[0].id, equals('news-1'));
    });

    test('finds news by content', () async {
      await seedTestData();

      final results =
          await container.read(searchProvider('public library').future);

      expect(results.news.length, equals(1));
      expect(results.news[0].id, equals('news-1'));
    });

    test('finds resources by name', () async {
      await seedTestData();

      final results = await container.read(searchProvider('Clinic').future);

      expect(results.resources.length, equals(1));
      expect(results.resources[0].name, contains('Clinic'));
    });

    test('finds resources by category', () async {
      await seedTestData();

      final results = await container.read(searchProvider('Education').future);

      expect(results.resources.length, equals(1));
      expect(results.resources[0].category, equals('Education'));
    });

    test('finds resources by address', () async {
      await seedTestData();

      final results =
          await container.read(searchProvider('Oak Avenue').future);

      expect(results.resources.length, equals(1));
      expect(results.resources[0].address, contains('Oak'));
    });

    test('finds resources by description', () async {
      await seedTestData();

      final results = await container.read(searchProvider('free wifi').future);

      expect(results.resources.length, equals(1));
      expect(results.resources[0].id, equals('resource-1'));
    });

    test('search is case insensitive', () async {
      await seedTestData();

      final upperResults =
          await container.read(searchProvider('FESTIVAL').future);
      final lowerResults =
          await container.read(searchProvider('festival').future);
      final mixedResults =
          await container.read(searchProvider('FeStIvAl').future);

      expect(upperResults.events.length, equals(1));
      expect(lowerResults.events.length, equals(1));
      expect(mixedResults.events.length, equals(1));
    });

    test('finds results across multiple content types', () async {
      await seedTestData();

      final results = await container.read(searchProvider('Library').future);

      expect(results.news.length, equals(1));
      expect(results.resources.length, equals(1));
    });

    test('partial word matching works', () async {
      await seedTestData();

      final results = await container.read(searchProvider('Fest').future);

      expect(results.events.length, equals(1));
    });

    test('returns empty results for no matches', () async {
      await seedTestData();

      final results =
          await container.read(searchProvider('xyz123nonexistent').future);

      expect(results.isEmpty, isTrue);
    });

    test('handles special characters in query', () async {
      await seedTestData();

      final results = await container.read(searchProvider('100 Main').future);

      expect(results.resources.length, equals(1));
    });

    test('multiple search terms work (partial match)', () async {
      await seedTestData();

      final results =
          await container.read(searchProvider('Central Park').future);

      expect(results.events.isNotEmpty || results.news.isNotEmpty, isTrue);
    });
  });
}
