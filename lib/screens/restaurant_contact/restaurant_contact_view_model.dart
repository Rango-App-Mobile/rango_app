import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/delivery_link_repository.dart';
import 'package:rango_app/data/external_link_launcher.dart';
import 'package:rango_app/data/restaurant_repository.dart';
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
    final photoName = restaurant.photoName;
    final repository = ref.read(restaurantRepositoryProvider);
    final links = ref.read(deliveryLinkRepositoryProvider);

    try {
      final (phone, deliveryLinks, photo) = await (
        _phone(repository),
        links.linksFor(restaurant.placeId),
        args.photoUri == null && photoName != null
            ? repository.fetchPhotoUri(photoName)
            : Future<String?>.value(),
      ).wait;
      if (!ref.mounted) return;
      state = state.copyWith(
        loadingDetails: false,
        phone: phone,
        links: deliveryLinks,
        photoUri: state.photoUri ?? photo,
      );
    } on Failure {
      // Contact actions have safe fallbacks: a search link, no phone and no photo.
      if (!ref.mounted) return;
      state = state.copyWith(loadingDetails: false);
    }
  }

  Future<String?> _phone(RestaurantRepository repository) async {
    try {
      return await repository.fetchPhone(args.restaurant.placeId);
    } on Failure {
      return null;
    }
  }

  Future<void> orderDelivery() => _open(state.deliveryUri);

  Future<void> callRestaurant() async {
    final uri = state.phoneUri;
    if (uri != null) await _open(uri);
  }

  Future<void> _open(Uri uri) async {
    final opened = await ref.read(externalLinkLauncherProvider).open(uri);
    if (!opened && ref.mounted) state = state.copyWith(openFailed: true);
  }

  void acknowledgeOpenFailed() {
    state = state.copyWith(openFailed: false);
  }
}
