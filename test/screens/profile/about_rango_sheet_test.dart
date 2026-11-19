import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/data/app_info_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/data/fake_history_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/screens/profile/profile_sheet.dart';

const _account = AppUser(
  uid: 'u1',
  isAnonymous: false,
  name: 'Joana',
  email: 'joana@email.com',
);

class _MockAuthRepository extends Mock implements AuthRepository {
  _MockAuthRepository() {
    when(reload).thenAnswer((_) async {});
    when(resendVerification).thenAnswer((_) async {});
  }
}

class _FakeAppInfoRepository implements AppInfoRepository {
  @override
  Future<String> fetchVersion() async => '1.2.3';
}

class _FailOnceAppInfoRepository implements AppInfoRepository {
  int calls = 0;

  @override
  Future<String> fetchVersion() async {
    calls++;
    if (calls == 1) throw StateError('temporary platform failure');
    return '1.2.3';
  }
}

AuthRepository _stub(AppUser user) {
  final repository = _MockAuthRepository();
  when(repository.watchUser).thenAnswer((_) => Stream.value(user));
  when(repository.signOut).thenAnswer((_) async => FakeAuthRepository.user);
  return repository;
}

Future<void> _openProfile(
  WidgetTester tester, {
  required AuthRepository authRepository,
  AppInfoRepository? appInfoRepository,
}) async {
  tester.view
    ..physicalSize = const Size(402, 874)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        appInfoRepositoryProvider.overrideWithValue(
          appInfoRepository ?? _FakeAppInfoRepository(),
        ),
        historyRepositoryProvider.overrideWithValue(
          FakeHistoryRepository(entries: const []),
        ),
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
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

Future<void> _openAbout(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Sobre o Rango'));
  await tester.tap(find.text('Sobre o Rango'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a guest can open About and see the installed version', (
    tester,
  ) async {
    await _openProfile(tester, authRepository: FakeAuthRepository());

    expect(find.text('Sobre o Rango'), findsOneWidget);
    await _openAbout(tester);

    expect(find.text('Versão 1.2.3'), findsOneWidget);
    expect(
      find.text(
        'O Rango ajuda você a decidir o que comer e encontrar '
        'restaurantes próximos.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('an account can open About', (tester) async {
    await _openProfile(tester, authRepository: _stub(_account));

    expect(find.text('Sobre o Rango'), findsOneWidget);
    await _openAbout(tester);

    expect(find.text('Versão 1.2.3'), findsOneWidget);
  });

  testWidgets('can retry when the version is temporarily unavailable', (
    tester,
  ) async {
    final repository = _FailOnceAppInfoRepository();
    await _openProfile(
      tester,
      authRepository: FakeAuthRepository(),
      appInfoRepository: repository,
    );

    await _openAbout(tester);

    expect(find.text('Não foi possível carregar a versão.'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Versão 1.2.3'), findsOneWidget);
    expect(repository.calls, 2);
  });
}
