import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';
import 'package:local_community_connect_app/shared/models/hive_adapters.dart';
import 'package:local_community_connect_app/shared/providers/hive_provider.dart';
import 'package:local_community_connect_app/shared/providers/theme_provider.dart';

void main() {
  late ProviderContainer container;
  late HiveService hiveService;

  setUpAll(() async {
    Hive.init('./test_hive_theme');

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

    for (final boxName in [
      HiveService.eventsBox,
      HiveService.newsBox,
      HiveService.resourcesBox,
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
    for (final boxName in [
      HiveService.eventsBox,
      HiveService.newsBox,
      HiveService.resourcesBox,
      HiveService.favoritesBox,
      HiveService.settingsBox,
    ]) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      }
    }
  });

  group('ThemeNotifier', () {
    test('defaults to light mode when no preference stored', () async {
      // Wait for hive to be ready
      await container.read(hiveServiceProvider.future);

      // Give the provider time to build
      await Future.delayed(const Duration(milliseconds: 100));

      final themeMode = container.read(themeProvider);

      expect(themeMode, equals(ThemeMode.light));
    });

    test('respects stored dark mode preference', () async {
      await hiveService.setDarkMode(true);

      // Create a new container to test initial load
      final newContainer = ProviderContainer(
        overrides: [
          hiveServiceProvider.overrideWith((ref) async => hiveService),
        ],
      );

      await newContainer.read(hiveServiceProvider.future);
      await Future.delayed(const Duration(milliseconds: 100));

      final themeMode = newContainer.read(themeProvider);

      expect(themeMode, equals(ThemeMode.dark));

      newContainer.dispose();
    });

    test('toggle switches from light to dark', () async {
      await container.read(hiveServiceProvider.future);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(themeProvider), equals(ThemeMode.light));

      await container.read(themeProvider.notifier).toggle();

      expect(container.read(themeProvider), equals(ThemeMode.dark));
    });

    test('toggle switches from dark to light', () async {
      await hiveService.setDarkMode(true);
      await container.read(hiveServiceProvider.future);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(themeProvider), equals(ThemeMode.dark));

      await container.read(themeProvider.notifier).toggle();

      expect(container.read(themeProvider), equals(ThemeMode.light));
    });

    test('toggle persists preference to Hive', () async {
      await container.read(hiveServiceProvider.future);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(hiveService.isDarkMode, isFalse);

      await container.read(themeProvider.notifier).toggle();

      expect(hiveService.isDarkMode, isTrue);
    });

    test('multiple toggles work correctly', () async {
      await container.read(hiveServiceProvider.future);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(themeProvider), equals(ThemeMode.light));

      await container.read(themeProvider.notifier).toggle();
      expect(container.read(themeProvider), equals(ThemeMode.dark));

      await container.read(themeProvider.notifier).toggle();
      expect(container.read(themeProvider), equals(ThemeMode.light));

      await container.read(themeProvider.notifier).toggle();
      expect(container.read(themeProvider), equals(ThemeMode.dark));
    });

    test('theme state is maintained across provider reads', () async {
      await container.read(hiveServiceProvider.future);
      await Future.delayed(const Duration(milliseconds: 100));

      await container.read(themeProvider.notifier).toggle();

      // Multiple reads should return same value
      final read1 = container.read(themeProvider);
      final read2 = container.read(themeProvider);
      final read3 = container.read(themeProvider);

      expect(read1, equals(ThemeMode.dark));
      expect(read2, equals(ThemeMode.dark));
      expect(read3, equals(ThemeMode.dark));
    });
  });
}
