import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/favorite_button.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../../../shared/widgets/search_button.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../providers/news_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);
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
                    'News',
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
              newsAsync.when(
                data: (news) {
                  if (news.isEmpty) {
                    return SliverFillRemaining(
                      child: _EmptyState(),
                    );
                  }

                  final crossAxisCount = isExtraWide ? 3 : (isWide ? 2 : 1);

                  if (crossAxisCount > 1) {
                    return SliverPadding(
                      padding: AppSpacing.paddingXl,
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: AppSpacing.xl,
                          crossAxisSpacing: AppSpacing.xl,
                          childAspectRatio: 0.9,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _NewsCard(
                            item: news[index],
                            compact: true,
                          ),
                          childCount: news.length,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: AppSpacing.paddingXl,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _NewsCard(item: news[index]),
                        childCount: news.length,
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
                color: AppColors.secondary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.newspaper_rounded,
                size: 48,
                color: AppColors.secondary.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.verticalXxl,
            Text(
              'No news available',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSm,
            Text(
              'Check back soon for community updates',
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

class _NewsCard extends ConsumerWidget {
  final NewsItem item;
  final bool compact;

  const _NewsCard({required this.item, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (state) => state[FavoriteType.news]?.contains(item.id) ?? false,
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 0 : AppSpacing.xl),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/news/${item.id}'),
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
                  color: AppColors.secondary.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.imageUrl != null)
                  Expanded(
                    flex: compact ? 3 : 0,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Stack(
                        fit: compact ? StackFit.expand : StackFit.loose,
                        children: [
                          if (compact)
                            CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  color:
                                      AppColors.secondary.withValues(alpha: 0.5),
                                ),
                              ),
                            )
                          else
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color:
                                      AppColors.secondary.withValues(alpha: 0.1),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color:
                                      AppColors.secondary.withValues(alpha: 0.1),
                                  child: Icon(
                                    Icons.image_not_supported_rounded,
                                    color: AppColors.secondary
                                        .withValues(alpha: 0.5),
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
                                    Colors.black.withValues(alpha: 0.4),
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
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppSpacing.borderRadiusTiny,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                DateFormat('MMM d').format(item.publishedDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w700,
                                    ),
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
                                  .toggle(FavoriteType.news, item.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  flex: compact ? 2 : 0,
                  child: Padding(
                    padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: compact ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!compact) ...[
                          const SizedBox(height: 10),
                          Text(
                            item.summary,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                      height: 1.5,
                                    ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (compact) const Spacer(),
                        if (item.imageUrl == null && !compact)
                          Padding(
                            padding: EdgeInsets.only(top: AppSpacing.lg),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MMM d, y')
                                      .format(item.publishedDate),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                ),
                                FavoriteButton(
                                  isFavorite: isFavorite,
                                  onTap: () => ref
                                      .read(favoritesProvider.notifier)
                                      .toggle(FavoriteType.news, item.id),
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                      ],
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
