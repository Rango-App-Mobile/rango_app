import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/screens/history/history_screen.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: GoRouter(
        initialLocation: '/history',
        routes: [
          GoRoute(
            path: '/history',
            builder: (_, _) => const HistoryScreen(),
          ),
          GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the empty state and the profile avatar', (tester) async {
    await _pump(tester);

    expect(find.text('Seu histórico'), findsOneWidget);
    expect(find.text('Seu primeiro rango'), findsOneWidget);
    expect(
      find.text(
        'Cada decisão aparece aqui, com a comida e o restaurante que você '
        'escolheu.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Abrir perfil'), findsOneWidget);
    expect(find.bySemanticsLabel('Voltar'), findsNothing);
  });

  testWidgets('"Decidir meu rango" goes to home', (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Decidir meu rango'));
    await tester.tap(find.text('Decidir meu rango'));
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
