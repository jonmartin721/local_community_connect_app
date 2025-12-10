import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/providers/providers.dart';
import '../../../features/resources/providers/resources_provider.dart';
import '../providers/location_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
      body: ListView(
        children: [
          // Display Section
          _SettingsSection(
            title: 'Display',
            children: [
              _SettingsTile(
                icon: Icons.brightness_7,
                label: 'Dark Mode',
                subtitle: isDarkMode ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (_) {
                    ref.read(themeProvider.notifier).toggle();
                  },
                ),
              ),
            ],
          ),
          // Location Section
          _SettingsSection(
            title: 'Location',
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final locationAsync = ref.watch(currentLocationProvider);
                  return locationAsync.when(
                    data: (location) => _SettingsTile(
                      icon: Icons.location_on_outlined,
                      label: 'Your Location',
                      subtitle: location?.displayName ?? 'Not set - using sample data',
                      onTap: () => context.push('/location-setup'),
                    ),
                    loading: () => const _SettingsTile(
                      icon: Icons.location_on_outlined,
                      label: 'Your Location',
                      subtitle: 'Loading...',
                    ),
                    error: (_, __) => _SettingsTile(
                      icon: Icons.location_on_outlined,
                      label: 'Your Location',
                      subtitle: 'Error loading location',
                      onTap: () => context.push('/location-setup'),
                    ),
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final locationAsync = ref.watch(currentLocationProvider);
                  final hasLocation = locationAsync.hasValue && locationAsync.value != null;
                  if (!hasLocation) return const SizedBox.shrink();
                  return _SettingsTile(
                    icon: Icons.refresh,
                    label: 'Reset to Sample Data',
                    subtitle: 'Clear location and use demo data',
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset to Sample Data?'),
                          content: const Text(
                            'This will clear your location and replace resources with sample data.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        final hive = await ref.read(hiveServiceProvider.future);
                        await hive.resetToSampleData();
                        ref.invalidate(currentLocationProvider);
                        ref.invalidate(resourcesProvider);
                      }
                    },
                  );
                },
              ),
            ],
          ),
          // Language Section
          _SettingsSection(
            title: 'Language',
            children: [
              _SettingsTile(
                icon: Icons.language,
                label: 'Language',
                subtitle: 'English',
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),
            ],
          ),
          // About Section
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outlined,
                label: 'Version',
                subtitle: '1.0.0',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              label: 'English',
              onTap: () => Navigator.pop(context),
            ),
            _LanguageOption(
              label: 'Spanish',
              onTap: () => Navigator.pop(context),
            ),
            _LanguageOption(
              label: 'French',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.md),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        leading: Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              )
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_right,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  )
                : null),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
