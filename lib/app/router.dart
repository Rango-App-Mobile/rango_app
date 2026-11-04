import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/app_shell.dart';
import 'package:rango_app/models/restaurant_contact_args.dart';
import 'package:rango_app/screens/history/history_screen.dart';
import 'package:rango_app/screens/restaurant_contact/restaurant_contact_screen.dart';
import 'package:rango_app/screens/restaurants/restaurants_screen.dart';
import 'package:rango_app/screens/result/result_screen.dart';
import 'package:rango_app/screens/swipe/swipe_screen.dart';

/// Provider (not a global) so the auth story can add a `redirect`
/// that watches the auth state later.
///
/// Home and Histórico are the two tab branches (with the Tab Bar). Everything
/// else is pushed on the root navigator, above the shell, so it is full screen.
final routerProvider = Provider<GoRouter>((ref) {
  // One key per router: a key shared at file level would clash if the
  // provider is rebuilt (another ProviderScope, hot restart).
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const SwipeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/choose',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SwipeScreen(mode: SwipeMode.flow),
      ),
      GoRoute(
        path: '/result',
        parentNavigatorKey: rootKey,
        builder: (context, state) => ResultScreen(
          pathIds: (state.uri.queryParameters['path'] ?? '')
              .split(',')
              .where((id) => id.isNotEmpty)
              .toList(),
        ),
      ),
      GoRoute(
        path: '/restaurants',
        parentNavigatorKey: rootKey,
        builder: (context, state) => RestaurantsScreen(
          categoryId: state.uri.queryParameters['category'],
        ),
      ),
      // Pushed from the map with the chosen restaurant in `extra`, so popping
      // returns to the same map. `extra` does not survive a cold deep link:
      // without it there is nothing to show, so go home.
      GoRoute(
        path: '/restaurants/contact',
        parentNavigatorKey: rootKey,
        redirect: (context, state) =>
            state.extra is RestaurantContactArgs ? null : '/home',
        builder: (context, state) => switch (state.extra) {
          final RestaurantContactArgs args => RestaurantContactScreen(
            args: args,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    ],
  );
});
