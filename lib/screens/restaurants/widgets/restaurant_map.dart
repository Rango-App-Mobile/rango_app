import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/config/env.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/screens/restaurants/widgets/drawn_restaurant_map.dart';
import 'package:rango_app/screens/restaurants/widgets/google_restaurant_map.dart';

/// Whether the real Google map is used. False without a key (fresh clone, CI,
/// tests), when the drawn map takes its place. Tests override it.
final useGoogleMapProvider = Provider<bool>((ref) => Env.hasGoogleKey);

/// The seam between the screen and the map implementation. Both take the
/// same props; [recenterTick] changing sends the camera back to [origin].
class RestaurantMap extends ConsumerWidget {
  const RestaurantMap({
    required this.restaurants,
    required this.selectedId,
    required this.foodTheme,
    required this.onSelect,
    this.origin,
    this.recenterTick = 0,
    super.key,
  });

  final GeoPoint? origin;
  final List<Restaurant> restaurants;
  final String? selectedId;
  final String? foodTheme;
  final ValueChanged<String> onSelect;
  final int recenterTick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(useGoogleMapProvider)) {
      return GoogleRestaurantMap(
        origin: origin,
        restaurants: restaurants,
        selectedId: selectedId,
        foodTheme: foodTheme,
        onSelect: onSelect,
        recenterTick: recenterTick,
      );
    }
    return DrawnRestaurantMap(
      origin: origin,
      restaurants: restaurants,
      selectedId: selectedId,
      foodTheme: foodTheme,
      onSelect: onSelect,
      recenterTick: recenterTick,
    );
  }
}
