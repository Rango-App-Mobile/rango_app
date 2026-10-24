import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/screens/restaurants/restaurants_screen.dart';

Future<void> _pump(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/restaurants',
    routes: [
      GoRoute(
        path: '/restaurants',
        builder: (_, s) => const RestaurantsScreen(categoryId: 'spaghetti'),
      ),
      GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the placeholder and back button, no profile', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Restaurantes em breve'), findsOneWidget);
    expect(find.bySemanticsLabel('Voltar'), findsOneWidget);
    expect(find.bySemanticsLabel('Abrir perfil'), findsNothing);
  });

  testWidgets('top bar back goes to home', (tester) async {
    await _pump(tester);

    await tester.tap(find.bySemanticsLabel('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('Voltar ao início goes to home', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Voltar ao início'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('does not overflow at 375x667', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester);

    expect(tester.takeException(), isNull);
  });
}
