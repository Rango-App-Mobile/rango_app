import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rango_app/core/theme/app_primitives.dart';
import 'package:rango_app/core/theme/resolve_food_theme.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/screens/restaurants/widgets/drawn_restaurant_map.dart';
import 'package:rango_app/screens/restaurants/widgets/map_pin.dart';

/// Real Google map with the Rango style and the pins painted by
/// [renderMapPinPng]. Not covered by widget tests (platform view); the drawn
/// map is the testable twin.
///
/// The halo around the person is a static circle: a platform-view map cannot
/// run the Flutter pulse animation.
class GoogleRestaurantMap extends StatefulWidget {
  const GoogleRestaurantMap({
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
  State<GoogleRestaurantMap> createState() => _GoogleRestaurantMapState();
}

class _GoogleRestaurantMapState extends State<GoogleRestaurantMap> {
  static const _styleAsset = 'assets/map/rango_map_style.json';

  GoogleMapController? _controller;
  String? _style;
  final Map<String, BitmapDescriptor> _icons = {};
  var _iconsFor = '';

  @override
  void initState() {
    super.initState();
    unawaited(_loadStyle());
  }

  Future<void> _loadStyle() async {
    final json = await rootBundle.loadString(_styleAsset);
    if (mounted) setState(() => _style = json);
  }

  @override
  void didUpdateWidget(GoogleRestaurantMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final origin = widget.origin;
    if (oldWidget.recenterTick != widget.recenterTick && origin != null) {
      unawaited(_move(origin));
    } else if (oldWidget.selectedId != widget.selectedId) {
      unawaited(_buildIcons());
      for (final r in widget.restaurants) {
        if (r.placeId == widget.selectedId) {
          unawaited(_move(r.location));
        }
      }
    }
  }

  Future<void> _move(GeoPoint point) async {
    await _controller?.animateCamera(
      CameraUpdate.newLatLng(LatLng(point.lat, point.lng)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_buildIcons());
  }

  /// Renders one icon per (restaurant, selected) pair; cached by key and
  /// redone only when the selection or the list changes.
  Future<void> _buildIcons() async {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final theme = resolveFoodTheme(widget.foodTheme);
    final stamp = '${widget.selectedId}|${widget.restaurants.length}';
    if (stamp == _iconsFor) return;
    _iconsFor = stamp;
    for (final r in widget.restaurants) {
      final selected = r.placeId == widget.selectedId;
      final key = '${r.placeId}|$selected';
      if (_icons.containsKey(key)) continue;
      final png = await renderMapPinPng(
        fill: theme.background,
        glyph: theme.foreground,
        selected: selected,
        balloon: selected ? MapPin.balloonText(r.name, r.rating) : null,
        pixelRatio: dpr,
      );
      _icons[key] = BitmapDescriptor.bytes(png, imagePixelRatio: dpr);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final origin = widget.origin;
    final style = _style;
    if (origin == null || style == null) {
      return DrawnRestaurantMap(
        restaurants: widget.restaurants,
        selectedId: widget.selectedId,
        foodTheme: widget.foodTheme,
        onSelect: widget.onSelect,
      );
    }
    final center = LatLng(origin.lat, origin.lng);
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: center, zoom: 14),
      style: style,
      onMapCreated: (controller) => _controller = controller,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      markers: {
        for (final r in widget.restaurants)
          if (_icons['${r.placeId}|${r.placeId == widget.selectedId}']
              case final icon?)
            Marker(
              markerId: MarkerId(r.placeId),
              position: LatLng(r.location.lat, r.location.lng),
              icon: icon,
              zIndexInt: r.placeId == widget.selectedId ? 2 : 1,
              onTap: () => widget.onSelect(r.placeId),
            ),
      },
      circles: {
        Circle(
          circleId: const CircleId('halo'),
          center: center,
          radius: 60,
          fillColor: AppPrimitives.sky.withValues(alpha: 0.3),
          strokeColor: AppPrimitives.sky,
          strokeWidth: 1,
        ),
        Circle(
          circleId: const CircleId('you'),
          center: center,
          radius: 9,
          fillColor: AppPrimitives.ink900,
          strokeColor: AppPrimitives.cream,
          strokeWidth: 3,
          zIndex: 1,
        ),
      },
    );
  }
}
