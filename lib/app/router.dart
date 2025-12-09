import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/events/screens/events_screen.dart';
import '../features/events/screens/event_detail_screen.dart';
import '../features/news/screens/news_screen.dart';
import '../features/news/screens/news_detail_screen.dart';
import '../features/resources/screens/resources_screen.dart';
import '../features/resources/screens/resource_detail_screen.dart';
import '../features/favorites/screens/favorites_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/location_setup_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../shared/widgets/bottom_nav_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({required bool showOnboarding}) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: showOnboarding ? '/onboarding' : '/events',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/location-setup',
      builder: (context, state) {
        final isOnboarding = state.uri.queryParameters['onboarding'] == 'true';
        return LocationSetupScreen(isOnboarding: isOnboarding);
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => BottomNavShell(child: child),
      routes: [
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                if (id == null || id.isEmpty) {
                  return const EventsScreen();
                }
                return EventDetailScreen(eventId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/news',
          builder: (context, state) => const NewsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                if (id == null || id.isEmpty) {
                  return const NewsScreen();
                }
                return NewsDetailScreen(newsId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/resources',
          builder: (context, state) => const ResourcesScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                if (id == null || id.isEmpty) {
                  return const ResourcesScreen();
                }
                return ResourceDetailScreen(resourceId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
      ],
    ),
  ],
);
