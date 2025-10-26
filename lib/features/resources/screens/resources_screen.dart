import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/models.dart';
import '../../../app/theme/colors.dart';
import '../providers/resources_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(resourcesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;
    final isExtraWide = screenWidth > 1200;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: CustomScrollView(
            slivers: [
              // App bar with gradient
              SliverAppBar(
                expandedHeight: 100,
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'Resources',
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
                          AppColors.tertiary.withValues(alpha: 0.1),
                          AppColors.primary.withValues(alpha: 0.04),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(Icons.search_rounded, size: 22),
                      ),
                      onPressed: () => context.push('/search'),
                    ),
                  ),
                ],
              ),
              // Category filter chips with counts
              resourcesAsync.when(
                data: (resources) {
                  final categories = resources.map((r) => r.category).toSet().toList()..sort();
                  final categoryCounts = <String, int>{};
                  for (final resource in resources) {
                    categoryCounts[resource.category] =
                        (categoryCounts[resource.category] ?? 0) + 1;
                  }

                  return SliverToBoxAdapter(
                    child: Container(
                      height: 56,
                      margin: const EdgeInsets.only(top: 8),
                      child: isWide
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  _FilterChip(
                                    label: 'All',
                                    count: resources.length,
                                    isSelected: _selectedCategory == null,
                                    onTap: () => setState(() => _selectedCategory = null),
                                  ),
                                  ...categories.map((category) => _FilterChip(
                                        label: category,
                                        count: categoryCounts[category] ?? 0,
                                        isSelected: _selectedCategory == category,
                                        color: _getCategoryColor(category),
                                        onTap: () =>
                                            setState(() => _selectedCategory = category),
                                      )),
                                ],
                              ),
                            )
                          : ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                _FilterChip(
                                  label: 'All',
                                  count: resources.length,
                                  isSelected: _selectedCategory == null,
                                  onTap: () => setState(() => _selectedCategory = null),
                                ),
                                ...categories.map((category) => _FilterChip(
                                      label: category,
                                      count: categoryCounts[category] ?? 0,
                                      isSelected: _selectedCategory == category,
                                      color: _getCategoryColor(category),
                                      onTap: () =>
                                          setState(() => _selectedCategory = category),
                                    )),
                              ],
                            ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              // Resources content
              resourcesAsync.when(
                data: (resources) {
                  final filtered = _selectedCategory == null
                      ? resources
                      : resources.where((r) => r.category == _selectedCategory).toList();

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      child: _EmptyState(category: _selectedCategory),
                    );
                  }

                  final crossAxisCount = isExtraWide ? 3 : (isWide ? 2 : 1);

                  if (crossAxisCount > 1) {
                    return SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _ResourceCard(resource: filtered[index]),
                          childCount: filtered.length,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ResourceCard(resource: filtered[index]),
                        childCount: filtered.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Government':
        return const Color(0xFF5C7AEA);
      case 'Health':
        return const Color(0xFFE07A9F);
      case 'Education':
        return const Color(0xFF7A9FE0);
      case 'Community':
        return AppColors.primary;
      case 'Emergency':
        return const Color(0xFFE05C5C);
      case 'Recreation':
        return AppColors.secondary;
      default:
        return AppColors.tertiary;
    }
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
    final chipColor = color ?? AppColors.tertiary;

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
              color: isSelected ? chipColor : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? chipColor
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : chipColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected ? Colors.white : chipColor,
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
                color: AppColors.tertiary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.explore_rounded,
                size: 48,
                color: AppColors.tertiary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              category != null ? 'No $category resources' : 'No resources available',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon for community resources',
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

class _ResourceCard extends ConsumerWidget {
  final LocalResource resource;

  const _ResourceCard({required this.resource});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Government':
        return const Color(0xFF5C7AEA);
      case 'Health':
        return const Color(0xFFE07A9F);
      case 'Education':
        return const Color(0xFF7A9FE0);
      case 'Community':
        return AppColors.primary;
      case 'Emergency':
        return const Color(0xFFE05C5C);
      case 'Recreation':
        return AppColors.secondary;
      default:
        return AppColors.tertiary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Government':
        return Icons.account_balance_rounded;
      case 'Health':
        return Icons.local_hospital_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Community':
        return Icons.groups_rounded;
      case 'Emergency':
        return Icons.emergency_rounded;
      case 'Recreation':
        return Icons.park_rounded;
      default:
        return Icons.business_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (state) => state[FavoriteType.resources]?.contains(resource.id) ?? false,
      ),
    );
    final categoryColor = _getCategoryColor(resource.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/resources/${resource.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getCategoryIcon(resource.category),
                    color: categoryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          resource.category,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                        ),
                      ),
                      Text(
                        resource.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (resource.address != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                resource.address!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                    ],
                  ),
                ),
                // Favorite button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => ref
                        .read(favoritesProvider.notifier)
                        .toggle(FavoriteType.resources, resource.id),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isFavorite
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(isFavorite),
                          size: 22,
                          color: isFavorite
                              ? Colors.red
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4),
                        ),
                      ),
                    ),
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
