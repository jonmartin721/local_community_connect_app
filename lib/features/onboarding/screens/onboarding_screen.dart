import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../shared/providers/hive_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              AppColors.primary.withValues(alpha: 0.03),
              AppColors.tertiary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed:
                          _currentPage < 2 ? _completeOnboarding : null,
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
              ),
              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    _OnboardingPage(
                      animationController: _animationController,
                      icon: Icons.calendar_month_rounded,
                      iconColor: AppColors.primary,
                      accentColor: AppColors.primary,
                      title: 'Discover Local Events',
                      description:
                          'Stay connected with your community through upcoming events, gatherings, and activities happening right in your neighborhood.',
                      decorationWidget: _FloatingIcons(
                        icons: const [
                          Icons.music_note_rounded,
                          Icons.sports_soccer_rounded,
                          Icons.palette_rounded,
                        ],
                        color: AppColors.primary,
                      ),
                    ),
                    _OnboardingPage(
                      animationController: _animationController,
                      icon: Icons.newspaper_rounded,
                      iconColor: AppColors.secondary,
                      accentColor: AppColors.secondary,
                      title: 'Stay Informed',
                      description:
                          'Get the latest news and announcements from your local government and community organizations, all in one place.',
                      decorationWidget: _FloatingIcons(
                        icons: const [
                          Icons.campaign_rounded,
                          Icons.notifications_rounded,
                          Icons.update_rounded,
                        ],
                        color: AppColors.secondary,
                      ),
                    ),
                    _OnboardingPage(
                      animationController: _animationController,
                      icon: Icons.explore_rounded,
                      iconColor: AppColors.tertiary,
                      accentColor: AppColors.tertiary,
                      title: 'Find Resources',
                      description:
                          'Easily access important community resources, services, and contact information whenever you need them.',
                      decorationWidget: _FloatingIcons(
                        icons: const [
                          Icons.local_library_rounded,
                          Icons.local_hospital_rounded,
                          Icons.park_rounded,
                        ],
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Page indicators and buttons
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Page indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final isActive = _currentPage == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
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
                        // Action button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _currentPage < 2
                                ? FilledButton(
                                    key: const ValueKey('next'),
                                    onPressed: () {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 400),
                                        curve: Curves.easeOutCubic,
                                      );
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          _getPageColor(_currentPage),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                        const SizedBox(width: 8),
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
                                        borderRadius: BorderRadius.circular(16),
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
  final AnimationController animationController;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final String title;
  final String description;
  final Widget decorationWidget;

  const _OnboardingPage({
    required this.animationController,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.decorationWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with decorations
          FadeTransition(
            opacity: CurvedAnimation(
              parent: animationController,
              curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animationController,
                  curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
                ),
              ),
              child: SizedBox(
                height: 200,
                width: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background glow
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
                    // Decorative floating icons
                    decorationWidget,
                    // Main icon container
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
            ),
          ),
          const SizedBox(height: 48),
          // Title
          FadeTransition(
            opacity: CurvedAnimation(
              parent: animationController,
              curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
              )),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          FadeTransition(
            opacity: CurvedAnimation(
              parent: animationController,
              curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
              )),
              child: Text(
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
            ),
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
          // Top left
          Positioned(
            top: 10,
            left: 10,
            child: _FloatingIcon(icon: icons[0], color: color, delay: 0),
          ),
          // Top right
          Positioned(
            top: 20,
            right: 5,
            child: _FloatingIcon(icon: icons[1], color: color, delay: 100),
          ),
          // Bottom
          Positioned(
            bottom: 15,
            left: 30,
            child: _FloatingIcon(icon: icons[2], color: color, delay: 200),
          ),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int delay;

  const _FloatingIcon({
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          widget.icon,
          size: 24,
          color: widget.color.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
