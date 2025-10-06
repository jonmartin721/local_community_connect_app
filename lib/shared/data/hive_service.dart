import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../models/hive_adapters.dart';
import 'sample_data.dart';

class HiveService {
  static const String eventsBox = 'events';
  static const String newsBox = 'news';
  static const String resourcesBox = 'resources';
  static const String favoritesBox = 'favorites';
  static const String settingsBox = 'settings';

  static bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Only register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EventAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NewsItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(LocalResourceAdapter());
    }

    await Future.wait([
      Hive.openBox<Event>(eventsBox),
      Hive.openBox<NewsItem>(newsBox),
      Hive.openBox<LocalResource>(resourcesBox),
      Hive.openBox<List<String>>(favoritesBox),
      Hive.openBox(settingsBox),
    ]);

    await _seedDataIfEmpty();
    _initialized = true;
  }

  Future<void> _seedDataIfEmpty() async {
    final events = Hive.box<Event>(eventsBox);
    if (events.isEmpty) {
      for (final event in SampleData.events) {
        await events.put(event.id, event);
      }
    }

    final news = Hive.box<NewsItem>(newsBox);
    if (news.isEmpty) {
      for (final item in SampleData.news) {
        await news.put(item.id, item);
      }
    }

    final resources = Hive.box<LocalResource>(resourcesBox);
    if (resources.isEmpty) {
      for (final resource in SampleData.resources) {
        await resources.put(resource.id, resource);
      }
    }
  }

  // Events
  List<Event> getAllEvents() => Hive.box<Event>(eventsBox).values.toList();
  Event? getEvent(String id) => Hive.box<Event>(eventsBox).get(id);

  // News
  List<NewsItem> getAllNews() => Hive.box<NewsItem>(newsBox).values.toList();
  NewsItem? getNewsItem(String id) => Hive.box<NewsItem>(newsBox).get(id);

  // Resources
  List<LocalResource> getAllResources() =>
      Hive.box<LocalResource>(resourcesBox).values.toList();
  LocalResource? getResource(String id) =>
      Hive.box<LocalResource>(resourcesBox).get(id);

  // Favorites
  Set<String> getFavoriteIds(String type) {
    final box = Hive.box<List<String>>(favoritesBox);
    return (box.get(type) ?? []).toSet();
  }

  Future<void> toggleFavorite(String type, String id) async {
    final box = Hive.box<List<String>>(favoritesBox);
    final current = (box.get(type) ?? []).toList();
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await box.put(type, current);
  }

  // Settings
  bool get isDarkMode => Hive.box(settingsBox).get('darkMode', defaultValue: false);
  Future<void> setDarkMode(bool value) =>
      Hive.box(settingsBox).put('darkMode', value);

  bool get hasSeenOnboarding =>
      Hive.box(settingsBox).get('seenOnboarding', defaultValue: false);
  Future<void> setSeenOnboarding(bool value) =>
      Hive.box(settingsBox).put('seenOnboarding', value);
}
