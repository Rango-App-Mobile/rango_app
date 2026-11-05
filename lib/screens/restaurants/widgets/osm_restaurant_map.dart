import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/screens/restaurants/widgets/drawn_restaurant_map.dart';
import 'package:rango_app/screens/restaurants/widgets/map_pin.dart';
import 'package:rango_app/screens/restaurants/widgets/user_location_marker.dart';

/// Real map with OpenStreetMap tiles and the Rango pins as ordinary widgets.
/// Until the position is known the drawn map holds the place.
class OsmRestaurantMap extends StatelessWidget {
  const OsmRestaurantMap({
    required this.restaurants,
    required this.selectedId,
    required this.foodTheme,
    required this.onSelect,
    required this.createTileProvider,
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

  /// A factory because the tile layer disposes its provider with itself.
  final TileProvider Function() createTileProvider;

  @override
  Widget build(BuildContext context) {
    final origin = this.origin;
    if (origin == null) {
      return DrawnRestaurantMap(
        restaurants: restaurants,
        selectedId: selectedId,
        foodTheme: foodTheme,
        onSelect: onSelect,
      );
    }
    return _LiveMap(
      origin: origin,
      restaurants: restaurants,
      selectedId: selectedId,
      foodTheme: foodTheme,
      onSelect: onSelect,
      recenterTick: recenterTick,
      createTileProvider: createTileProvider,
    );
  }
}

class _LiveMap extends StatefulWidget {
  const _LiveMap({
    required this.origin,
    required this.restaurants,
    required this.selectedId,
    required this.foodTheme,
    required this.onSelect,
    required this.recenterTick,
    required this.createTileProvider,
  });

  final GeoPoint origin;
  final List<Restaurant> restaurants;
  final String? selectedId;
  final String? foodTheme;
  final ValueChanged<String> onSelect;
  final int recenterTick;
  final TileProvider Function() createTileProvider;

  @override
  State<_LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<_LiveMap>
    with SingleTickerProviderStateMixin {
  static const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// OpenStreetMap blocks clients without an identifying User-Agent.
  static const _userAgentPackage = 'br.senac.rango_app';
  static const _initialZoom = 14.0;
  static const _minZoom = 3.0;
  static const _maxZoom = 19.0;

  final _map = MapController();
  late final TileProvider _tiles;
  late final AnimationController _flight;

  bool _mapReady = false;
  bool _reduceMotion = false;
  LatLng _flightStart = const LatLng(0, 0);
  LatLng _flightEnd = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _tiles = widget.createTileProvider();
    _flight = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(_onFlightTick);
  }

  @override
  void dispose() {
    _flight.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_LiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recenterTick != widget.recenterTick) {
      _flyAfterFrame(widget.origin);
    } else if (oldWidget.selectedId != widget.selectedId) {
      final selected = _selectedLocation();
      if (selected != null) _flyAfterFrame(selected);
    }
  }

  GeoPoint? _selectedLocation() {
    for (final restaurant in widget.restaurants) {
      if (restaurant.placeId == widget.selectedId) return restaurant.location;
    }
    return null;
  }

  /// Moving the map notifies it to rebuild, which is not allowed while the
  /// tree is still building.
  void _flyAfterFrame(GeoPoint target) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _flyTo(target);
    });
  }

  void _flyTo(GeoPoint target) {
    // Before the map is ready _onMapReady takes care of the selection.
    if (!_mapReady) return;
    final end = LatLng(target.lat, target.lng);
    if (_reduceMotion) {
      _flight.stop();
      _map.move(end, _map.camera.zoom);
      return;
    }
    _flightStart = _map.camera.center;
    _flightEnd = end;
    _flight.forward(from: 0).ignore();
  }

  void _onFlightTick() {
    final progress = Curves.easeOut.transform(_flight.value);
    _map.move(
      LatLng(
        lerpDouble(_flightStart.latitude, _flightEnd.latitude, progress) ??
            _flightEnd.latitude,
        lerpDouble(_flightStart.longitude, _flightEnd.longitude, progress) ??
            _flightEnd.longitude,
      ),
      _map.camera.zoom,
    );
  }

  void _onMapReady() {
    _mapReady = true;
    final selected = _selectedLocation();
    if (selected != null) _flyTo(selected);
  }

  Marker _pin(Restaurant restaurant, {required bool selected}) {
    final size = selected ? MapPin.selectedSize : MapPin.defaultSize;
    return Marker(
      key: ValueKey(restaurant.placeId),
      point: LatLng(restaurant.location.lat, restaurant.location.lng),
      width: size.width,
      height: size.height,
      // The tip of the drop, not the box, sits on the coordinate.
      alignment: Marker.computePixelAlignment(
        width: size.width,
        height: size.height,
        left: size.width / 2,
        top: size.height - MapPin.tipInset,
      ),
      child: MapPin(
        name: restaurant.name,
        rating: restaurant.rating,
        distanceMeters: restaurant.distanceMeters,
        foodTheme: widget.foodTheme,
        selected: selected,
        onTap: () => widget.onSelect(restaurant.placeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    final origin = widget.origin;
    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        initialCenter: LatLng(origin.lat, origin.lng),
        initialZoom: _initialZoom,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        backgroundColor: context.colors.bgCanvas,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: _onMapReady,
        // The person's own gesture wins over a camera move in progress.
        onPositionChanged: (_, hasGesture) {
          if (hasGesture) _flight.stop();
        },
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrl,
          userAgentPackageName: _userAgentPackage,
          tileProvider: _tiles,
          maxNativeZoom: _maxZoom.toInt(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(origin.lat, origin.lng),
              width: UserLocationMarker.size,
              height: UserLocationMarker.size,
              child: const UserLocationMarker(),
            ),
            // The selected pin comes last so it stays on top.
            for (final r in widget.restaurants)
              if (r.placeId != widget.selectedId) _pin(r, selected: false),
            for (final r in widget.restaurants)
              if (r.placeId == widget.selectedId) _pin(r, selected: true),
          ],
        ),
      ],
    );
  }
}
