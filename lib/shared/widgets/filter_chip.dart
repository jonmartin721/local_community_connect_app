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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chipColor = color ?? theme.colorScheme.primary;

    // Compute contrasting text color for selected state based on chip luminance
    final selectedTextColor = chipColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

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
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? chipColor
                    : theme.colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.15),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? selectedTextColor
                            : theme.colorScheme.onSurface,
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
                          ? selectedTextColor.withValues(alpha: 0.2)
                          : chipColor.withValues(alpha: isDark ? 0.25 : 0.12),
                      borderRadius: AppSpacing.borderRadiusXs,
                    ),
                    child: Text(
                      count.toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected ? selectedTextColor : chipColor,
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
