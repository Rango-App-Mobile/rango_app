import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/core/widgets/restaurant_card.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_location_repository.dart';
import 'package:rango_app/data/fake_restaurant_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/data/location_repository.dart';
import 'package:rango_app/data/restaurant_repository.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/models/restaurant_contact_args.dart';
import 'package:rango_app/screens/restaurants/restaurants_screen.dart';
import 'package:rango_app/screens/restaurants/widgets/map_credit.dart';
import 'package:rango_app/screens/restaurants/widgets/osm_restaurant_map.dart';
import 'package:rango_app/screens/restaurants/widgets/restaurant_map.dart';

class _MockLocation extends Mock implements LocationRepository {}

class _MockRestaurants extends Mock implements RestaurantRepository {}

const GeoPoint _origin = FakeLocationRepository.point;

LocationRepository _fakeLocation() => const FakeLocationRepository();

/// Keeps the tests off the network: every tile is a transparent pixel.
class _BlankTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(TileProvider.transparentImage);
}

Future<void> _pump(
  WidgetTester tester, {
  LocationRepository? location,
  RestaurantRepository? restaurants,
  Size size = const Size(402, 874),
  bool settle = true,
  bool useTileMap = false,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/restaurants',
    routes: [
      GoRoute(
        path: '/restaurants',
        builder: (_, _) => const RestaurantsScreen(categoryId: 'spaghetti'),
      ),
      GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
      GoRoute(
        path: '/restaurants/contact',
        builder: (_, state) {
          final args = state.extra! as RestaurantContactArgs;
          return Text('CONTACT ${args.restaurant.name} ${args.foodTheme}');
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        locationRepositoryProvider.overrideWithValue(
          location ?? _fakeLocation(),
        ),
        restaurantRepositoryProvider.overrideWithValue(
          restaurants ?? FakeRestaurantRepository(),
        ),
        useTileMapProvider.overrideWithValue(useTileMap),
        tileProviderFactoryProvider.overrideWithValue(_BlankTiles.new),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        // The user-location halo pulses forever; reduced motion lets
        // pumpAndSettle finish.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

_MockLocation _denying(Failure failure) {
  final location = _MockLocation();
  when(location.currentPosition).thenThrow(failure);
  when(location.openAppSettings).thenAnswer((_) async {});
  when(location.openLocationSettings).thenAnswer((_) async {});
  return location;
}

Finder _pin(String name) => find.bySemanticsLabel(RegExp('^$name, nota'));

void main() {
  setUpAll(() => registerFallbackValue(_origin));

  group('tile map', () {
    testWidgets('is the default map', (tester) async {
      final container = ProviderContainer.test();

      expect(container.read(useTileMapProvider), isTrue);
    });

    testWidgets('credits OpenStreetMap above the preview card', (tester) async {
      await _pump(tester, useTileMap: true);

      expect(find.byType(OsmRestaurantMap), findsOneWidget);
      final credit = tester.getRect(find.byType(MapCredit));
      final card = tester.getRect(find.byType(RestaurantCard));
      expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
      expect(credit.bottom, lessThanOrEqualTo(card.top));
    });

    testWidgets('credits OpenStreetMap while still searching', (tester) async {
      final restaurants = _MockRestaurants();
      when(
        () => restaurants.search(
          keyword: any(named: 'keyword'),
          near: any(named: 'near'),
        ),
      ).thenAnswer((_) => Completer<List<Restaurant>>().future);

      await _pump(tester, restaurants: restaurants, useTileMap: true);

      expect(find.byType(MapCredit), findsOneWidget);
      expect(find.byType(RestaurantCard), findsNothing);
    });

    testWidgets('fits the credit and the recenter button on a small phone', (
      tester,
    ) async {
      await _pump(tester, size: const Size(375, 667), useTileMap: true);

      expect(tester.takeException(), isNull);
      final credit = tester.getRect(find.byType(MapCredit));
      final recenter = tester.getRect(
        find.bySemanticsLabel('Centralizar em você'),
      );
      expect(credit.right, lessThanOrEqualTo(recenter.left));
    });

    testWidgets('the drawn map needs no credit', (tester) async {
      await _pump(tester);

      expect(find.byType(MapCredit), findsNothing);
    });
  });

  group('map', () {
    testWidgets('shows the searching chip until the search answers', (
      tester,
    ) async {
      final pending = Completer<List<Restaurant>>();
      final restaurants = _MockRestaurants();
      when(
        () => restaurants.search(
          keyword: any(named: 'keyword'),
          near: any(named: 'near'),
        ),
      ).thenAnswer((_) => pending.future);

      await _pump(tester, restaurants: restaurants);

      expect(find.text('Procurando macarrão perto de você'), findsOneWidget);
      expect(find.bySemanticsLabel('Você está aqui'), findsOneWidget);
      expect(find.bySemanticsLabel('Centralizar em você'), findsNothing);
      expect(find.textContaining('lugares em até 3 km'), findsNothing);

      pending.complete([
        const Restaurant(
          placeId: 'p1',
          name: 'Só Um',
          location: GeoPoint(lat: -30.027, lng: -51.228),
          rating: 4.5,
          distanceMeters: 120,
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.textContaining('Procurando'), findsNothing);
      expect(find.text('1 lugar em até 3 km'), findsOneWidget);
    });

    testWidgets('shows the pins, the count chip and the nearest preview', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Macarrão'), findsOneWidget);
      expect(find.text('7 lugares em até 3 km'), findsOneWidget);
      expect(find.bySemanticsLabel('Centralizar em você'), findsOneWidget);
      // Nearest restaurant: balloon on the pin and the preview card.
      expect(find.text('Cantina da Nona ★ 4,6'), findsOneWidget);
      expect(find.text('Cantina da Nona'), findsOneWidget);
      expect(find.text('Restaurante italiano'), findsOneWidget);
      expect(_pin('Bistrô do Centro'), findsOneWidget);
    });

    testWidgets('tapping another pin selects only that one', (tester) async {
      await _pump(tester);

      await tester.tap(_pin('Forno e Lenha'));
      await tester.pumpAndSettle();

      expect(find.text('Forno e Lenha ★ 4,7'), findsOneWidget);
      expect(find.text('Forno e Lenha'), findsOneWidget); // preview
      expect(find.text('Cantina da Nona ★ 4,6'), findsNothing);
      expect(find.text('Cantina da Nona'), findsNothing);
      expect(find.textContaining('★'), findsOneWidget);
    });

    testWidgets('tapping the preview opens the contact screen', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Restaurante italiano'));
      await tester.pumpAndSettle();

      expect(find.text('CONTACT Cantina da Nona lime'), findsOneWidget);
    });

    testWidgets('tapping the selected pin opens the contact screen', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.bySemanticsLabel(RegExp('^Cantina da Nona, nota')));
      await tester.pumpAndSettle();

      expect(find.textContaining('CONTACT Cantina da Nona'), findsOneWidget);
    });

    testWidgets('keeps the selection when coming back from contact', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(_pin('Forno e Lenha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Forno e Lenha'));
      await tester.pumpAndSettle();
      expect(find.textContaining('CONTACT Forno e Lenha'), findsOneWidget);

      tester
          .element(find.textContaining('CONTACT'))
          .pop(); // back to the map, as the system back would
      await tester.pumpAndSettle();

      expect(find.text('Forno e Lenha ★ 4,7'), findsOneWidget);
    });

    testWidgets('recenter button is there and tappable', (tester) async {
      await _pump(tester);
      await tester.tap(_pin('Forno e Lenha'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Centralizar em você'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Você está aqui'), findsOneWidget);
      expect(find.text('Forno e Lenha ★ 4,7'), findsOneWidget);
    });

    testWidgets('back goes home', (tester) async {
      await _pump(tester);

      await tester.tap(find.bySemanticsLabel('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('does not overflow at 375x667', (tester) async {
      await _pump(tester, size: const Size(375, 667));

      expect(tester.takeException(), isNull);
      expect(find.text('7 lugares em até 3 km'), findsOneWidget);
    });
  });

  group('location', () {
    testWidgets('denied shows screen 09 and Permitir retries', (tester) async {
      final location = _denying(const LocationDeniedFailure());
      await _pump(tester, location: location);

      expect(find.text('Precisamos da sua localização'), findsOneWidget);
      expect(find.text('Permitir localização'), findsOneWidget);
      expect(find.text('Abrir ajustes do celular'), findsOneWidget);

      when(location.currentPosition).thenAnswer((_) async => _origin);
      await tester.tap(find.text('Permitir localização'));
      await tester.pumpAndSettle();

      verify(location.currentPosition).called(2);
      expect(find.text('7 lugares em até 3 km'), findsOneWidget);
    });

    testWidgets('denied can open the phone settings', (tester) async {
      final location = _denying(const LocationDeniedFailure());
      await _pump(tester, location: location);

      await tester.tap(find.text('Abrir ajustes do celular'));
      await tester.pumpAndSettle();

      verify(location.openAppSettings).called(1);
    });

    testWidgets('denied forever: the primary button opens the settings', (
      tester,
    ) async {
      final location = _denying(const LocationDeniedForeverFailure());
      await _pump(tester, location: location);

      expect(find.text('Permitir localização'), findsNothing);
      await tester.tap(find.text('Abrir ajustes do celular'));
      await tester.pumpAndSettle();

      verify(location.openAppSettings).called(1);

      await tester.tap(find.text('Voltar ao início'));
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('location off opens the location settings', (tester) async {
      final location = _denying(const LocationServiceDisabledFailure());
      await _pump(tester, location: location);

      expect(find.text('Sua localização está desligada'), findsOneWidget);
      await tester.tap(find.text('Abrir ajustes de localização'));
      await tester.pumpAndSettle();

      verify(location.openLocationSettings).called(1);
      expect(find.text('Tentar de novo'), findsOneWidget);
    });

    testWidgets('denied does not overflow at 375x667', (tester) async {
      await _pump(
        tester,
        location: _denying(const LocationDeniedFailure()),
        size: const Size(375, 667),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Abrir ajustes do celular'), findsOneWidget);
    });
  });

  group('empty and error', () {
    testWidgets('empty offers retry and a way home', (tester) async {
      final restaurants = _MockRestaurants();
      when(
        () => restaurants.search(
          keyword: any(named: 'keyword'),
          near: any(named: 'near'),
        ),
      ).thenAnswer((_) async => []);
      await _pump(tester, restaurants: restaurants);

      expect(find.text('Nenhum lugar perto'), findsOneWidget);
      expect(
        find.text('Não achamos macarrão a até 3 km de você.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();
      verify(
        () => restaurants.search(
          keyword: any(named: 'keyword'),
          near: any(named: 'near'),
        ),
      ).called(2);

      await tester.tap(find.text('Voltar ao início'));
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('error shows the message and retries', (tester) async {
      final restaurants = _MockRestaurants();
      when(
        () => restaurants.search(
          keyword: any(named: 'keyword'),
          near: any(named: 'near'),
        ),
      ).thenThrow(const NetworkFailure());
      await _pump(tester, restaurants: restaurants);

      expect(find.text('Não deu para buscar'), findsOneWidget);
      expect(find.text('Sem conexão.'), findsOneWidget);

      when(
        () => restaurants.search(
          keyword: any(named: 'keyword'),
          near: any(named: 'near'),
        ),
      ).thenAnswer(
        (_) async => FakeRestaurantRepository().search(
          keyword: 'x',
          near: _origin,
        ),
      );
      when(
        () => restaurants.fetchPhotoUri(any()),
      ).thenAnswer((_) async => null);
      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      expect(find.text('7 lugares em até 3 km'), findsOneWidget);
    });
  });
}
