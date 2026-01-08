import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/features/resources/providers/resources_provider.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';
import 'package:local_community_connect_app/shared/models/hive_adapters.dart';
import 'package:local_community_connect_app/shared/models/models.dart';
import 'package:local_community_connect_app/shared/providers/hive_provider.dart';

void main() {
  late ProviderContainer container;
  late HiveService hiveService;

  setUpAll(() async {
    Hive.init('./test_hive_resources');

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

  Future<void> addResource(LocalResource resource) async {
    final box = Hive.box<LocalResource>(HiveService.resourcesBox);
    await box.put(resource.id, resource);
  }

  group('ResourcesNotifier', () {
    test('loads resources sorted by name alphabetically', () async {
      final resourceZ = LocalResource(
        id: 'res-z',
        name: 'Zebra Center',
        category: 'Services',
      );
      final resourceA = LocalResource(
        id: 'res-a',
        name: 'Apple Library',
        category: 'Education',
      );

      await addResource(resourceZ);
      await addResource(resourceA);

      final resources = await container.read(resourcesProvider.future);

      expect(resources.length, equals(2));
      expect(resources[0].name, equals('Apple Library'));
      expect(resources[1].name, equals('Zebra Center'));
    });

    test('returns empty list when no resources exist', () async {
      final resources = await container.read(resourcesProvider.future);
      expect(resources, isEmpty);
    });

    test('groupByCategory groups resources correctly', () async {
      final healthResource = LocalResource(
        id: 'r1',
        name: 'Health Clinic',
        category: 'Health',
      );
      final educationResource1 = LocalResource(
        id: 'r2',
        name: 'Public Library',
        category: 'Education',
      );
      final educationResource2 = LocalResource(
        id: 'r3',
        name: 'Community College',
        category: 'Education',
      );

      await addResource(healthResource);
      await addResource(educationResource1);
      await addResource(educationResource2);

      final notifier = container.read(resourcesProvider.notifier);
      final resources = await container.read(resourcesProvider.future);
      final grouped = notifier.groupByCategory(resources);

      expect(grouped.keys, contains('Health'));
      expect(grouped.keys, contains('Education'));
      expect(grouped['Health']!.length, equals(1));
      expect(grouped['Education']!.length, equals(2));
    });

    test('groupByCategory returns empty map for empty list', () async {
      final notifier = container.read(resourcesProvider.notifier);
      final grouped = notifier.groupByCategory([]);

      expect(grouped, isEmpty);
    });

    test('groupByCategory handles single category', () async {
      final resource1 = LocalResource(
        id: 'r1',
        name: 'Resource 1',
        category: 'Services',
      );
      final resource2 = LocalResource(
        id: 'r2',
        name: 'Resource 2',
        category: 'Services',
      );

      await addResource(resource1);
      await addResource(resource2);

      final notifier = container.read(resourcesProvider.notifier);
      final resources = await container.read(resourcesProvider.future);
      final grouped = notifier.groupByCategory(resources);

      expect(grouped.keys.length, equals(1));
      expect(grouped['Services']!.length, equals(2));
    });

    test('loads resources with all optional fields', () async {
      final fullResource = LocalResource(
        id: 'full-res',
        name: 'Full Resource',
        category: 'Services',
        address: '123 Main St',
        phoneNumber: '555-1234',
        websiteUrl: 'https://example.com',
        description: 'A complete resource entry',
      );

      await addResource(fullResource);

      final resources = await container.read(resourcesProvider.future);

      expect(resources.length, equals(1));
      expect(resources[0].address, equals('123 Main St'));
      expect(resources[0].phoneNumber, equals('555-1234'));
      expect(resources[0].websiteUrl, equals('https://example.com'));
      expect(resources[0].description, equals('A complete resource entry'));
    });
  });

  group('resourceById', () {
    test('returns correct resource for valid id', () async {
      final resource = LocalResource(
        id: 'test-resource',
        name: 'Test Resource',
        category: 'Health',
        address: '456 Oak Ave',
      );

      await addResource(resource);

      final result =
          await container.read(resourceByIdProvider('test-resource').future);

      expect(result, isNotNull);
      expect(result!.id, equals('test-resource'));
      expect(result.name, equals('Test Resource'));
      expect(result.address, equals('456 Oak Ave'));
    });

    test('returns null for non-existent id', () async {
      final result =
          await container.read(resourceByIdProvider('non-existent').future);

      expect(result, isNull);
    });

    test('returns resource with minimal fields', () async {
      final resource = LocalResource(
        id: 'minimal',
        name: 'Minimal Resource',
        category: 'Other',
      );

      await addResource(resource);

      final result =
          await container.read(resourceByIdProvider('minimal').future);

      expect(result, isNotNull);
      expect(result!.address, isNull);
      expect(result.phoneNumber, isNull);
      expect(result.websiteUrl, isNull);
      expect(result.description, isNull);
    });
  });
}
