import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/widgets/scrim.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/data/fake_history_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/models/history_entry.dart';
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

class _FailOnceHistoryRepository implements HistoryRepository {
  _FailOnceHistoryRepository(this.entries);

  final List<HistoryEntry> entries;
  int requests = 0;

  @override
  Future<List<HistoryEntry>> fetchAll(String uid) async {
    requests++;
    if (requests == 1) throw const NetworkFailure();
    return entries;
  }

  @override
  Future<void> save(String uid, HistoryEntry entry) async {}
}

class _PendingHistoryRepository implements HistoryRepository {
  final _entries = Completer<List<HistoryEntry>>();

  void complete(List<HistoryEntry> entries) => _entries.complete(entries);

  @override
  Future<List<HistoryEntry>> fetchAll(String uid) => _entries.future;

  @override
  Future<void> save(String uid, HistoryEntry entry) async {}
}

AuthRepository _stub(AppUser user) {
  final repository = _MockAuthRepository();
  when(repository.watchUser).thenAnswer((_) => Stream.value(user));
  when(repository.signOut).thenAnswer((_) async => FakeAuthRepository.user);
  return repository;
}

Future<void> _open(
  WidgetTester tester, {
  AuthRepository? repository,
  HistoryRepository? historyRepository,
  CategoryRepository? categoryRepository,
  Size size = const Size(402, 874),
  bool disableAnimations = false,
  double textScale = 1,
  bool settle = true,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository ?? _stub(_account)),
        historyRepositoryProvider.overrideWithValue(
          historyRepository ?? FakeHistoryRepository(entries: const []),
        ),
        categoryRepositoryProvider.overrideWithValue(
          categoryRepository ?? LocalCategoryRepository(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
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
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<void> _openGuest(WidgetTester tester, {Size? size}) => _open(
  tester,
  repository: FakeAuthRepository(),
  size: size ?? const Size(402, 874),
);

void main() {
  group('terms and privacy', () {
    Future<void> opensTheTerms(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Termos e Privacidade'));
      await tester.tap(find.text('Termos e Privacidade'));
      await tester.pumpAndSettle();

      expect(
        find.text('Termos de Uso e Política de Privacidade'),
        findsOneWidget,
      );
    }

    testWidgets('a guest can read them', (tester) async {
      await _openGuest(tester);
      await opensTheTerms(tester);
    });

    testWidgets('an account can read them', (tester) async {
      await _open(tester);
      await opensTheTerms(tester);
    });
  });

  group('opening', () {
    testWidgets('slides up over a 45% veil, with sheet radius', (tester) async {
      await _openGuest(tester);

      final barrier = tester.widget<ModalBarrier>(
        find.byType(ModalBarrier).last,
      );
      expect(
        barrier.color,
        AppColors.light.bgInverse.withValues(alpha: Scrim.modalOpacity),
      );

      final material = tester.widget<Material>(
        find
            .ancestor(
              of: find.byType(ProfileSheet),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, AppColors.light.bgCanvas);
      expect(
        material.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      );
    });

    testWidgets('sits at the bottom of the screen', (tester) async {
      await _openGuest(tester);

      expect(tester.getBottomLeft(find.byType(ProfileSheet)).dy, 874);
    });

    testWidgets('takes 350 ms to open', (tester) async {
      tester.view
        ..physicalSize = const Size(402, 874)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(FakeAuthRepository()));

      await tester.tap(find.text('ABRIR'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final midway = _sheetTop(tester);

      await tester.pump(const Duration(milliseconds: 60));
      final opened = _sheetTop(tester);
      expect(midway, greaterThan(opened));

      await tester.pumpAndSettle();
      expect(_sheetTop(tester), opened);
    });

    testWidgets('opens at once with reduced motion', (tester) async {
      tester.view
        ..physicalSize = const Size(402, 874)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(FakeAuthRepository(), reduceMotion: true));

      await tester.tap(find.text('ABRIR'));
      await tester.pump();
      await tester.pump();
      final opened = _sheetTop(tester);

      await tester.pumpAndSettle();
      expect(_sheetTop(tester), opened);
    });
  });

  group('closing', () {
    testWidgets('closes through the X button', (tester) async {
      await _openGuest(tester);

      await tester.tap(find.bySemanticsLabel('Fechar perfil'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileSheet), findsNothing);
    });

    testWidgets('closes by tapping the veil', (tester) async {
      await _openGuest(tester);

      await tester.tapAt(const Offset(201, 40));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileSheet), findsNothing);
    });

    testWidgets('closes by dragging down', (tester) async {
      await _openGuest(tester);

      await tester.drag(find.text('Visitante'), const Offset(0, 400));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileSheet), findsNothing);
    });
  });

  group('guest', () {
    testWidgets('shows the name and the invitation to sign in', (tester) async {
      await _openGuest(tester);

      expect(find.text('Visitante'), findsOneWidget);
      expect(find.text('Sessão anônima neste aparelho'), findsOneWidget);
      expect(find.text('Entrar ou criar conta'), findsOneWidget);
      expect(
        find.text('Sem conta, seus rangos não ficam salvos.'),
        findsOneWidget,
      );
    });

    testWidgets('shows no statistics and no preferences', (tester) async {
      await _openGuest(tester);

      for (final absent in [
        'rangos decididos',
        'comida favorita',
        'restaurante favorito',
        'Preferências',
        'Localização',
        'Notificações',
        'App de delivery',
        'Apagar meus dados',
      ]) {
        expect(find.text(absent), findsNothing, reason: absent);
      }
    });

    testWidgets('the invitation closes the sheet and opens the login', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: GoRouter(
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
                GoRoute(path: '/login', builder: (_, _) => const Text('LOGIN')),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('ABRIR'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar ou criar conta'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileSheet), findsNothing);
      expect(find.text('LOGIN'), findsOneWidget);
    });

    testWidgets('falls back to guest when the session fails', (tester) async {
      final repository = _MockAuthRepository();
      when(
        repository.watchUser,
      ).thenAnswer((_) => Stream.error(StateError('no session')));
      await _open(tester, repository: repository);

      expect(find.text('Visitante'), findsOneWidget);
    });
  });

  group('statistics', () {
    testWidgets('shows the count and the most recent favorites', (
      tester,
    ) async {
      await _open(
        tester,
        historyRepository: FakeHistoryRepository(
          entries: FakeHistoryRepository.sample,
        ),
      );

      expect(find.text('9'), findsOneWidget);
      expect(find.text('Macarrão'), findsOneWidget);
      expect(find.text('Cantina da Nona'), findsOneWidget);
      expect(find.text('rangos decididos'), findsOneWidget);
      expect(find.text('comida favorita'), findsOneWidget);
      expect(find.text('restaurante favorito'), findsOneWidget);
      expect(
        find.text('Com base nas até 100 decisões mais recentes.'),
        findsOneWidget,
      );
    });

    testWidgets('shows the count for the full 100-decision window', (
      tester,
    ) async {
      final entries = List<HistoryEntry>.generate(
        100,
        (index) => FakeHistoryRepository
            .sample[index % FakeHistoryRepository.sample.length]
            .copyWith(id: 'h$index'),
      );
      await _open(
        tester,
        historyRepository: FakeHistoryRepository(entries: entries),
      );

      expect(find.text('100'), findsOneWidget);
      expect(
        find.text('Com base nas até 100 decisões mais recentes.'),
        findsOneWidget,
      );
    });

    testWidgets('shows neutral values when the account has no decisions', (
      tester,
    ) async {
      await _open(tester);

      expect(find.text('0'), findsNothing);
      expect(find.text('—'), findsNWidgets(3));
    });

    testWidgets('loading stats fit a small screen with large text', (
      tester,
    ) async {
      final repository = _PendingHistoryRepository();
      await _open(
        tester,
        historyRepository: repository,
        size: const Size(320, 480),
        textScale: 2,
        settle: false,
      );

      expect(find.text('Carregando estatísticas…'), findsOneWidget);
      expect(tester.takeException(), isNull);

      repository.complete(const []);
      await tester.pumpAndSettle();
    });

    testWidgets('shows a retry when the history cannot be loaded', (
      tester,
    ) async {
      final repository = _FailOnceHistoryRepository(
        FakeHistoryRepository.sample,
      );
      await _open(tester, historyRepository: repository);

      expect(
        find.text('Não foi possível carregar as estatísticas.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      expect(repository.requests, 2);
      expect(find.text('9'), findsOneWidget);
    });
  });

  group('with an account', () {
    testWidgets('shows the name and e-mail, without the invitation', (
      tester,
    ) async {
      await _open(tester);

      expect(find.text('Joana'), findsOneWidget);
      expect(find.text('joana@email.com'), findsOneWidget);
      expect(find.text('Visitante'), findsNothing);
      expect(find.text('Entrar ou criar conta'), findsNothing);
    });

    testWidgets('signs out through Sair da conta', (tester) async {
      final repository = _stub(_account);
      await _open(tester, repository: repository);

      await tester.tap(find.text('Sair da conta'));
      await tester.pump();

      verify(repository.signOut).called(1);
    });

    testWidgets('draws the photo when there is one', (tester) async {
      await _open(
        tester,
        repository: _stub(
          const AppUser(
            uid: 'u1',
            isAnonymous: false,
            name: 'Joana',
            photoUrl: 'https://example.com/joana.png',
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as NetworkImage).url,
        'https://example.com/joana.png',
      );
    });

    testWidgets('without a photo, draws the guest icon', (tester) async {
      await _open(tester);

      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('a long name does not overflow, and X stays visible', (
      tester,
    ) async {
      await _open(
        tester,
        repository: _stub(
          const AppUser(
            uid: 'u1',
            isAnonymous: false,
            name: 'Maria Eduarda dos Santos Albuquerque de Oliveira',
            email: 'maria.eduarda.santos.albuquerque.oliveira@email.com',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Fechar perfil'), findsOneWidget);
    });
  });

  testWidgets('fits a small screen with large text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 480)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(FakeAuthRepository(), textScale: 2));

    await tester.tap(find.text('ABRIR'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Fechar perfil'), findsOneWidget);
  });
}

double _sheetTop(WidgetTester tester) =>
    tester.getTopLeft(find.byType(ProfileSheet)).dy;

Widget _host(
  AuthRepository repository, {
  bool reduceMotion = false,
  double textScale = 1,
}) => ProviderScope(
  overrides: [authRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations: reduceMotion,
        textScaler: TextScaler.linear(textScale),
      ),
      child: child!,
    ),
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
);
