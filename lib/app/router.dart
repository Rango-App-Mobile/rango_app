import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/screens/swipe/swipe_screen.dart';

/// Provider (not a global) so the auth story can add a `redirect`
/// that watches the auth state later.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SwipeScreen(),
      ),
    ],
  );
});
