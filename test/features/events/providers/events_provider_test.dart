import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/features/events/providers/events_provider.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';
import 'package:local_community_connect_app/shared/models/hive_adapters.dart';
import 'package:local_community_connect_app/shared/models/models.dart';
import 'package:local_community_connect_app/shared/providers/hive_provider.dart';

void main() {
  late ProviderContainer container;
  late HiveService hiveService;

  setUpAll(() async {
    Hive.init('./test_hive_events');

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

  group('EventsNotifier', () {
    test('loads events sorted by date ascending', () async {
      final laterEvent = Event(
        id: 'event-2',
        title: 'Later Event',
        date: DateTime(2025, 3, 15),
        category: 'Community',
        description: 'Description 2',
      );
      final earlierEvent = Event(
        id: 'event-1',
        title: 'Earlier Event',
        date: DateTime(2025, 1, 10),
        category: 'Arts',
        description: 'Description 1',
      );

      await addEvent(laterEvent);
      await addEvent(earlierEvent);

      final events = await container.read(eventsProvider.future);

      expect(events.length, equals(2));
      expect(events[0].id, equals('event-1'));
      expect(events[1].id, equals('event-2'));
    });

    test('returns empty list when no events exist', () async {
      final events = await container.read(eventsProvider.future);
      expect(events, isEmpty);
    });

    test('filterByCategory returns all events when category is null', () async {
      final communityEvent = Event(
        id: 'community-event',
        title: 'Community Event',
        date: DateTime.now(),
        category: 'Community',
        description: 'Desc',
      );
      final artsEvent = Event(
        id: 'arts-event',
        title: 'Arts Event',
        date: DateTime.now(),
        category: 'Arts',
        description: 'Desc',
      );

      await addEvent(communityEvent);
      await addEvent(artsEvent);

      final notifier = container.read(eventsProvider.notifier);
      final events = await container.read(eventsProvider.future);
      final filtered = notifier.filterByCategory(events, null);

      expect(filtered.length, equals(2));
    });

    test('filterByCategory returns only matching events', () async {
      final communityEvent = Event(
        id: 'community-filter-event',
        title: 'Community Event',
        date: DateTime.now(),
        category: 'Community',
        description: 'Desc',
      );
      final artsEvent = Event(
        id: 'arts-filter-event',
        title: 'Arts Event',
        date: DateTime.now(),
        category: 'Arts',
        description: 'Desc',
      );

      await addEvent(communityEvent);
      await addEvent(artsEvent);

      final notifier = container.read(eventsProvider.notifier);
      final events = await container.read(eventsProvider.future);
      final filtered = notifier.filterByCategory(events, 'Community');

      expect(filtered.length, equals(1));
      expect(filtered[0].category, equals('Community'));
    });

    test('filterByCategory returns empty list for non-matching category',
        () async {
      final communityEvent = Event(
        id: 'community-only-event',
        title: 'Event',
        date: DateTime.now(),
        category: 'Community',
        description: 'Desc',
      );

      await addEvent(communityEvent);

      final notifier = container.read(eventsProvider.notifier);
      final events = await container.read(eventsProvider.future);
      final filtered = notifier.filterByCategory(events, 'NonExistent');

      expect(filtered, isEmpty);
    });
  });

  group('eventCategories', () {
    test('returns predefined list of categories', () {
      final categories = container.read(eventCategoriesProvider);

      expect(categories, contains('Community'));
      expect(categories, contains('Government'));
      expect(categories, contains('Arts'));
      expect(categories, contains('Sports'));
      expect(categories, contains('Health'));
      expect(categories, contains('Education'));
      expect(categories.length, equals(6));
    });
  });

  group('eventById', () {
    test('returns correct event for valid id', () async {
      final event = Event(
        id: 'test-event',
        title: 'Test Event',
        date: DateTime(2025, 6, 15),
        category: 'Community',
        description: 'Test description',
        location: 'Test Location',
      );

      await addEvent(event);

      final result =
          await container.read(eventByIdProvider('test-event').future);

      expect(result, isNotNull);
      expect(result!.id, equals('test-event'));
      expect(result.title, equals('Test Event'));
      expect(result.location, equals('Test Location'));
    });

    test('returns null for non-existent id', () async {
      final result =
          await container.read(eventByIdProvider('non-existent').future);

      expect(result, isNull);
    });

    test('returns event with all optional fields', () async {
      final event = Event(
        id: 'full-event',
        title: 'Full Event',
        date: DateTime(2025, 7, 20),
        category: 'Arts',
        description: 'Full description',
        location: 'Art Gallery',
        imageUrl: 'https://example.com/image.jpg',
      );

      await addEvent(event);

      final result =
          await container.read(eventByIdProvider('full-event').future);

      expect(result, isNotNull);
      expect(result!.location, equals('Art Gallery'));
      expect(result.imageUrl, equals('https://example.com/image.jpg'));
    });
  });
}
