import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/delivery_link_repository.dart';
import 'package:rango_app/data/external_link_launcher.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/data/restaurant_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/models/delivery_links.dart';
import 'package:rango_app/models/history_entry.dart';
import 'package:rango_app/models/order_channel.dart';
import 'package:rango_app/models/restaurant_contact_args.dart';
import 'package:rango_app/screens/restaurant_contact/restaurant_contact_state.dart';

/// Keyed by the args (freezed equality), so the same restaurant reuses state.
// The family type is not exported by Riverpod, so it cannot be annotated.
// ignore: specify_nonobvious_property_types
final restaurantContactViewModelProvider = NotifierProvider.autoDispose
    .family<
      RestaurantContactViewModel,
      RestaurantContactState,
      RestaurantContactArgs
    >(RestaurantContactViewModel.new);

class RestaurantContactViewModel extends Notifier<RestaurantContactState> {
  RestaurantContactViewModel(this.args);

  final RestaurantContactArgs args;

  @override
  RestaurantContactState build() {
    // Fire and forget: the state updates itself when the details arrive.
    unawaited(_loadDetails());
    return RestaurantContactState(args: args, photoUri: args.photoUri);
  }

  Future<void> _loadDetails() async {
    final restaurant = args.restaurant;
    final repository = ref.read(restaurantRepositoryProvider);
    final links = ref.read(deliveryLinkRepositoryProvider);
    final (phone, deliveryLinks, photo) = await (
      _phone(repository),
      _deliveryLinks(links, restaurant.placeId),
      _photo(repository, restaurant.photoName),
    ).wait;
    if (!ref.mounted) return;
    state = state.copyWith(
      loadingDetails: false,
      phone: phone,
      links: deliveryLinks,
      photoUri: state.photoUri ?? photo,
    );
  }

  Future<DeliveryLinks?> _deliveryLinks(
    DeliveryLinkRepository repository,
    String placeId,
  ) async {
    try {
      return await repository.linksFor(placeId);
    } on Failure {
      return null;
    }
  }

  Future<String?> _photo(
    RestaurantRepository repository,
    String? photoName,
  ) async {
    if (args.photoUri != null || photoName == null) return null;
    try {
      return await repository.fetchPhotoUri(photoName);
    } on Failure {
      return null;
    }
  }

  Future<String?> _phone(RestaurantRepository repository) async {
    try {
      return await repository.fetchPhone(args.restaurant.placeId);
    } on Failure {
      return null;
    }
  }

  Future<void> orderDelivery() =>
      _open(state.deliveryUri, OrderChannel.delivery);

  Future<void> callRestaurant() async {
    final uri = state.phoneUri;
    if (uri != null) await _open(uri, OrderChannel.call);
  }

  Future<void> _open(Uri uri, OrderChannel channel) async {
    await _saveDecision(channel);
    if (!ref.mounted) return;
    final opened = await ref.read(externalLinkLauncherProvider).open(uri);
    if (!opened && ref.mounted) state = state.copyWith(openFailed: true);
  }

  bool _saved = false;

  /// The first order or call of this screen goes to the Histórico, only for
  /// an account user (R1). The repository never throws and does not wait
  /// for the server, so this does not hold the order up.
  Future<void> _saveDecision(OrderChannel channel) async {
    final foodId = args.foodId;
    if (_saved || foodId == null) return;
    _saved = true;
    final history = ref.read(historyRepositoryProvider);
    final AppUser user;
    try {
      user = await ref.read(authRepositoryProvider).ensureSignedIn();
    } on Failure {
      return; // Without a user there is no Histórico to save to.
    }
    if (user.isAnonymous) return;
    final restaurant = args.restaurant;
    await history.save(
      user.uid,
      HistoryEntry(
        id: '',
        foodId: foodId,
        restaurantId: restaurant.placeId,
        restaurantName: restaurant.name,
        cuisine: restaurant.cuisine,
        channel: channel,
        decidedAt: DateTime.now(),
      ),
    );
    if (ref.mounted) ref.invalidate(historyEntriesProvider);
  }

  void acknowledgeOpenFailed() {
    state = state.copyWith(openFailed: false);
  }
}
