import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/features/profile/providers/profile_provider.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';
import 'package:local_community_connect_app/shared/models/hive_adapters.dart';
import 'package:local_community_connect_app/shared/providers/hive_provider.dart';

void main() {
  late ProviderContainer container;
  late HiveService hiveService;

  setUpAll(() async {
    Hive.init('./test_hive_profile');

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

    if (Hive.isBoxOpen(HiveService.eventsBox)) {
      await Hive.box(HiveService.eventsBox).clear();
    }
    if (Hive.isBoxOpen(HiveService.newsBox)) {
      await Hive.box(HiveService.newsBox).clear();
    }
    if (Hive.isBoxOpen(HiveService.resourcesBox)) {
      await Hive.box(HiveService.resourcesBox).clear();
    }
    if (Hive.isBoxOpen(HiveService.favoritesBox)) {
      await Hive.box(HiveService.favoritesBox).clear();
    }
    if (Hive.isBoxOpen(HiveService.settingsBox)) {
      await Hive.box(HiveService.settingsBox).clear();
    }

    if (!Hive.isBoxOpen(HiveService.eventsBox)) {
      await Hive.openBox(HiveService.eventsBox);
    }
    if (!Hive.isBoxOpen(HiveService.newsBox)) {
      await Hive.openBox(HiveService.newsBox);
    }
    if (!Hive.isBoxOpen(HiveService.resourcesBox)) {
      await Hive.openBox(HiveService.resourcesBox);
    }
    if (!Hive.isBoxOpen(HiveService.favoritesBox)) {
      await Hive.openBox(HiveService.favoritesBox);
    }
    if (!Hive.isBoxOpen(HiveService.settingsBox)) {
      await Hive.openBox(HiveService.settingsBox);
    }

    container = ProviderContainer(
      overrides: [
        hiveServiceProvider.overrideWith((ref) async => hiveService),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Hive.box(HiveService.settingsBox).clear();
    await Hive.box(HiveService.favoritesBox).clear();
  });

  group('ProfileNotifier', () {
    test('loads profile with default preferences', () async {
      await container.read(hiveServiceProvider.future);

      final profileAsync = await container.read(profileProvider.future);

      expect(profileAsync.name, equals('Jane Doe'));
      expect(profileAsync.email, equals('jane.doe@example.com'));
      expect(profileAsync.notificationsEnabled, isTrue);
      expect(profileAsync.privateProfile, isFalse);
      expect(profileAsync.emailDigestEnabled, isTrue);
    });

    test('setNotificationsEnabled updates state and persists', () async {
      await container.read(hiveServiceProvider.future);
      final notifier = container.read(profileProvider.notifier);

      await notifier.setNotificationsEnabled(false);

      final profile = container.read(profileProvider).asData?.value;
      expect(profile?.notificationsEnabled, isFalse);

      // Verify persisted
      expect(hiveService.notificationsEnabled, isFalse);
    });

    test('setPrivateProfile updates state and persists', () async {
      await container.read(hiveServiceProvider.future);
      final notifier = container.read(profileProvider.notifier);

      await notifier.setPrivateProfile(true);

      final profile = container.read(profileProvider).asData?.value;
      expect(profile?.privateProfile, isTrue);

      // Verify persisted
      expect(hiveService.privateProfile, isTrue);
    });

    test('setEmailDigestEnabled updates state and persists', () async {
      await container.read(hiveServiceProvider.future);
      final notifier = container.read(profileProvider.notifier);

      await notifier.setEmailDigestEnabled(false);

      final profile = container.read(profileProvider).asData?.value;
      expect(profile?.emailDigestEnabled, isFalse);

      // Verify persisted
      expect(hiveService.emailDigestEnabled, isFalse);
    });

    test('favoritesCount reflects actual favorites', () async {
      await container.read(hiveServiceProvider.future);

      // Add some favorites
      await hiveService.toggleFavorite('events', 'event-1');
      await hiveService.toggleFavorite('events', 'event-2');
      await hiveService.toggleFavorite('news', 'news-1');

      // Refresh the provider
      container.invalidate(profileProvider);
      final profile = await container.read(profileProvider.future);

      expect(profile.favoritesCount, equals(3));
    });
  });

  group('ProfileData', () {
    test('copyWith creates correct copy', () {
      const original = ProfileData(
        name: 'Test User',
        email: 'test@example.com',
        avatarInitials: 'TU',
        bio: 'Test bio',
        favoritesCount: 5,
        interests: ['Testing'],
        notificationsEnabled: true,
        privateProfile: false,
        emailDigestEnabled: true,
      );

      final copy = original.copyWith(
        notificationsEnabled: false,
        favoritesCount: 10,
      );

      expect(copy.name, equals('Test User'));
      expect(copy.notificationsEnabled, isFalse);
      expect(copy.favoritesCount, equals(10));
      expect(copy.privateProfile, isFalse);
    });
  });
}
