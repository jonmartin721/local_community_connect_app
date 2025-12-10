# Portfolio Cleanup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Clean up the codebase for portfolio readiness by removing dead code, fixing analyzer warnings, resolving TODOs, and adding essential test coverage.

**Architecture:** No architectural changes. This is a cleanup pass that removes unused code, consolidates patterns where beneficial, and adds tests to demonstrate code quality. All changes should preserve existing behavior.

**Tech Stack:** Flutter 3.7+, Riverpod, Hive, flutter_test

---

## Phase 1: Remove Dead Code

### Task 1: Delete Unused ErrorView Widget

**Files:**
- Delete: `lib/shared/widgets/error_view.dart`

**Step 1: Verify ErrorView is unused**

Run: `grep -r "ErrorView" lib/`
Expected: No matches (only the class definition itself)

**Step 2: Delete the file**

```bash
rm lib/shared/widgets/error_view.dart
```

**Step 3: Verify app still builds**

Run: `flutter analyze`
Expected: No new errors related to ErrorView

**Step 4: Commit**

```bash
git add -A && git commit -m "chore: remove unused ErrorView widget"
```

---

### Task 2: Delete Unused NewsCard Shared Widget

**Files:**
- Delete: `lib/shared/widgets/news_card.dart`

**Step 1: Verify NewsCard shared widget is unused**

Run: `grep -r "import.*news_card" lib/`
Expected: No matches

**Step 2: Delete the file**

```bash
rm lib/shared/widgets/news_card.dart
```

**Step 3: Verify app still builds**

Run: `flutter analyze`
Expected: No new errors related to NewsCard import

**Step 4: Commit**

```bash
git add -A && git commit -m "chore: remove unused shared NewsCard widget

Each screen uses its own inline _NewsCard tailored to its context."
```

---

## Phase 2: Fix Analyzer Warnings

### Task 3: Remove Unused Imports in ProfileScreen

**Files:**
- Modify: `lib/features/profile/screens/profile_screen.dart:3,6`

**Step 1: Read the current imports**

Verify lines 3 and 6 contain:
```dart
import 'package:go_router/go_router.dart';
import '../../../shared/providers/providers.dart';
```

**Step 2: Remove the unused imports**

Delete line 3 (`go_router`) and line 6 (`providers.dart`).

**Step 3: Verify analyzer is happy**

Run: `flutter analyze lib/features/profile/`
Expected: No warnings about unused imports

**Step 4: Commit**

```bash
git add lib/features/profile/screens/profile_screen.dart
git commit -m "chore: remove unused imports in ProfileScreen"
```

---

### Task 4: Fix Deprecated RadioListTile in LocationSetupScreen

**Files:**
- Modify: `lib/features/settings/screens/location_setup_screen.dart:129-130`

**Step 1: Read the current implementation**

Find the RadioListTile usage around lines 129-130 with deprecated `groupValue` and `onChanged`.

**Step 2: Update to use Radio with RadioGroup or keep RadioListTile with suppression**

For now, wrap with a `// ignore: deprecated_member_use` comment since Flutter's RadioGroup API is still evolving:

```dart
// ignore: deprecated_member_use
groupValue: _selectedIndex,
// ignore: deprecated_member_use
onChanged: (int? value) {
```

**Step 3: Verify analyzer passes**

Run: `flutter analyze lib/features/settings/`
Expected: No deprecated_member_use warnings

**Step 4: Commit**

```bash
git add lib/features/settings/screens/location_setup_screen.dart
git commit -m "chore: suppress deprecated RadioListTile warnings

Flutter's RadioGroup replacement API is still maturing."
```

---

### Task 5: Fix Unnecessary Import in SettingsScreen

**Files:**
- Modify: `lib/features/settings/screens/settings_screen.dart:6`

**Step 1: Read the imports**

Line 6 imports `theme_provider.dart` but line 7 imports `providers.dart` which re-exports it.

**Step 2: Remove the redundant import**

Delete line 6:
```dart
import '../../../shared/providers/theme_provider.dart';
```

**Step 3: Verify analyzer passes**

Run: `flutter analyze lib/features/settings/`
Expected: No unnecessary_import warning

**Step 4: Commit**

```bash
git add lib/features/settings/screens/settings_screen.dart
git commit -m "chore: remove redundant import in SettingsScreen"
```

---

## Phase 3: Clean Up Settings TODOs

### Task 6: Remove Unimplemented Notification Settings

**Files:**
- Modify: `lib/features/settings/screens/settings_screen.dart:116-153`

**Step 1: Remove the entire Notifications section**

Delete the `_SettingsSection` for "Notifications" (lines ~116-153) which contains unimplemented TODO toggles.

**Step 2: Verify the app builds**

Run: `flutter analyze`
Expected: Clean

**Step 3: Run the app and verify Settings screen renders**

Run: `flutter run -d chrome` (or device)
Navigate to Settings tab, verify it displays without Notifications section.

**Step 4: Commit**

```bash
git add lib/features/settings/screens/settings_screen.dart
git commit -m "chore: remove unimplemented Notifications settings section

Will add back when notification infrastructure is built."
```

---

### Task 7: Remove Unimplemented About Links

**Files:**
- Modify: `lib/features/settings/screens/settings_screen.dart`

**Step 1: Remove Terms of Service and Privacy Policy tiles**

In the "About" section, remove the two tiles with TODO comments:
- "Terms of Service" tile
- "Privacy Policy" tile

Keep only the "Version" tile.

**Step 2: Verify the app builds**

Run: `flutter analyze`
Expected: Clean

**Step 3: Commit**

```bash
git add lib/features/settings/screens/settings_screen.dart
git commit -m "chore: remove unimplemented Terms/Privacy links

Will add back when legal pages exist."
```

---

### Task 8: Remove Unimplemented Language Dialog

**Files:**
- Modify: `lib/features/settings/screens/settings_screen.dart`

**Step 1: Remove the Language section and related code**

Remove:
1. The "Language" `_SettingsSection`
2. The `_showLanguageDialog` method
3. The `_LanguageOption` class

**Step 2: Verify the app builds**

Run: `flutter analyze`
Expected: Clean, no unused code warnings

**Step 3: Commit**

```bash
git add lib/features/settings/screens/settings_screen.dart
git commit -m "chore: remove unimplemented Language settings

Will add i18n support in a future iteration."
```

---

## Phase 4: Add Essential Tests

### Task 9: Add HiveService Favorites Tests

**Files:**
- Create: `test/shared/data/hive_service_test.dart`

**Step 1: Write the test file**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';

void main() {
  late HiveService hiveService;

  setUpAll(() async {
    // Initialize Hive with a temp directory for testing
    Hive.init('./test_hive');
  });

  setUp(() async {
    hiveService = HiveService();
    await hiveService.init();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
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
```

**Step 2: Run the tests**

Run: `flutter test test/shared/data/hive_service_test.dart`
Expected: All tests pass

**Step 3: Commit**

```bash
git add test/shared/data/hive_service_test.dart
git commit -m "test: add HiveService favorites unit tests"
```

---

### Task 10: Add HiveService Settings Tests

**Files:**
- Modify: `test/shared/data/hive_service_test.dart`

**Step 1: Add settings tests to the existing file**

Add a new test group:

```dart
  group('HiveService Settings', () {
    test('isDarkMode defaults to false', () {
      expect(hiveService.isDarkMode, isFalse);
    });

    test('setDarkMode persists the value', () async {
      await hiveService.setDarkMode(true);
      expect(hiveService.isDarkMode, isTrue);

      await hiveService.setDarkMode(false);
      expect(hiveService.isDarkMode, isFalse);
    });

    test('hasSeenOnboarding defaults to false', () {
      expect(hiveService.hasSeenOnboarding, isFalse);
    });

    test('setSeenOnboarding persists the value', () async {
      await hiveService.setSeenOnboarding(true);
      expect(hiveService.hasSeenOnboarding, isTrue);
    });

    test('hasLocation returns false when no location set', () {
      expect(hiveService.hasLocation, isFalse);
    });

    test('setLocation and clearLocation work correctly', () async {
      await hiveService.setLocation(
        name: 'Test City',
        lat: 40.7128,
        lon: -74.0060,
      );

      expect(hiveService.hasLocation, isTrue);
      expect(hiveService.locationName, equals('Test City'));
      expect(hiveService.locationLat, equals(40.7128));
      expect(hiveService.locationLon, equals(-74.0060));

      await hiveService.clearLocation();
      expect(hiveService.hasLocation, isFalse);
    });
  });
```

**Step 2: Run the tests**

Run: `flutter test test/shared/data/hive_service_test.dart`
Expected: All tests pass

**Step 3: Commit**

```bash
git add test/shared/data/hive_service_test.dart
git commit -m "test: add HiveService settings unit tests"
```

---

### Task 11: Add FavoritesProvider Tests

**Files:**
- Create: `test/features/favorites/providers/favorites_provider_test.dart`

**Step 1: Write the provider test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_community_connect_app/features/favorites/providers/favorites_provider.dart';
import 'package:local_community_connect_app/shared/data/hive_service.dart';
import 'package:local_community_connect_app/shared/providers/hive_provider.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    Hive.init('./test_hive_provider');
  });

  setUp(() async {
    final hiveService = HiveService();
    await hiveService.init();

    container = ProviderContainer(
      overrides: [
        hiveServiceProvider.overrideWith((ref) async => hiveService),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Hive.deleteFromDisk();
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
```

**Step 2: Run the tests**

Run: `flutter test test/features/favorites/providers/`
Expected: All tests pass

**Step 3: Commit**

```bash
git add test/features/favorites/providers/favorites_provider_test.dart
git commit -m "test: add FavoritesProvider unit tests"
```

---

## Phase 5: Final Verification

### Task 12: Run Full Test Suite and Analyzer

**Step 1: Run all tests**

Run: `flutter test`
Expected: All tests pass

**Step 2: Run analyzer**

Run: `flutter analyze`
Expected: 0 errors, 0 warnings (only info-level notices acceptable)

**Step 3: Run the app**

Run: `flutter run -d chrome`
Manually verify:
- Events screen loads
- News screen loads
- Resources screen loads
- Favorites screen loads
- Settings screen loads (no Notifications/Language/Terms/Privacy)
- Search works
- Dark mode toggle works

**Step 4: Final commit if any cleanup needed**

```bash
git status
# If clean, proceed to squash or keep commits as-is
```

---

## Summary

| Phase | Tasks | Purpose |
|-------|-------|---------|
| 1 | 1-2 | Remove dead code |
| 2 | 3-5 | Fix analyzer warnings |
| 3 | 6-8 | Clean up unimplemented TODOs |
| 4 | 9-11 | Add essential test coverage |
| 5 | 12 | Final verification |

**Total: 12 tasks, ~45-60 minutes estimated**
