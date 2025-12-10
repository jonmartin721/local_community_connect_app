import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../providers/events_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, size: 64),
                  AppSpacing.verticalLg,
                  Text(
                    'Event not found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          final isFavorite = ref.watch(
            favoritesProvider.select(
              (state) => state[FavoriteType.events]?.contains(event.id) ?? false,
            ),
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: event.imageUrl != null ? 300 : 0,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        event.title,
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
                      background: event.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: event.imageUrl!,
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
                      const ThemeToggleButton(),
                      IconButton(
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
                    ],
                  ),
                  SliverPadding(
                    padding: AppSpacing.paddingLg,
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Date
                        Card(
                          child: Padding(
                            padding: AppSpacing.paddingLg,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                AppSpacing.horizontalLg,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    AppSpacing.verticalXs,
                                    Text(
                                      DateFormat('EEEE, MMMM d, y').format(event.date),
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      DateFormat('h:mm a').format(event.date),
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.verticalLg,
                        // Location
                        if (event.location != null) ...[
                          Card(
                            child: Padding(
                              padding: AppSpacing.paddingLg,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  AppSpacing.horizontalLg,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Location',
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                        AppSpacing.verticalXs,
                                        Text(
                                          event.location!,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppSpacing.verticalLg,
                        ],
                        // Category
                        Card(
                          child: Padding(
                            padding: AppSpacing.paddingLg,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.category,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                AppSpacing.horizontalLg,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Category',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    AppSpacing.verticalXs,
                                    Chip(
                                      label: Text(
                                        event.category,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                      side: BorderSide.none,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.verticalXxl,
                        // Description
                        Text(
                          'About this event',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        AppSpacing.verticalSm,
                        Text(
                          event.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: AppSpacing.paddingXxxl,
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
                  'Could not load event',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppSpacing.verticalSm,
                Text(
                  'Please try again later',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
