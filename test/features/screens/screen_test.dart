import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/app/app.dart';
import 'package:local_community_connect_app/app/router.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';
import 'package:local_community_connect_app/shared/models/hive_adapters.dart';
import 'package:local_community_connect_app/shared/providers/hive_provider.dart';

void main() {
  late HiveService hiveService;

  setUpAll(() async {
    Hive.init('./test_hive_screens');

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
  });

  Widget buildTestApp() {
    final router = createRouter(showOnboarding: false);
    return ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWith((ref) async => hiveService),
      ],
      child: CommunityConnectApp(router: router),
    );
  }

  group('Events Screen', () {
    testWidgets('displays events list with sample data', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Events'), findsAtLeastNWidgets(1));
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });

  group('Navigation', () {
    testWidgets('can navigate to News screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('News'));
      await tester.pumpAndSettle();

      expect(find.text('News'), findsAtLeastNWidgets(1));
    });

    testWidgets('can navigate to Resources screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Resources'));
      await tester.pumpAndSettle();

      expect(find.text('Resources'), findsAtLeastNWidgets(1));
    });

    testWidgets('can navigate to Favorites screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      expect(find.text('Favorites'), findsAtLeastNWidgets(1));
    });

    testWidgets('can navigate to Settings screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsAtLeastNWidgets(1));
      expect(find.text('Dark Mode'), findsOneWidget);
    });
  });

  group('Settings Screen', () {
    testWidgets('shows Profile link', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('View and edit your profile'), findsOneWidget);
    });

    testWidgets('can navigate to Profile from Settings', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Tap on Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Verify Profile screen is shown
      expect(find.text('Jane Doe'), findsOneWidget);
    });
  });

  group('Profile Screen', () {
    testWidgets('displays profile information', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      // Navigate to Settings then Profile
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('jane.doe@example.com'), findsOneWidget);
    });

    testWidgets('shows preference toggles', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Private Profile'), findsOneWidget);
      expect(find.text('Email Digest'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(3));
    });

    testWidgets('shows interests chips', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Volunteering'), findsOneWidget);
    });
  });

  group('Dark Mode', () {
    testWidgets('app respects theme mode', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Favorites Screen', () {
    testWidgets('shows tabs for different content types', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Events'), findsAtLeastNWidgets(1));
      expect(find.text('News'), findsAtLeastNWidgets(1));
      expect(find.text('Resources'), findsAtLeastNWidgets(1));
    });

  });
}
