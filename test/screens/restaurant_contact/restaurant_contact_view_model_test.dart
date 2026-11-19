import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/delivery_link_repository.dart';
import 'package:rango_app/data/external_link_launcher.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/data/fake_delivery_link_repository.dart';
import 'package:rango_app/data/fake_external_link_launcher.dart';
import 'package:rango_app/data/fake_history_repository.dart';
import 'package:rango_app/data/fake_restaurant_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/data/restaurant_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/models/delivery_links.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/order_channel.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/models/restaurant_contact_args.dart';
import 'package:rango_app/screens/restaurant_contact/restaurant_contact_view_model.dart';

class _StubRestaurantRepository extends FakeRestaurantRepository {
  _StubRestaurantRepository({this.phone, this.phoneFails = false});

  final String? phone;
  final bool phoneFails;
  final List<String> photoRequests = [];

  @override
  Future<String?> fetchPhone(String placeId) async {
    if (phoneFails) throw const NetworkFailure();
    return phone;
  }

  @override
  Future<String?> fetchPhotoUri(String photoName) async {
    photoRequests.add(photoName);
    return 'https://photos.example/$photoName';
  }
}

class _SignedIn extends FakeAuthRepository {
  _SignedIn(this._user);

  final AppUser _user;

  @override
  Future<AppUser> ensureSignedIn() async => _user;
}

const restaurant = Restaurant(
  placeId: 'p1',
  name: 'Cantina da Nona',
  location: GeoPoint(lat: 0, lng: 0),
  photoName: 'places/p1/photos/a',
);
const args = RestaurantContactArgs(restaurant: restaurant);
const pizzaArgs = RestaurantContactArgs(
  restaurant: restaurant,
  foodId: 'pizza',
);
const account = AppUser(uid: 'u1', isAnonymous: false);
const guest = AppUser(uid: 'g1', isAnonymous: true);

({ProviderContainer container, FakeExternalLinkLauncher launcher}) setUp_({
  RestaurantRepository? repository,
  Map<String, DeliveryLinks> links = const {},
  AppUser user = guest,
  HistoryRepository? history,
}) {
  final launcher = FakeExternalLinkLauncher();
  final container = ProviderContainer.test(
    overrides: [
      authRepositoryProvider.overrideWithValue(_SignedIn(user)),
      currentUserProvider.overrideWithValue(AsyncData(user)),
      historyRepositoryProvider.overrideWithValue(
        history ?? FakeHistoryRepository(entries: const []),
      ),
      restaurantRepositoryProvider.overrideWithValue(
        repository ?? _StubRestaurantRepository(),
      ),
      deliveryLinkRepositoryProvider.overrideWithValue(
        FakeDeliveryLinkRepository(links),
      ),
      externalLinkLauncherProvider.overrideWithValue(launcher),
    ],
  );
  return (container: container, launcher: launcher);
}

Future<void> settle(
  ProviderContainer container,
  RestaurantContactArgs a,
) async {
  container.listen(restaurantContactViewModelProvider(a), (_, _) {});
  await Future<void>.delayed(Duration.zero);
}

void main() {
  test('starts loading with the photo the map already had', () {
    final (:container, launcher: _) = setUp_();
    const withPhoto = RestaurantContactArgs(
      restaurant: restaurant,
      photoUri: 'https://x/y.jpg',
    );
    final state = container.read(restaurantContactViewModelProvider(withPhoto));
    expect(state.loadingDetails, isTrue);
    expect(state.photoUri, 'https://x/y.jpg');
  });

  test('iFood link wins over the others', () async {
    final (:container, launcher: _) = setUp_(
      links: {
        'p1': const DeliveryLinks(
          ifood: 'https://ifood.com.br/x',
          others: ['https://rappi.com/x'],
        ),
      },
    );
    await settle(container, args);
    final state = container.read(restaurantContactViewModelProvider(args));
    expect(state.loadingDetails, isFalse);
    expect(state.deliveryUri, Uri.parse('https://ifood.com.br/x'));
  });

  test('first other link is used when there is no iFood', () async {
    final (:container, launcher: _) = setUp_(
      links: {
        'p1': const DeliveryLinks(others: ['https://rappi.com/x']),
      },
    );
    await settle(container, args);
    expect(
      container.read(restaurantContactViewModelProvider(args)).deliveryUri,
      Uri.parse('https://rappi.com/x'),
    );
  });

  test('falls back to a Google search without links', () async {
    final (:container, launcher: _) = setUp_();
    await settle(container, args);
    expect(
      container.read(restaurantContactViewModelProvider(args)).deliveryUri,
      Uri.https('www.google.com', '/search', {'q': 'Cantina da Nona delivery'}),
    );
  });

  test('phone becomes a tel uri with digits and leading plus only', () async {
    final (:container, launcher: _) = setUp_(
      repository: _StubRestaurantRepository(phone: '+55 (51) 3333-0000'),
    );
    await settle(container, args);
    expect(
      container.read(restaurantContactViewModelProvider(args)).phoneUri,
      Uri.parse('tel:+555133330000'),
    );
  });

  test('a phone failure just leaves no phone', () async {
    final (:container, launcher: _) = setUp_(
      repository: _StubRestaurantRepository(phoneFails: true),
    );
    await settle(container, args);
    final state = container.read(restaurantContactViewModelProvider(args));
    expect(state.loadingDetails, isFalse);
    expect(state.phone, isNull);
    expect(state.phoneUri, isNull);
  });

  test('photo is fetched only when the map did not provide one', () async {
    final repository = _StubRestaurantRepository();
    final (:container, launcher: _) = setUp_(repository: repository);
    await settle(container, args);
    expect(
      container.read(restaurantContactViewModelProvider(args)).photoUri,
      'https://photos.example/places/p1/photos/a',
    );

    final other = _StubRestaurantRepository();
    final second = setUp_(repository: other);
    const withPhoto = RestaurantContactArgs(
      restaurant: restaurant,
      photoUri: 'https://x/y.jpg',
    );
    await settle(second.container, withPhoto);
    expect(other.photoRequests, isEmpty);
  });

  test('orderDelivery and callRestaurant open the right uris', () async {
    final (:container, :launcher) = setUp_(
      repository: _StubRestaurantRepository(phone: '(51) 3333-0000'),
      links: {'p1': const DeliveryLinks(ifood: 'https://ifood.com.br/x')},
    );
    await settle(container, args);
    final notifier = container.read(
      restaurantContactViewModelProvider(args).notifier,
    );
    await notifier.orderDelivery();
    await notifier.callRestaurant();
    expect(launcher.opened, [
      Uri.parse('https://ifood.com.br/x'),
      Uri.parse('tel:5133330000'),
    ]);
  });

  test('callRestaurant without phone opens nothing', () async {
    final (:container, :launcher) = setUp_();
    await settle(container, args);
    await container
        .read(restaurantContactViewModelProvider(args).notifier)
        .callRestaurant();
    expect(launcher.opened, isEmpty);
  });

  test('a refused open sets openFailed until acknowledged', () async {
    final (:container, :launcher) = setUp_();
    launcher.succeeds = false;
    await settle(container, args);
    final notifier = container.read(
      restaurantContactViewModelProvider(args).notifier,
    );
    await notifier.orderDelivery();
    expect(
      container.read(restaurantContactViewModelProvider(args)).openFailed,
      isTrue,
    );
    notifier.acknowledgeOpenFailed();
    expect(
      container.read(restaurantContactViewModelProvider(args)).openFailed,
      isFalse,
    );
  });

  group('saving the decision', () {
    test('an account user ordering saves it as delivery', () async {
      final history = FakeHistoryRepository(entries: const []);
      final (:container, :launcher) = setUp_(user: account, history: history);
      await settle(container, pizzaArgs);

      await container
          .read(restaurantContactViewModelProvider(pizzaArgs).notifier)
          .orderDelivery();

      final saved = history.saved.single;
      expect(saved.foodId, 'pizza');
      expect(saved.restaurantId, 'p1');
      expect(saved.restaurantName, 'Cantina da Nona');
      expect(saved.channel, OrderChannel.delivery);
      expect(launcher.opened, hasLength(1));
    });

    test('an account user calling saves it as call', () async {
      final history = FakeHistoryRepository(entries: const []);
      final (:container, launcher: _) = setUp_(
        repository: _StubRestaurantRepository(phone: '5133330000'),
        user: account,
        history: history,
      );
      await settle(container, pizzaArgs);

      await container
          .read(restaurantContactViewModelProvider(pizzaArgs).notifier)
          .callRestaurant();

      expect(history.saved.single.channel, OrderChannel.call);
    });

    test('a second tap does not save again', () async {
      final history = FakeHistoryRepository(entries: const []);
      final (:container, :launcher) = setUp_(
        repository: _StubRestaurantRepository(phone: '5133330000'),
        user: account,
        history: history,
      );
      await settle(container, pizzaArgs);
      final notifier = container.read(
        restaurantContactViewModelProvider(pizzaArgs).notifier,
      );

      await notifier.orderDelivery();
      await notifier.orderDelivery();
      await notifier.callRestaurant();

      expect(history.saved, hasLength(1));
      expect(launcher.opened, hasLength(3));
    });

    test('a guest never saves (R1) but still orders', () async {
      final history = FakeHistoryRepository(entries: const []);
      final (:container, :launcher) = setUp_(history: history);
      await settle(container, pizzaArgs);

      await container
          .read(restaurantContactViewModelProvider(pizzaArgs).notifier)
          .orderDelivery();

      expect(history.saved, isEmpty);
      expect(launcher.opened, hasLength(1));
    });

    test('the Histórico reloads with the new decision', () async {
      final (:container, launcher: _) = setUp_(user: account);
      expect(await container.read(historyEntriesProvider.future), isEmpty);
      await settle(container, pizzaArgs);

      await container
          .read(restaurantContactViewModelProvider(pizzaArgs).notifier)
          .orderDelivery();

      final entries = await container.read(historyEntriesProvider.future);
      expect(entries.single.restaurantId, 'p1');
    });
  });
}
