import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/models/models.dart';
import '../providers/location_provider.dart';

class LocationSetupScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;

  const LocationSetupScreen({
    super.key,
    this.isOnboarding = false,
  });

  @override
  ConsumerState<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends ConsumerState<LocationSetupScreen> {
  final _controller = TextEditingController();
  UserLocation? _selectedLocation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(locationSetupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Location'),
        actions: widget.isOnboarding
            ? [
                TextButton(
                  onPressed: () => context.go('/events'),
                  child: const Text('Skip'),
                ),
              ]
            : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter your city or zip code to find local resources',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                AppSpacing.verticalLg,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Portland, OR or 97201',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    AppSpacing.horizontalSm,
                    FilledButton(
                      onPressed: setupState.status == LocationSetupStatus.searching
                          ? null
                          : _search,
                      child: setupState.status == LocationSetupStatus.searching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Search'),
                    ),
                  ],
                ),
                AppSpacing.verticalXxl,
                if (setupState.errorMessage != null)
                  Container(
                    padding: AppSpacing.paddingMd,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        AppSpacing.horizontalSm,
                        Expanded(
                          child: Text(
                            setupState.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (setupState.status == LocationSetupStatus.selectingLocation) ...[
                  Text(
                    'Select your location:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  AppSpacing.verticalSm,
                  Expanded(
                    child: ListView.builder(
                      itemCount: setupState.searchResults.length,
                      itemBuilder: (context, index) {
                        final location = setupState.searchResults[index];
                        final isSelected = _selectedLocation == location;
                        return RadioListTile<UserLocation>(
                          value: location,
                          groupValue: _selectedLocation,
                          onChanged: (value) {
                            setState(() => _selectedLocation = value);
                          },
                          title: Text(
                            location.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: isSelected,
                          activeColor: AppColors.primary,
                        );
                      },
                    ),
                  ),
                ],
                if (setupState.status == LocationSetupStatus.fetchingResources)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          AppSpacing.verticalLg,
                          const Text('Finding local resources...'),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                if (setupState.status == LocationSetupStatus.selectingLocation)
                  FilledButton(
                    onPressed: _selectedLocation != null ? _confirmSelection : null,
                    child: const Text('Continue'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _search() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() => _selectedLocation = null);
    ref.read(locationSetupProvider.notifier).search(query);
  }

  Future<void> _confirmSelection() async {
    if (_selectedLocation == null) return;
    final success = await ref
        .read(locationSetupProvider.notifier)
        .selectLocation(_selectedLocation!);
    if (success && mounted) {
      if (widget.isOnboarding) {
        context.go('/events');
      } else {
        context.pop();
      }
    }
  }
}
