import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/spacing.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusSm,
        child: InkWell(
          onTap: () => context.push('/search'),
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
            child: const Icon(Icons.search_rounded, size: 22),
          ),
        ),
      ),
    );
  }
}
