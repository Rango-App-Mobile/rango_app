import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/core/widgets/rango_loading_view.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/screens/profile/profile_sheet.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

const _social = AppUser(
  uid: 'u1',
  isAnonymous: false,
  name: 'Joana',
  email: 'joana@email.com',
);

late _MockAuthRepository _auth;
late _MockAccountRepository _accounts;

Future<void> _open(WidgetTester tester, AppUser user) async {
  tester.view
    ..physicalSize = const Size(402, 874)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _auth = _MockAuthRepository();
  _accounts = _MockAccountRepository();
  when(_auth.reload).thenAnswer((_) async {});
  when(_auth.watchUser).thenAnswer((_) => Stream.value(user));
  when(_auth.ensureSignedIn).thenAnswer((_) async => user);
  when(_auth.refreshLoginSilently).thenAnswer((_) async => true);
  when(() => _accounts.deleteData(any())).thenAnswer((_) async {});
  when(_auth.deleteAccount).thenAnswer((_) async => FakeAuthRepository.user);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_auth),
        accountRepositoryProvider.overrideWithValue(_accounts),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showProfileSheet(context),
                child: const Text('ABRIR'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('ABRIR'));
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.text('Excluir conta'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Excluir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a guest has no delete row', (tester) async {
    await _open(tester, FakeAuthRepository.user);

    expect(find.text('Excluir conta'), findsNothing);
  });

  testWidgets('an account has it, and the dialog only asks to confirm', (
    tester,
  ) async {
    await _open(tester, _social.copyWith(usesPassword: true));
    await tester.tap(find.text('Excluir conta'));
    await tester.pumpAndSettle();

    expect(find.text('Excluir sua conta?'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    verifyNever(() => _accounts.deleteData(any()));
  });

  testWidgets('while deleting, the loading covers the whole screen', (
    tester,
  ) async {
    await _open(tester, _social);
    final gate = Completer<void>();
    when(() => _accounts.deleteData(any())).thenAnswer((_) => gate.future);
    await tester.tap(find.text('Excluir conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pump();
    await tester.pump();

    final loading = find.byType(RangoLoadingView);
    expect(loading, findsOneWidget);
    expect(tester.getSize(loading), const Size(402, 874));
    expect(
      find.descendant(of: find.byType(ProfileSheet), matching: loading),
      findsNothing,
    );

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('success closes everything and leaves nothing behind', (
    tester,
  ) async {
    await _open(tester, _social);
    await _confirm(tester);

    expect(find.byType(ProfileSheet), findsNothing);
    expect(find.byType(RangoLoadingView), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    verifyInOrder([
      () => _accounts.deleteData('u1'),
      _auth.deleteAccount,
    ]);
  });

  testWidgets('an error closes the loading and explains in an alert', (
    tester,
  ) async {
    await _open(tester, _social);
    when(() => _accounts.deleteData(any())).thenThrow(const NetworkFailure());
    await _confirm(tester);

    expect(find.byType(RangoLoadingView), findsNothing);
    expect(find.text('Não deu para excluir'), findsOneWidget);
    expect(find.text('Sem conexão.'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSheet), findsOneWidget);
  });
}
