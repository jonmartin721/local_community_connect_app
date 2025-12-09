import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../shared/providers/theme_provider.dart';

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
          // Notifications Section
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Push Notifications',
                subtitle: 'Receive event and news updates',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification toggle
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.event_outlined,
                label: 'Event Alerts',
                subtitle: 'Notify for new events',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement event alert toggle
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.newspaper_outlined,
                label: 'News Updates',
                subtitle: 'Notify for new articles',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement news update toggle
                  },
                ),
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
              _SettingsTile(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () {
                  // TODO: Navigate to terms
                },
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
