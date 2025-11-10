import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/models.dart';
import '../providers/search_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _query.isEmpty
        ? null
        : ref.watch(searchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events, news, resources...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          // Results
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for events, news, and resources',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : searchResults!.when(
                    data: (results) {
                      if (results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No results found',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with different keywords',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Events
                          if (results.events.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'Events',
                              count: results.events.length,
                            ),
                            const SizedBox(height: 8),
                            ...results.events.map((event) {
                              return _EventCard(event: event);
                            }),
                            const SizedBox(height: 24),
                          ],
                          // News
                          if (results.news.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'News',
                              count: results.news.length,
                            ),
                            const SizedBox(height: 8),
                            ...results.news.map((item) {
                              return _NewsCard(item: item);
                            }),
                            const SizedBox(height: 24),
                          ],
                          // Resources
                          if (results.resources.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'Resources',
                              count: results.resources.length,
                            ),
                            const SizedBox(height: 8),
                            ...results.resources.map((resource) {
                              return _ResourceCard(resource: resource);
                            }),
                          ],
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$title ($count)',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (state) => state[FavoriteType.events]?.contains(event.id) ?? false,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.push('/events/${event.id}'),
        leading: Icon(
          Icons.event,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          event.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormat('MMM d, y').format(event.date),
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
          color: isFavorite ? Colors.red : null,
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggle(
                  FavoriteType.events,
                  event.id,
                );
          },
        ),
      ),
    );
  }
}

class _NewsCard extends ConsumerWidget {
  final NewsItem item;

  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (state) => state[FavoriteType.news]?.contains(item.id) ?? false,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.push('/news/${item.id}'),
        leading: Icon(
          Icons.article,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          item.summary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
          color: isFavorite ? Colors.red : null,
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggle(
                  FavoriteType.news,
                  item.id,
                );
          },
        ),
      ),
    );
  }
}

class _ResourceCard extends ConsumerWidget {
  final LocalResource resource;

  const _ResourceCard({required this.resource});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (state) => state[FavoriteType.resources]?.contains(resource.id) ?? false,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.push('/resources/${resource.id}'),
        leading: Icon(
          Icons.location_on,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          resource.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          resource.category,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
          color: isFavorite ? Colors.red : null,
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggle(
                  FavoriteType.resources,
                  resource.id,
                );
          },
        ),
      ),
    );
  }
}
