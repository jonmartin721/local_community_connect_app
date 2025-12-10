import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/providers/hive_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final hive = await ref.read(hiveServiceProvider.future);
    await hive.setSeenOnboarding(true);
    if (mounted) {
      context.go('/events');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: TextButton(
                  onPressed: _currentPage < 2 ? _completeOnboarding : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: _currentPage < 2 ? 0.6 : 0),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _OnboardingPage(
                    icon: Icons.calendar_month_rounded,
                    iconColor: AppColors.primary,
                    accentColor: AppColors.primary,
                    title: 'Discover Local Events',
                    description:
                        'Stay connected with your community through upcoming events, gatherings, and activities happening right in your neighborhood.',
                    decorationIcons: const [
                      Icons.music_note_rounded,
                      Icons.sports_soccer_rounded,
                      Icons.palette_rounded,
                    ],
                  ),
                  _OnboardingPage(
                    icon: Icons.newspaper_rounded,
                    iconColor: AppColors.secondary,
                    accentColor: AppColors.secondary,
                    title: 'Stay Informed',
                    description:
                        'Get the latest news and announcements from your local government and community organizations, all in one place.',
                    decorationIcons: const [
                      Icons.campaign_rounded,
                      Icons.notifications_rounded,
                      Icons.update_rounded,
                    ],
                  ),
                  _OnboardingPage(
                    icon: Icons.explore_rounded,
                    iconColor: AppColors.tertiary,
                    accentColor: AppColors.tertiary,
                    title: 'Find Resources',
                    description:
                        'Easily access important community resources, services, and contact information whenever you need them.',
                    decorationIcons: const [
                      Icons.local_library_rounded,
                      Icons.local_hospital_rounded,
                      Icons.park_rounded,
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.paddingXxxl,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? _getPageColor(_currentPage)
                              : Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withValues(alpha: 0.2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _currentPage < 2
                              ? FilledButton(
                                  key: const ValueKey('next'),
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeOutCubic,
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _getPageColor(_currentPage),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppSpacing.borderRadiusLg,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      AppSpacing.horizontalSm,
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                )
                              : FilledButton(
                                  key: const ValueKey('start'),
                                  onPressed: _completeOnboarding,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.tertiary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppSpacing.borderRadiusLg,
                                    ),
                                  ),
                                  child: Text(
                                    'Get Started',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPageColor(int page) {
    switch (page) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.secondary;
      case 2:
        return AppColors.tertiary;
      default:
        return AppColors.primary;
    }
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final String title;
  final String description;
  final List<IconData> decorationIcons;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.decorationIcons,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.15),
                        accentColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                _FloatingIcons(icons: decorationIcons, color: accentColor),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 56,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalLg,
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FloatingIcons extends StatelessWidget {
  final List<IconData> icons;
  final Color color;

  const _FloatingIcons({
    required this.icons,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: _StaticIcon(icon: icons[0], color: color),
          ),
          Positioned(
            top: 20,
            right: 5,
            child: _StaticIcon(icon: icons[1], color: color),
          ),
          Positioned(
            bottom: 15,
            left: 30,
            child: _StaticIcon(icon: icons[2], color: color),
          ),
        ],
      ),
    );
  }
}

class _StaticIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _StaticIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Icon(
        icon,
        size: 24,
        color: color.withValues(alpha: 0.6),
      ),
    );
  }
}
