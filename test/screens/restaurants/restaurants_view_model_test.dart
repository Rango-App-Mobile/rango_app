import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_location_repository.dart';
import 'package:rango_app/data/fake_restaurant_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/data/location_repository.dart';
import 'package:rango_app/data/restaurant_repository.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/screens/restaurants/restaurants_state.dart';
import 'package:rango_app/screens/restaurants/restaurants_view_model.dart';

class _MockLocation extends Mock implements LocationRepository {}

class _MockRestaurants extends Mock implements RestaurantRepository {}

const GeoPoint _origin = FakeLocationRepository.point;

Restaurant _place(String id, {String? photoName, double meters = 100}) =>
    Restaurant(
      placeId: id,
      name: 'Lugar $id',
      location: const GeoPoint(lat: -30.02, lng: -51.22),
      photoName: photoName,
      distanceMeters: meters,
    );

void main() {
  setUpAll(() => registerFallbackValue(_origin));

  late _MockLocation location;
  late _MockRestaurants restaurants;

  setUp(() {
    location = _MockLocation();
    restaurants = _MockRestaurants();
    when(location.currentPosition).thenAnswer((_) async => _origin);
    when(
      () => restaurants.search(
        keyword: any(named: 'keyword'),
        near: any(named: 'near'),
      ),
    ).thenAnswer((_) async => [_place('a'), _place('b'), _place('c')]);
    when(() => restaurants.fetchPhotoUri(any())).thenAnswer((_) async => null);
  });

  ProviderContainer makeContainer() => ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [
      categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
      locationRepositoryProvider.overrideWithValue(location),
      restaurantRepositoryProvider.overrideWithValue(restaurants),
    ],
  );

  /// Reads the provider, keeps it alive and waits for the first load.
  Future<(ProviderContainer, RestaurantsViewModel)> load([
    String? categoryId = 'spaghetti',
  ]) async {
    final container = makeContainer();
    final provider = restaurantsViewModelProvider(categoryId);
    container.listen(provider, (_, _) {});
    await pumpEventQueue();
    return (container, container.read(provider.notifier));
  }

  RestaurantsState read(ProviderContainer container, [String? id]) =>
      container.read(restaurantsViewModelProvider(id ?? 'spaghetti'));

  test('starts locating', () {
    final container = makeContainer();
    final state = container.read(restaurantsViewModelProvider('spaghetti'));
    expect(state.status, RestaurantsStatus.locating);
  });

  test('is ready with the nearest restaurant selected', () async {
    final (container, _) = await load();

    final state = read(container);
    expect(state.status, RestaurantsStatus.ready);
    expect(state.origin, _origin);
    expect(state.foodLabel, 'Macarrão');
    expect(state.restaurants, hasLength(3));
    expect(state.selectedId, 'a');
    expect(state.selected?.name, 'Lugar a');
    verify(
      () => restaurants.search(keyword: 'restaurante italiano', near: _origin),
    ).called(1);
  });

  test('shows searching while Places has not answered', () async {
    final pending = Completer<List<Restaurant>>();
    when(
      () => restaurants.search(
        keyword: any(named: 'keyword'),
        near: any(named: 'near'),
      ),
    ).thenAnswer((_) => pending.future);

    final (container, _) = await load();

    expect(read(container).status, RestaurantsStatus.searching);
    expect(read(container).origin, _origin);
    expect(read(container).restaurants, isEmpty);

    pending.complete([_place('a')]);
    await pumpEventQueue();
    expect(read(container).status, RestaurantsStatus.ready);
  });

  test('is empty when nothing is in the radius', () async {
    when(
      () => restaurants.search(
        keyword: any(named: 'keyword'),
        near: any(named: 'near'),
      ),
    ).thenAnswer((_) async => []);

    final (container, _) = await load();

    expect(read(container).status, RestaurantsStatus.empty);
  });

  for (final (failure, status) in <(Failure, RestaurantsStatus)>[
    (const LocationDeniedFailure(), RestaurantsStatus.locationDenied),
    (
      const LocationDeniedForeverFailure(),
      RestaurantsStatus.locationDeniedForever,
    ),
    (
      const LocationServiceDisabledFailure(),
      RestaurantsStatus.locationServiceOff,
    ),
  ]) {
    test('${failure.runtimeType} becomes $status', () async {
      when(location.currentPosition).thenThrow(failure);

      final (container, _) = await load();

      expect(read(container).status, status);
      verifyNever(
        () => restaurants.search(
          keyword: any(named: 'keyword'),
          near: any(named: 'near'),
        ),
      );
    });
  }

  test('a failed search is an error with the failure message', () async {
    when(
      () => restaurants.search(
        keyword: any(named: 'keyword'),
        near: any(named: 'near'),
      ),
    ).thenThrow(const NetworkFailure());

    final (container, _) = await load();

    expect(read(container).status, RestaurantsStatus.error);
    expect(read(container).errorMessage, 'Sem conexão.');
  });

  test('an unexpected GPS failure is an error', () async {
    when(location.currentPosition).thenThrow(const UnexpectedFailure());

    final (container, _) = await load();

    expect(read(container).status, RestaurantsStatus.error);
    expect(read(container).errorMessage, 'Algo deu errado.');
  });

  test('an unknown category is an error', () async {
    final (container, _) = await load('nope');

    final state = read(container, 'nope');
    expect(state.status, RestaurantsStatus.error);
    expect(state.errorMessage, 'Comida não encontrada.');
  });

  test('a null category is an error', () async {
    final container = makeContainer();
    final provider = restaurantsViewModelProvider(null);
    container.listen(provider, (_, _) {});
    await pumpEventQueue();

    expect(container.read(provider).status, RestaurantsStatus.error);
  });

  test('select changes the selection and fetches its photo', () async {
    when(
      () => restaurants.search(
        keyword: any(named: 'keyword'),
        near: any(named: 'near'),
      ),
    ).thenAnswer(
      (_) async => [_place('a'), _place('b', photoName: 'places/b/photos/1')],
    );
    when(
      () => restaurants.fetchPhotoUri('places/b/photos/1'),
    ).thenAnswer((_) async => 'https://photo/b');
    final (container, viewModel) = await load();

    await viewModel.select('b');

    expect(read(container).selectedId, 'b');
    expect(read(container).photoUri, 'https://photo/b');

    await viewModel.select('a');
    expect(read(container).selectedId, 'a');
    expect(read(container).photoUri, isNull);
  });

  test('ignores a photo that arrives after another selection', () async {
    final slow = Completer<String?>();
    when(
      () => restaurants.search(
        keyword: any(named: 'keyword'),
        near: any(named: 'near'),
      ),
    ).thenAnswer(
      (_) async => [
        _place('a'),
        _place('b', photoName: 'slow'),
        _place('c', photoName: 'fast'),
      ],
    );
    when(
      () => restaurants.fetchPhotoUri('slow'),
    ).thenAnswer((_) => slow.future);
    when(
      () => restaurants.fetchPhotoUri('fast'),
    ).thenAnswer((_) async => 'https://photo/c');
    final (container, viewModel) = await load();

    final first = viewModel.select('b');
    await viewModel.select('c');
    slow.complete('https://photo/b');
    await first;

    expect(read(container).selectedId, 'c');
    expect(read(container).photoUri, 'https://photo/c');
  });

  test('retry reloads after a failure', () async {
    when(location.currentPosition).thenThrow(const LocationDeniedFailure());
    final (container, viewModel) = await load();
    expect(read(container).status, RestaurantsStatus.locationDenied);

    when(location.currentPosition).thenAnswer((_) async => _origin);
    await viewModel.retry();

    expect(read(container).status, RestaurantsStatus.ready);
    verify(location.currentPosition).called(2);
  });

  test('requestPermissionAgain asks for the position again', () async {
    when(location.currentPosition).thenThrow(const LocationDeniedFailure());
    final (container, viewModel) = await load();

    when(location.currentPosition).thenAnswer((_) async => _origin);
    await viewModel.requestPermissionAgain();

    expect(read(container).status, RestaurantsStatus.ready);
  });

  test('openSettings opens the app settings when denied forever', () async {
    when(
      location.currentPosition,
    ).thenThrow(const LocationDeniedForeverFailure());
    when(location.openAppSettings).thenAnswer((_) async {});
    final (_, viewModel) = await load();

    await viewModel.openSettings();

    verify(location.openAppSettings).called(1);
    verifyNever(location.openLocationSettings);
  });

  test(
    'openSettings opens the location settings when the GPS is off',
    () async {
      when(
        location.currentPosition,
      ).thenThrow(const LocationServiceDisabledFailure());
      when(location.openLocationSettings).thenAnswer((_) async {});
      final (_, viewModel) = await load();

      await viewModel.openSettings();

      verify(location.openLocationSettings).called(1);
      verifyNever(location.openAppSettings);
    },
  );

  test('works with the in-memory fakes', () async {
    final container = ProviderContainer.test(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        locationRepositoryProvider.overrideWithValue(
          const FakeLocationRepository(),
        ),
        restaurantRepositoryProvider.overrideWithValue(
          FakeRestaurantRepository(),
        ),
      ],
    );
    final provider = restaurantsViewModelProvider('spaghetti');
    container.listen(provider, (_, _) {});
    await pumpEventQueue();

    final state = container.read(provider);
    expect(state.status, RestaurantsStatus.ready);
    expect(state.selectedId, state.restaurants.first.placeId);
  });
}
