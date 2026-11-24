import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/screens/profile/profile_sheet.dart';

void main() {
  testWidgets('"Como funciona o app" closes the sheet and opens the '
      'onboarding', (tester) async {
    tester.view
      ..physicalSize = const Size(402, 874)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => showProfileSheet(context),
              child: const Text('ABRIR'),
            ),
          ),
        ),
        GoRoute(path: '/onboarding', builder: (_, _) => const Text('TOUR')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.tap(find.text('ABRIR'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Como funciona o app'));
    await tester.pumpAndSettle();

    expect(find.text('TOUR'), findsOneWidget);
    expect(find.text('Como funciona o app'), findsNothing);
  });
}
