import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_text_field.dart';
import 'package:rango_app/data/auth_repository.dart';

/// Opens [route] over a HOME page, so the screen can pop back to it. The other
/// account routes are text stubs, replaced by [screens].
Future<void> pumpAuthScreen(
  WidgetTester tester, {
  required String route,
  required AuthRepository repository,
  required Map<String, Widget Function(Object? extra)> screens,
}) async {
  tester.view
    ..physicalSize = const Size(402, 874)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  Widget stub(String name, Object? extra) =>
      Scaffold(body: Text(extra == null ? name : '$name $extra'));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, _) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.push(route),
                    child: const Text('HOME'),
                  ),
                ),
              ),
            ),
            for (final path in ['/login', '/signup', '/password-reset'])
              GoRoute(
                path: path,
                builder: (_, state) =>
                    screens[path]?.call(state.extra) ?? stub(path, state.extra),
              ),
          ],
        ),
      ),
    ),
  );
  await tester.tap(find.text('HOME'));
  await tester.pumpAndSettle();
}

Future<void> typeIn(WidgetTester tester, String label, String text) =>
    tester.enterText(
      find.descendant(
        of: find.widgetWithText(RangoTextField, label),
        matching: find.byType(TextField),
      ),
      text,
    );

Future<void> tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(RangoButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// What the back gesture does: pops the top route.
Future<void> goBack(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(Scaffold).last)).pop();
  await tester.pumpAndSettle();
}
