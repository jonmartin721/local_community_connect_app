import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/hive_provider.dart';

part 'search_provider.g.dart';

class SearchResults {
  final List<Event> events;
  final List<NewsItem> news;
  final List<LocalResource> resources;

  SearchResults({
    required this.events,
    required this.news,
    required this.resources,
  });

  bool get isEmpty => events.isEmpty && news.isEmpty && resources.isEmpty;
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  Future<SearchResults> build(String query) async {
    if (query.isEmpty) {
      return SearchResults(events: [], news: [], resources: []);
    }

    final hive = await ref.watch(hiveServiceProvider.future);
    final allEvents = hive.getAllEvents();
    final allNews = hive.getAllNews();
    final allResources = hive.getAllResources();

    final lowerQuery = query.toLowerCase();

    final filteredEvents = allEvents.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
          event.description.toLowerCase().contains(lowerQuery) ||
          event.category.toLowerCase().contains(lowerQuery) ||
          (event.location?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    final filteredNews = allNews.where((item) {
      return item.title.toLowerCase().contains(lowerQuery) ||
          item.summary.toLowerCase().contains(lowerQuery) ||
          (item.content?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    final filteredResources = allResources.where((resource) {
      return resource.name.toLowerCase().contains(lowerQuery) ||
          resource.category.toLowerCase().contains(lowerQuery) ||
          (resource.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (resource.address?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    return SearchResults(
      events: filteredEvents,
      news: filteredNews,
      resources: filteredResources,
    );
  }
}
