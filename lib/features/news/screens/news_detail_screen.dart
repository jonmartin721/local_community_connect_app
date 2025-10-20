import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/news_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class NewsDetailScreen extends ConsumerWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsByIdProvider(newsId));

    return Scaffold(
      body: newsAsync.when(
        data: (newsItem) {
          if (newsItem == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Article not found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          final isFavorite = ref.watch(
            favoritesProvider.select(
              (state) => state[FavoriteType.news]?.contains(newsItem.id) ?? false,
            ),
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: newsItem.imageUrl != null ? 300 : 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    newsItem.title,
                    style: const TextStyle(
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  background: newsItem.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: newsItem.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : null,
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    color: isFavorite ? Colors.red : null,
                    onPressed: () {
                      ref.read(favoritesProvider.notifier).toggle(
                            FavoriteType.news,
                            newsItem.id,
                          );
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Published date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Published ${DateFormat('MMMM d, y').format(newsItem.publishedDate)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Summary
                    Text(
                      newsItem.summary,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Content
                    if (newsItem.content != null)
                      Text(
                        newsItem.content!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                      )
                    else
                      Text(
                        'No additional content available.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
