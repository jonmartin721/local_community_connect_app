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
import '../../../app/theme/colors.dart';
import '../providers/events_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCategory;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Events',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.tertiary.withValues(alpha: 0.05),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
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
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                    )),
                    child: Container(
                      height: 56,
                      margin: const EdgeInsets.only(top: 8),
                      child: isWide
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  _FilterChip(
                                    label: 'All',
                                    count: allEvents.length,
                                    isSelected: _selectedCategory == null,
                                    onTap: () =>
                                        setState(() => _selectedCategory = null),
                                  ),
                                  ...categories.map((category) => _FilterChip(
                                        label: category,
                                        count: categoryCounts[category] ?? 0,
                                        isSelected:
                                            _selectedCategory == category,
                                        color: getCategoryColor(category),
                                        onTap: () => setState(
                                            () => _selectedCategory = category),
                                      )),
                                ],
                              ),
                            )
                          : ListView(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                _FilterChip(
                                  label: 'All',
                                  count: allEvents.length,
                                  isSelected: _selectedCategory == null,
                                  onTap: () =>
                                      setState(() => _selectedCategory = null),
                                ),
                                ...categories.map((category) => _FilterChip(
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
                padding: const EdgeInsets.all(20),
                sliver: crossAxisCount > 1
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = filteredEvents[index];
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  0.2 + (index * 0.05).clamp(0.0, 0.6),
                                  0.4 + (index * 0.05).clamp(0.0, 0.6),
                                  curve: Curves.easeOut,
                                ),
                              ),
                              child: _EventCard(event: event, compact: isWide),
                            );
                          },
                          childCount: filteredEvents.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = filteredEvents[index];
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  0.2 + (index * 0.1).clamp(0.0, 0.6),
                                  0.4 + (index * 0.1).clamp(0.0, 0.6),
                                  curve: Curves.easeOut,
                                ),
                              ),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    0.2 + (index * 0.1).clamp(0.0, 0.6),
                                    0.4 + (index * 0.1).clamp(0.0, 0.6),
                                    curve: Curves.easeOut,
                                  ),
                                )),
                                child: _EventCard(event: event),
                              ),
                            );
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
                    const SizedBox(height: 16),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.count,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? chipColor
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? chipColor
                    : Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.15),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: chipColor.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : chipColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : chipColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ],
            ),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 24),
            Text(
              category != null ? 'No $category events' : 'No events found',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
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
      padding: EdgeInsets.only(bottom: compact ? 0 : 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/events/${event.id}'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
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
                // Image with gradient overlay
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
                        // Gradient overlay
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
                        // Date badge
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
                          top: 12,
                          right: 12,
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
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
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
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              height: 1.2,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Description
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
                        const SizedBox(height: 16),
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
                      // Date row for cards without image
                      if (event.imageUrl == null) ...[
                        const SizedBox(height: 16),
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
                                const SizedBox(width: 8),
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
