import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/scrim.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/screens/profile/profile_sheet.dart';

const _account = AppUser(
  uid: 'u1',
  isAnonymous: false,
  name: 'Joana',
  email: 'joana@email.com',
);

class _MockAuthRepository extends Mock implements AuthRepository {}

class _StubAuthRepository implements AuthRepository {
  const _StubAuthRepository(this.user);

  final AppUser user;

  @override
  Future<AppUser> ensureSignedIn() async => user;
}

Future<void> _open(
  WidgetTester tester, {
  AuthRepository repository = const _StubAuthRepository(_account),
  Size size = const Size(402, 874),
  bool disableAnimations = false,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
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
  await tester.pumpAndSettle();
}

Future<void> _openGuest(WidgetTester tester, {Size? size}) => _open(
  tester,
  repository: FakeAuthRepository(),
  size: size ?? const Size(402, 874),
);

void main() {
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

    testWidgets('the invitation is disabled until sign-in exists (#E1-S3)', (
      tester,
    ) async {
      await _openGuest(tester);

      final button = tester.widget<RangoButton>(find.byType(RangoButton));
      expect(button.style, RangoButtonStyle.secondary);
      expect(button.onPressed, isNull);
    });

    testWidgets('falls back to guest when the session fails', (tester) async {
      final repository = _MockAuthRepository();
      when(repository.ensureSignedIn).thenAnswer((_) async {
        throw StateError('no session');
      });
      await _open(tester, repository: repository);

      expect(find.text('Visitante'), findsOneWidget);
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

    testWidgets('draws the photo when there is one', (tester) async {
      await _open(
        tester,
        repository: const _StubAuthRepository(
          AppUser(
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
        repository: const _StubAuthRepository(
          AppUser(
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
