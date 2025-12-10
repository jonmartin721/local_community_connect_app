import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../providers/search_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final searchResults = query.isEmpty
        ? null
        : ref.watch(searchProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: AppSpacing.paddingLg,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events, news, resources...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              // Results
              Expanded(
                child: query.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            AppSpacing.verticalLg,
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
                                  AppSpacing.verticalLg,
                                  Text(
                                    'No results found',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  AppSpacing.verticalSm,
                                  Text(
                                    'Try searching with different keywords',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView(
                            padding: AppSpacing.paddingLg,
                            children: [
                              // Events
                              if (results.events.isNotEmpty) ...[
                                _SectionHeader(
                                  title: 'Events',
                                  count: results.events.length,
                                ),
                                AppSpacing.verticalSm,
                                ...results.events.map((event) {
                                  return _EventCard(event: event);
                                }),
                                AppSpacing.verticalXxl,
                              ],
                              // News
                              if (results.news.isNotEmpty) ...[
                                _SectionHeader(
                                  title: 'News',
                                  count: results.news.length,
                                ),
                                AppSpacing.verticalSm,
                                ...results.news.map((item) {
                                  return _NewsCard(item: item);
                                }),
                                AppSpacing.verticalXxl,
                              ],
                              // Resources
                              if (results.resources.isNotEmpty) ...[
                                _SectionHeader(
                                  title: 'Resources',
                                  count: results.resources.length,
                                ),
                                AppSpacing.verticalSm,
                                ...results.resources.map((resource) {
                                  return _ResourceCard(resource: resource);
                                }),
                              ],
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              AppSpacing.verticalLg,
                              Text(
                                'Search failed',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
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
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
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
            semanticLabel: isFavorite ? 'Remove from favorites' : 'Add to favorites',
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
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
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
            semanticLabel: isFavorite ? 'Remove from favorites' : 'Add to favorites',
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
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
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
            semanticLabel: isFavorite ? 'Remove from favorites' : 'Add to favorites',
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
