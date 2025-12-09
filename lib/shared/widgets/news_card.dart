import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/spacing.dart';
import '../models/news_item.dart';
import 'favorite_button.dart';

/// A reusable news card widget that displays title, excerpt, image, and timestamp.
///
/// Balances competing requirements:
/// - Brand consistency: Uses terracotta/sage/gold palette and app typography
/// - Accessibility: Semantic labels, proper contrast, text hierarchy
/// - Visual distinction: Gradient accents and thoughtful spacing without excess
/// - Animation: Smooth favorite button transitions
class NewsCard extends StatefulWidget {
  final NewsItem item;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool compact;
  final String? heroTag;

  const NewsCard({
    super.key,
    required this.item,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.compact = false,
    this.heroTag,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> with SingleTickerProviderStateMixin {
  late AnimationController _elevationController;
  late Animation<double> _elevation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _elevation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _elevationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _elevationController.dispose();
    super.dispose();
  }

  void _onEnter() {
    if (!_isHovered) {
      _isHovered = true;
      _elevationController.forward();
    }
  }

  void _onExit() {
    if (_isHovered) {
      _isHovered = false;
      _elevationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Semantics(
      enabled: true,
      label: '${widget.item.title}, published ${DateFormat('MMM d, y').format(widget.item.publishedDate)}',
      button: true,
      child: MouseRegion(
        onEnter: (_) => _onEnter(),
        onExit: (_) => _onExit(),
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.compact ? 0 : 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: AnimatedBuilder(
                animation: _elevation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      border: Border.all(
                        color: textColor.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        if (_elevation.value > 0)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: _elevation.value * 0.08),
                            blurRadius: 20,
                            offset: Offset(0, _elevation.value),
                          ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: _buildCardContent(context, isDark, textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section with gradient and overlays
        if (widget.item.imageUrl != null)
          _buildImageSection(context, isDark, textColor),

        // Content section
        Expanded(
          flex: widget.compact ? 2 : 0,
          child: Padding(
            padding: EdgeInsets.all(widget.compact ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: widget.compact ? MainAxisSize.max : MainAxisSize.min,
              children: [
                // Title with gradient accent underline (subtle distinctive touch)
                Stack(
                  children: [
                    Text(
                      widget.item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: widget.compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Subtle gradient underline (distinctive without being loud)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -4,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.tertiary.withValues(alpha: 0.4),
                              AppColors.secondary.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.compact ? 12 : 8),

                // Excerpt
                if (!widget.compact)
                  Text(
                    widget.item.summary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    semanticsLabel: 'Summary: ${widget.item.summary}',
                  ),

                if (widget.compact) const Spacer(),

                // Footer with metadata
                if (widget.item.imageUrl == null && !widget.compact)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildFooter(context, textColor),
                  ),
              ],
            ),
          ),
        ),

        // Compact footer for image cards
        if (widget.item.imageUrl != null && widget.compact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildCompactFooter(context, textColor),
          ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, bool isDark, Color textColor) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      child: Stack(
        fit: widget.compact ? StackFit.expand : StackFit.loose,
        children: [
          // Image
          if (widget.compact)
            CachedNetworkImage(
              imageUrl: widget.item.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => _buildImagePlaceholder(),
              errorWidget: (context, url, error) => _buildImageError(),
            )
          else
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: widget.item.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildImageError(),
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
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),

          // Date badge with brand color
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusTiny),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                DateFormat('MMM d').format(widget.item.publishedDate),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                semanticsLabel: 'Published date: ${DateFormat('MMMM d').format(widget.item.publishedDate)}',
              ),
            ),
          ),

          // Favorite button
          if (widget.onFavoriteTap != null)
            Positioned(
              top: 12,
              right: 12,
              child: FavoriteButton(
                isFavorite: widget.isFavorite,
                onTap: widget.onFavoriteTap ?? () {},
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            DateFormat('MMM d, y').format(widget.item.publishedDate),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withValues(alpha: 0.5),
                ),
            semanticsLabel: 'Published: ${DateFormat('MMMM d, yyyy').format(widget.item.publishedDate)}',
          ),
        ),
        if (widget.onFavoriteTap != null)
          FavoriteButton(
            isFavorite: widget.isFavorite,
            onTap: widget.onFavoriteTap ?? () {},
            compact: true,
          ),
      ],
    );
  }

  Widget _buildCompactFooter(BuildContext context, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          DateFormat('MMM d, y').format(widget.item.publishedDate),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor.withValues(alpha: 0.5),
              ),
          semanticsLabel: 'Published: ${DateFormat('MMMM d, yyyy').format(widget.item.publishedDate)}',
        ),
        if (widget.onFavoriteTap != null)
          FavoriteButton(
            isFavorite: widget.isFavorite,
            onTap: widget.onFavoriteTap ?? () {},
            compact: true,
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.secondary.withValues(alpha: 0.1),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(AppColors.secondary),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.secondary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          color: AppColors.secondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
