import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/screens/startup/startup_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('shows the error with a retry button that tries again', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    var calls = 0;
    when(repository.ensureSignedIn).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw const NetworkFailure();
      return const AppUser(uid: 'uid', isAnonymous: true);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: StartupScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sem conexão.'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    // Ready again: the spinner keeps animating until RangoApp swaps this
    // screen for the router, so pumpAndSettle would never settle.
    await tester.pump();
    await tester.pump();

    expect(calls, 2);
    expect(find.text('Tentar novamente'), findsNothing);
  });
}
