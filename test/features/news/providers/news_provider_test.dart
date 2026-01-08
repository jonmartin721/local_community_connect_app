import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/features/news/providers/news_provider.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';
import 'package:local_community_connect_app/shared/models/hive_adapters.dart';
import 'package:local_community_connect_app/shared/models/models.dart';
import 'package:local_community_connect_app/shared/providers/hive_provider.dart';

void main() {
  late ProviderContainer container;
  late HiveService hiveService;

  setUpAll(() async {
    Hive.init('./test_hive_news');

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

  Future<void> addNewsItem(NewsItem item) async {
    final box = Hive.box<NewsItem>(HiveService.newsBox);
    await box.put(item.id, item);
  }

  group('NewsNotifier', () {
    test('loads news sorted by published date descending (newest first)',
        () async {
      final olderNews = NewsItem(
        id: 'news-1',
        title: 'Older News',
        summary: 'Summary 1',
        publishedDate: DateTime(2025, 1, 10),
      );
      final newerNews = NewsItem(
        id: 'news-2',
        title: 'Newer News',
        summary: 'Summary 2',
        publishedDate: DateTime(2025, 3, 15),
      );

      await addNewsItem(olderNews);
      await addNewsItem(newerNews);

      final news = await container.read(newsProvider.future);

      expect(news.length, equals(2));
      expect(news[0].id, equals('news-2'));
      expect(news[1].id, equals('news-1'));
    });

    test('returns empty list when no news exists', () async {
      final news = await container.read(newsProvider.future);
      expect(news, isEmpty);
    });

    test('loads news with all fields populated', () async {
      final newsItem = NewsItem(
        id: 'full-news',
        title: 'Full News Article',
        summary: 'This is the summary',
        content: 'This is the full content of the article.',
        publishedDate: DateTime(2025, 5, 20),
        imageUrl: 'https://example.com/news-image.jpg',
      );

      await addNewsItem(newsItem);

      final news = await container.read(newsProvider.future);

      expect(news.length, equals(1));
      expect(
          news[0].content, equals('This is the full content of the article.'));
      expect(news[0].imageUrl, equals('https://example.com/news-image.jpg'));
    });

    test('handles multiple news items with same date', () async {
      final sameDate = DateTime(2025, 2, 14);
      final news1 = NewsItem(
        id: 'news-a',
        title: 'News A',
        summary: 'Summary A',
        publishedDate: sameDate,
      );
      final news2 = NewsItem(
        id: 'news-b',
        title: 'News B',
        summary: 'Summary B',
        publishedDate: sameDate,
      );

      await addNewsItem(news1);
      await addNewsItem(news2);

      final news = await container.read(newsProvider.future);

      expect(news.length, equals(2));
    });
  });

  group('newsById', () {
    test('returns correct news item for valid id', () async {
      final newsItem = NewsItem(
        id: 'test-news',
        title: 'Test News',
        summary: 'Test summary',
        publishedDate: DateTime(2025, 6, 15),
      );

      await addNewsItem(newsItem);

      final result = await container.read(newsByIdProvider('test-news').future);

      expect(result, isNotNull);
      expect(result!.id, equals('test-news'));
      expect(result.title, equals('Test News'));
    });

    test('returns null for non-existent id', () async {
      final result =
          await container.read(newsByIdProvider('non-existent').future);

      expect(result, isNull);
    });

    test('returns news item with optional content field', () async {
      final newsItem = NewsItem(
        id: 'content-news',
        title: 'News With Content',
        summary: 'Summary',
        content: 'Full article content here with lots of details.',
        publishedDate: DateTime(2025, 7, 20),
      );

      await addNewsItem(newsItem);

      final result =
          await container.read(newsByIdProvider('content-news').future);

      expect(result, isNotNull);
      expect(result!.content, contains('Full article content'));
    });

    test('handles news item without optional fields', () async {
      final newsItem = NewsItem(
        id: 'minimal-news',
        title: 'Minimal News',
        summary: 'Just a summary',
        publishedDate: DateTime(2025, 8, 1),
      );

      await addNewsItem(newsItem);

      final result =
          await container.read(newsByIdProvider('minimal-news').future);

      expect(result, isNotNull);
      expect(result!.content, isNull);
      expect(result.imageUrl, isNull);
    });
  });
}
