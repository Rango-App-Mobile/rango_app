import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/data/delivery_link_repository.dart';
import 'package:rango_app/data/external_link_launcher.dart';
import 'package:rango_app/data/fake_delivery_link_repository.dart';
import 'package:rango_app/data/fake_external_link_launcher.dart';
import 'package:rango_app/data/fake_restaurant_repository.dart';
import 'package:rango_app/data/restaurant_repository.dart';
import 'package:rango_app/models/delivery_links.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/models/restaurant_contact_args.dart';
import 'package:rango_app/screens/restaurant_contact/restaurant_contact_screen.dart';

class _PhoneRepository extends FakeRestaurantRepository {
  _PhoneRepository(this.phone);

  final String? phone;

  @override
  Future<String?> fetchPhone(String placeId) async => phone;
}

const _args = RestaurantContactArgs(
  restaurant: Restaurant(
    placeId: 'p1',
    name: 'Cantina da Nona',
    location: GeoPoint(lat: 0, lng: 0),
    cuisine: 'Restaurante italiano',
    address: 'Rua A, 10',
    rating: 4.6,
    distanceMeters: 850,
  ),
);

Future<FakeExternalLinkLauncher> pumpScreen(
  WidgetTester tester, {
  String? phone,
  bool launchSucceeds = true,
  Size size = const Size(402, 874),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final launcher = FakeExternalLinkLauncher(succeeds: launchSucceeds);
  final router = GoRouter(
    initialLocation: '/map',
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
      GoRoute(
        path: '/map',
        builder: (context, _) => Scaffold(
          body: TextButton(
            onPressed: () => context.push('/contact', extra: _args),
            child: const Text('MAP'),
          ),
        ),
      ),
      GoRoute(
        path: '/contact',
        builder: (_, state) => RestaurantContactScreen(
          args: state.extra! as RestaurantContactArgs,
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        restaurantRepositoryProvider.overrideWithValue(_PhoneRepository(phone)),
        deliveryLinkRepositoryProvider.overrideWithValue(
          FakeDeliveryLinkRepository({
            'p1': const DeliveryLinks(ifood: 'https://ifood.com.br/x'),
          }),
        ),
        externalLinkLauncherProvider.overrideWithValue(launcher),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('MAP'));
  await tester.pumpAndSettle();
  return launcher;
}

void main() {
  testWidgets('renders the card, heading and delivery button', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Cantina da Nona'), findsOneWidget);
    expect(find.text('Restaurante italiano. Rua A, 10'), findsOneWidget);
    expect(find.text('4,6'), findsOneWidget);
    expect(find.text('850 m'), findsOneWidget);
    expect(find.text('Como você quer pedir?'), findsOneWidget);
    expect(find.text('Pedir no delivery'), findsOneWidget);
    expect(find.text('Voltar ao início'), findsOneWidget);
  });

  testWidgets('guest sees no map, history chip or history shortcut', (
    tester,
  ) async {
    await pumpScreen(tester, phone: '5133330000');

    expect(find.text('Abrir no mapa'), findsNothing);
    expect(find.text('Salvo no seu histórico'), findsNothing);
    expect(find.text('Ir para o histórico'), findsNothing);
  });

  testWidgets('"Ligar" is hidden without a phone', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Ligar'), findsNothing);
  });

  testWidgets('"Ligar" shows with a phone and dials it', (tester) async {
    final launcher = await pumpScreen(tester, phone: '(51) 3333-0000');

    expect(find.text('Ligar'), findsOneWidget);
    await tester.tap(find.text('Ligar'));
    await tester.pumpAndSettle();
    expect(launcher.opened, [Uri.parse('tel:5133330000')]);
  });

  testWidgets('"Pedir no delivery" opens the registered link', (tester) async {
    final launcher = await pumpScreen(tester);

    await tester.tap(find.text('Pedir no delivery'));
    await tester.pumpAndSettle();
    expect(launcher.opened, [Uri.parse('https://ifood.com.br/x')]);
  });

  testWidgets('back pops to the previous route', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('MAP'), findsOneWidget);
    expect(find.text('Pedir no delivery'), findsNothing);
  });

  testWidgets('"Voltar ao início" goes home', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Voltar ao início'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('shows a SnackBar when the app cannot be opened', (tester) async {
    await pumpScreen(tester, launchSucceeds: false);

    await tester.tap(find.text('Pedir no delivery'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Não deu para abrir. Tente de novo.'), findsOneWidget);
  });

  testWidgets('does not overflow on a 375x667 screen', (tester) async {
    await pumpScreen(tester, phone: '5133330000', size: const Size(375, 667));
    expect(tester.takeException(), isNull);
  });
}
