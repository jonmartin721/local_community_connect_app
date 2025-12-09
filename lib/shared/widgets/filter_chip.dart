import 'package:flutter/material.dart';
import '../../app/theme/spacing.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
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
      padding: EdgeInsets.only(right: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg + 2,
              vertical: AppSpacing.md,
            ),
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
                      ),
                ),
                if (count != null) ...[
                  AppSpacing.horizontalSm,
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : chipColor.withValues(alpha: 0.12),
                      borderRadius: AppSpacing.borderRadiusXs,
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
