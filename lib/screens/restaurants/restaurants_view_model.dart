import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/location_repository.dart';
import 'package:rango_app/data/restaurant_repository.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/restaurants/restaurants_state.dart';

/// Family argument is the category id from the route (may be null).
/// `autoDispose` so a new session searches again; the map screen watches it
/// while mounted, so it survives the contact screen being pushed on top.
// The family type is not exported by Riverpod, so it cannot be annotated.
// ignore: specify_nonobvious_property_types
final restaurantsViewModelProvider = NotifierProvider.autoDispose
    .family<RestaurantsViewModel, RestaurantsState, String?>(
      RestaurantsViewModel.new,
    );

class RestaurantsViewModel extends Notifier<RestaurantsState> {
  RestaurantsViewModel(this.categoryId);

  final String? categoryId;

  /// Bumped on every (re)load so an older run cannot write over a newer one.
  int _run = 0;

  @override
  RestaurantsState build() {
    // Fire and forget: build() must return `locating` synchronously and
    // _load reports everything through state, never throwing.
    unawaited(Future.microtask(_load));
    return const RestaurantsState(status: RestaurantsStatus.locating);
  }

  Future<void> _load() async {
    final run = ++_run;
    bool stale() => !ref.mounted || run != _run;

    try {
      final category = await _findCategory();
      if (stale()) return;
      if (category == null) {
        state = state.copyWith(
          status: RestaurantsStatus.error,
          errorMessage: 'Comida não encontrada.',
        );
        return;
      }
      state = state.copyWith(
        foodLabel: category.label,
        foodTheme: category.foodTheme,
        foodPhoto: category.photo,
      );

      final origin = await ref
          .read(locationRepositoryProvider)
          .currentPosition();
      if (stale()) return;
      state = state.copyWith(
        status: RestaurantsStatus.searching,
        origin: origin,
      );

      final found = await ref
          .read(restaurantRepositoryProvider)
          .search(
            keyword: category.placesKeyword ?? category.label,
            near: origin,
          );
      if (stale()) return;
      if (found.isEmpty) {
        state = state.copyWith(status: RestaurantsStatus.empty);
        return;
      }
      state = state.copyWith(
        status: RestaurantsStatus.ready,
        restaurants: found,
        selectedId: found.first.placeId,
      );
      await _fetchPhoto(found.first.placeId, found.first.photoName);
    } on LocationDeniedFailure {
      _setStatus(run, RestaurantsStatus.locationDenied);
    } on LocationDeniedForeverFailure {
      _setStatus(run, RestaurantsStatus.locationDeniedForever);
    } on LocationServiceDisabledFailure {
      _setStatus(run, RestaurantsStatus.locationServiceOff);
    } on Failure catch (failure) {
      if (ref.mounted && run == _run) {
        state = state.copyWith(
          status: RestaurantsStatus.error,
          errorMessage: failure.message,
        );
      }
    }
  }

  Future<FoodCategory?> _findCategory() async {
    final id = categoryId;
    if (id == null) return null;
    final all = await ref.read(categoryRepositoryProvider).fetchAll();
    for (final category in all) {
      if (category.id == id) return category;
    }
    return null;
  }

  void _setStatus(int run, RestaurantsStatus status) {
    if (!ref.mounted || run != _run) return;
    state = state.copyWith(status: status);
  }

  Future<void> _fetchPhoto(String placeId, String? photoName) async {
    if (photoName == null) return;
    final uri = await ref
        .read(restaurantRepositoryProvider)
        .fetchPhotoUri(photoName);
    // Ignore an answer for a restaurant that is no longer the selected one.
    if (!ref.mounted || state.selectedId != placeId) return;
    state = state.copyWith(photoUri: uri);
  }

  Future<void> select(String placeId) async {
    if (state.selectedId == placeId) return;
    final matches = state.restaurants.where((r) => r.placeId == placeId);
    if (matches.isEmpty) return;
    state = state.copyWith(selectedId: placeId, photoUri: null);
    await _fetchPhoto(placeId, matches.first.photoName);
  }

  Future<void> retry() {
    state = RestaurantsState(
      status: RestaurantsStatus.locating,
      foodLabel: state.foodLabel,
      foodTheme: state.foodTheme,
      foodPhoto: state.foodPhoto,
    );
    return _load();
  }

  Future<void> requestPermissionAgain() => retry();

  Future<void> openSettings() {
    final location = ref.read(locationRepositoryProvider);
    return state.status == RestaurantsStatus.locationServiceOff
        ? location.openLocationSettings()
        : location.openAppSettings();
  }
}
