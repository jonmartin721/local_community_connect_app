import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/models/models.dart';
import '../../../shared/utils/category_colors.dart';
import '../../../shared/widgets/favorite_button.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../../../shared/widgets/search_button.dart';
import '../../../shared/widgets/filter_chip.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../providers/events_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final categories = ref.watch(eventCategoriesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;
    final isExtraWide = screenWidth > 1200;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                stretch: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: AppSpacing.xl, bottom: AppSpacing.lg),
                  title: Text(
                    'Events',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
                actions: const [
                  ThemeToggleButton(),
                  SearchButton(),
                ],
              ),
              eventsAsync.when(
                data: (allEvents) {
                  final categoryCounts = <String, int>{};
                  for (final event in allEvents) {
                    categoryCounts[event.category] =
                        (categoryCounts[event.category] ?? 0) + 1;
                  }

                  return SliverToBoxAdapter(
                    child: Container(
                      height: 56,
                      margin: EdgeInsets.only(top: AppSpacing.sm),
                      child: isWide
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                              child: Row(
                                children: [
                                  AppFilterChip(
                                    label: 'All',
                                    count: allEvents.length,
                                    isSelected: _selectedCategory == null,
                                    onTap: () =>
                                        setState(() => _selectedCategory = null),
                                  ),
                                  ...categories.map((category) => AppFilterChip(
                                        label: category,
                                        count: categoryCounts[category] ?? 0,
                                        isSelected: _selectedCategory == category,
                                        color: getCategoryColor(category),
                                        onTap: () => setState(
                                            () => _selectedCategory = category),
                                      )),
                                ],
                              ),
                            )
                          : ListView(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                              children: [
                                AppFilterChip(
                                  label: 'All',
                                  count: allEvents.length,
                                  isSelected: _selectedCategory == null,
                                  onTap: () =>
                                      setState(() => _selectedCategory = null),
                                ),
                                ...categories.map((category) => AppFilterChip(
                                      label: category,
                                      count: categoryCounts[category] ?? 0,
                                      isSelected: _selectedCategory == category,
                                      color: getCategoryColor(category),
                                      onTap: () => setState(
                                          () => _selectedCategory = category),
                                    )),
                              ],
                            ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              eventsAsync.when(
                data: (events) {
                  final filteredEvents = _selectedCategory == null
                      ? events
                      : events
                          .where((e) => e.category == _selectedCategory)
                          .toList();

                  if (filteredEvents.isEmpty) {
                    return SliverFillRemaining(
                      child: _EmptyState(category: _selectedCategory),
                    );
                  }

                  final crossAxisCount = isExtraWide ? 3 : (isWide ? 2 : 1);

                  return SliverPadding(
                    padding: AppSpacing.paddingXl,
                    sliver: crossAxisCount > 1
                        ? SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: AppSpacing.xl,
                              crossAxisSpacing: AppSpacing.xl,
                              childAspectRatio: 0.85,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final event = filteredEvents[index];
                                return _EventCard(event: event, compact: isWide);
                              },
                              childCount: filteredEvents.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final event = filteredEvents[index];
                                return _EventCard(event: event);
                              },
                              childCount: filteredEvents.length,
                            ),
                          ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(
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
                          'Something went wrong',
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

class _EmptyState extends StatelessWidget {
  final String? category;

  const _EmptyState({this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXxxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingXxl,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.verticalXxl,
            Text(
              category != null ? 'No $category events' : 'No events found',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSm,
            Text(
              'Check back soon for upcoming community events',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  final Event event;
  final bool compact;

  const _EventCard({required this.event, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (state) => state[FavoriteType.events]?.contains(event.id) ?? false,
      ),
    );
    final categoryColor = getCategoryColor(event.category);

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 0 : AppSpacing.xl),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/events/${event.id}'),
          borderRadius: AppSpacing.borderRadiusXl,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppSpacing.borderRadiusXl,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.imageUrl != null)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                            imageUrl: event.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: categoryColor.withValues(alpha: 0.1),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: categoryColor.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: categoryColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                ],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.md,
                          left: AppSpacing.md,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppSpacing.borderRadiusXs,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('MMM').format(event.date).toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: categoryColor,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                Text(
                                  DateFormat('d').format(event.date),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w700,
                                        height: 1,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.md,
                          right: AppSpacing.md,
                          child: FavoriteButton(
                            isFavorite: isFavorite,
                            onTap: () => ref
                                .read(favoritesProvider.notifier)
                                .toggle(FavoriteType.events, event.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: AppSpacing.paddingXl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs + 6,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: AppSpacing.borderRadiusTiny,
                        ),
                        child: Text(
                          event.category,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: categoryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      AppSpacing.verticalMd,
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              height: 1.2,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.verticalSm,
                      Text(
                        event.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (event.location != null) ...[
                        AppSpacing.verticalLg,
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                event.location!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (event.imageUrl == null) ...[
                        AppSpacing.verticalLg,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: categoryColor,
                                ),
                                AppSpacing.horizontalSm,
                                Text(
                                  DateFormat('EEEE, MMM d').format(event.date),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: categoryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            FavoriteButton(
                              isFavorite: isFavorite,
                              onTap: () => ref
                                  .read(favoritesProvider.notifier)
                                  .toggle(FavoriteType.events, event.id),
                              compact: true,
                            ),
                          ],
                        ),
                      ],
                    ],
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
