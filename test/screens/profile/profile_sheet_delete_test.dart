import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/error/failure.dart';
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
  when(
    () => _auth.reauthenticate(password: any(named: 'password')),
  ).thenAnswer((_) async => true);
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

  testWidgets('an account has it, and the dialog asks to confirm', (
    tester,
  ) async {
    await _open(tester, _social);
    await tester.tap(find.text('Excluir conta'));
    await tester.pumpAndSettle();

    expect(find.text('Excluir sua conta?'), findsOneWidget);
    expect(
      find.text(
        'Seu histórico e seus dados serão apagados. '
        'Isso não pode ser desfeito.',
      ),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    verifyNever(() => _accounts.deleteData(any()));
  });

  testWidgets('a password account is asked for the password', (tester) async {
    await _open(
      tester,
      _social.copyWith(usesPassword: true, emailVerified: true),
    );
    await tester.tap(find.text('Excluir conta'));
    await tester.pumpAndSettle();
    expect(find.text('Senha'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'secret123');
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    verify(() => _auth.reauthenticate(password: 'secret123')).called(1);
  });

  testWidgets('success closes the sheet and shows the SnackBar', (
    tester,
  ) async {
    await _open(tester, _social);
    await _confirm(tester);

    expect(find.byType(ProfileSheet), findsNothing);
    expect(find.text('Sua conta foi excluída.'), findsOneWidget);
    verifyInOrder([
      () => _auth.reauthenticate(),
      () => _accounts.deleteData('u1'),
      _auth.deleteAccount,
    ]);
  });

  testWidgets('an error keeps the sheet and shows the message', (tester) async {
    await _open(tester, _social);
    when(() => _accounts.deleteData(any())).thenThrow(const NetworkFailure());
    await _confirm(tester);

    expect(find.byType(ProfileSheet), findsOneWidget);
    expect(find.text('Sem conexão.'), findsOneWidget);
    expect(find.text('Excluir conta'), findsOneWidget);
  });

  testWidgets('closing the re-login sheet shows nothing', (tester) async {
    await _open(tester, _social);
    when(
      () => _auth.reauthenticate(password: any(named: 'password')),
    ).thenAnswer((_) async => false);
    await _confirm(tester);

    expect(find.byType(ProfileSheet), findsOneWidget);
    expect(find.text('Sua conta foi excluída.'), findsNothing);
    expect(find.text('Sem conexão.'), findsNothing);
  });
}
