import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../../../shared/widgets/search_button.dart';
import '../../../shared/widgets/filter_chip.dart';
import '../../../shared/utils/category_colors.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
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
              SliverAppBar(
                expandedHeight: 100,
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: AppSpacing.xl, bottom: AppSpacing.lg),
                  title: Text(
                    'Resources',
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
                      margin: EdgeInsets.only(top: AppSpacing.sm),
                      child: isWide
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                              child: Row(
                                children: [
                                  AppFilterChip(
                                    label: 'All',
                                    count: resources.length,
                                    isSelected: _selectedCategory == null,
                                    onTap: () => setState(() => _selectedCategory = null),
                                  ),
                                  ...categories.map((category) => AppFilterChip(
                                        label: category,
                                        count: categoryCounts[category] ?? 0,
                                        isSelected: _selectedCategory == category,
                                        color: getCategoryColor(category),
                                        onTap: () =>
                                            setState(() => _selectedCategory = category),
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
                                  count: resources.length,
                                  isSelected: _selectedCategory == null,
                                  onTap: () => setState(() => _selectedCategory = null),
                                ),
                                ...categories.map((category) => AppFilterChip(
                                      label: category,
                                      count: categoryCounts[category] ?? 0,
                                      isSelected: _selectedCategory == category,
                                      color: getCategoryColor(category),
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
                      padding: AppSpacing.paddingXl,
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: AppSpacing.lg,
                          crossAxisSpacing: AppSpacing.lg,
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
                    padding: AppSpacing.paddingXl,
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
                color: AppColors.tertiary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.explore_rounded,
                size: 48,
                color: AppColors.tertiary.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.verticalXxl,
            Text(
              category != null ? 'No $category resources' : 'No resources available',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSm,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (state) => state[FavoriteType.resources]?.contains(resource.id) ?? false,
      ),
    );
    final categoryColor = getCategoryColor(resource.category);
    final categoryIcon = getCategoryIcon(resource.category);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/resources/${resource.id}'),
          borderRadius: AppSpacing.borderRadiusLg,
          child: Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppSpacing.borderRadiusLg,
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
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 26,
                  ),
                ),
                AppSpacing.horizontalLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
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
                        AppSpacing.verticalXs,
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
                            AppSpacing.horizontalXs,
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
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => ref
                        .read(favoritesProvider.notifier)
                        .toggle(FavoriteType.resources, resource.id),
                    borderRadius: AppSpacing.borderRadiusXs,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: AppSpacing.paddingSm,
                      decoration: BoxDecoration(
                        color: isFavorite
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: AppSpacing.borderRadiusXs,
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
                          semanticLabel: isFavorite ? 'Remove from favorites' : 'Add to favorites',
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
