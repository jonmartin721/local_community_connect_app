import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final bool compact;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure minimum 48px touch target for accessibility
    // compact: 14 + 20 + 14 = 48px, normal: 13 + 22 + 13 = 48px
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(compact ? 14 : 13),
          decoration: BoxDecoration(
            color: isFavorite
                ? Colors.red.withValues(alpha: 0.1)
                : (compact
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.95)),
            borderRadius: BorderRadius.circular(compact ? 8 : 12),
            boxShadow: compact
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              size: compact ? 20 : 22,
              color: isFavorite
                  ? Colors.red
                  : AppColors.onSurface.withValues(alpha: 0.6),
              semanticLabel: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
          ),
        ),
      ),
    );
  }
}
