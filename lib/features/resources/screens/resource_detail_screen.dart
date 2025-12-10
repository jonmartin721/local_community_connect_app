import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
import '../providers/resources_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class ResourceDetailScreen extends ConsumerWidget {
  final String resourceId;

  const ResourceDetailScreen({super.key, required this.resourceId});

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(resourceByIdProvider(resourceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Details'),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: resourceAsync.when(
        data: (resource) {
          if (resource == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64),
                  AppSpacing.verticalLg,
                  Text(
                    'Resource not found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          final isFavorite = ref.watch(
            favoritesProvider.select(
              (state) => state[FavoriteType.resources]?.contains(resource.id) ?? false,
            ),
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with favorite button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            resource.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          color: isFavorite ? Colors.red : null,
                          onPressed: () {
                            ref.read(favoritesProvider.notifier).toggle(
                                  FavoriteType.resources,
                                  resource.id,
                                );
                          },
                        ),
                      ],
                    ),
                    AppSpacing.verticalSm,
                    Chip(
                      label: Text(
                        resource.category,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                      avatar: Icon(
                        Icons.category,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      side: BorderSide.none,
                    ),
                    AppSpacing.verticalXxl,
                    // Description
                    if (resource.description != null) ...[
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      AppSpacing.verticalSm,
                      Text(
                        resource.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      AppSpacing.verticalXxl,
                    ],
                    // Contact Information
                    Text(
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalLg,
                    // Address
                    if (resource.address != null)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: const Text('Address'),
                          subtitle: Text(resource.address!),
                        ),
                      ),
                    AppSpacing.verticalSm,
                    // Phone
                    if (resource.phoneNumber != null)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: const Text('Phone'),
                          subtitle: Text(resource.phoneNumber!),
                          trailing: IconButton(
                            icon: const Icon(Icons.call),
                            onPressed: () => _launchPhone(resource.phoneNumber!),
                            tooltip: 'Call',
                          ),
                        ),
                      ),
                    AppSpacing.verticalSm,
                    // Website
                    if (resource.websiteUrl != null)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.language,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: const Text('Website'),
                          subtitle: Text(
                            resource.websiteUrl!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => _launchWebsite(resource.websiteUrl!),
                            tooltip: 'Open website',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: AppSpacing.paddingXxxl,
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
                  'Could not load resource',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppSpacing.verticalSm,
                Text(
                  'Please try again later',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
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
