import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../../app/theme/spacing.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusSm,
        child: InkWell(
          onTap: () => ref.read(themeProvider.notifier).toggle(),
          borderRadius: AppSpacing.borderRadiusSm,
          child: Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
