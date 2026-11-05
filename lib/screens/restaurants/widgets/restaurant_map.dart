import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/screens/restaurants/widgets/drawn_restaurant_map.dart';
import 'package:rango_app/screens/restaurants/widgets/osm_restaurant_map.dart';

/// Whether the real tile map is used. The widget tests of the screen turn it
/// off, so they run on the drawn map.
final useTileMapProvider = Provider<bool>((ref) => true);

/// How the real map gets its tiles. Tests swap it to stay off the network.
final tileProviderFactoryProvider = Provider<TileProvider Function()>(
  (ref) => NetworkTileProvider.new,
);

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
    if (ref.watch(useTileMapProvider)) {
      return OsmRestaurantMap(
        origin: origin,
        restaurants: restaurants,
        selectedId: selectedId,
        foodTheme: foodTheme,
        onSelect: onSelect,
        recenterTick: recenterTick,
        createTileProvider: ref.watch(tileProviderFactoryProvider),
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
