import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_primitives.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/screens/restaurants/widgets/map_pin.dart';
import 'package:rango_app/screens/restaurants/widgets/user_location_marker.dart';

/// Map drawn with Flutter only (Figma "Map base" look), used while the position
/// is unknown and in tests. The streets are decorative and deterministic; the
/// pins sit at their real relative positions around [origin].
class DrawnRestaurantMap extends StatefulWidget {
  const DrawnRestaurantMap({
    required this.restaurants,
    required this.selectedId,
    required this.foodTheme,
    required this.onSelect,
    this.origin,
    this.recenterTick = 0,
    super.key,
  });

  /// Null while locating: only the background is drawn.
  final GeoPoint? origin;
  final List<Restaurant> restaurants;
  final String? selectedId;
  final String? foodTheme;
  final ValueChanged<String> onSelect;

  /// Changes each time the person asks to recenter on themselves.
  final int recenterTick;

  /// The search radius (3 km) fits the shorter side with this share of margin.
  static const _radiusMeters = 3000.0;
  static const _fit = 0.85;
  static const _metersPerDegree = 111320.0;

  @override
  State<DrawnRestaurantMap> createState() => _DrawnRestaurantMapState();
}

class _DrawnRestaurantMapState extends State<DrawnRestaurantMap> {
  /// Pixel offset, from the origin, of what sits at the centre of the view.
  Offset _focus = Offset.zero;
  double _scale = 0.05;

  @override
  void didUpdateWidget(DrawnRestaurantMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recenterTick != widget.recenterTick) {
      _focus = Offset.zero;
    } else if (oldWidget.selectedId != widget.selectedId ||
        oldWidget.restaurants != widget.restaurants) {
      _focusOnSelected();
    }
  }

  void _focusOnSelected() {
    final origin = widget.origin;
    if (origin == null) return;
    for (final restaurant in widget.restaurants) {
      if (restaurant.placeId == widget.selectedId) {
        _focus = _project(origin, restaurant.location);
        return;
      }
    }
  }

  /// Equirectangular projection around [origin], in pixels at [_scale].
  Offset _project(GeoPoint origin, GeoPoint point) {
    final dx =
        (point.lng - origin.lng) *
        math.cos(origin.lat * math.pi / 180) *
        DrawnRestaurantMap._metersPerDegree;
    final dy = -(point.lat - origin.lat) * DrawnRestaurantMap._metersPerDegree;
    return Offset(dx, dy) * _scale;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final newScale =
            size.shortestSide /
            2 *
            DrawnRestaurantMap._fit /
            DrawnRestaurantMap._radiusMeters;
        if (newScale != _scale) {
          _scale = newScale;
          _focusOnSelected();
        }
        final origin = widget.origin;
        final center = Offset(size.width / 2, size.height / 2);

        return ClipRect(
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(begin: _focus, end: _focus),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, focus, _) {
              // World origin (the person) on screen.
              final originOnScreen = center - focus;
              final selected = <Restaurant>[];
              final others = <Restaurant>[];
              if (origin != null) {
                for (final r in widget.restaurants) {
                  (r.placeId == widget.selectedId ? selected : others).add(r);
                }
              }
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: CustomPaint(
                        painter: _MapBasePainter(shift: originOnScreen),
                      ),
                    ),
                  ),
                  if (origin != null) ...[
                    Positioned(
                      left: originOnScreen.dx - UserLocationMarker.size / 2,
                      top: originOnScreen.dy - UserLocationMarker.size / 2,
                      child: const UserLocationMarker(),
                    ),
                    for (final r in [...others, ...selected])
                      _positionedPin(
                        r,
                        origin,
                        originOnScreen,
                        r.placeId == widget.selectedId,
                      ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _positionedPin(
    Restaurant restaurant,
    GeoPoint origin,
    Offset originOnScreen,
    bool isSelected,
  ) {
    final point = originOnScreen + _project(origin, restaurant.location);
    final size = isSelected ? MapPin.selectedSize : MapPin.defaultSize;
    return Positioned(
      key: ValueKey(restaurant.placeId),
      left: point.dx - size.width / 2,
      top: point.dy - size.height + MapPin.tipInset,
      child: MapPin(
        name: restaurant.name,
        rating: restaurant.rating,
        distanceMeters: restaurant.distanceMeters,
        foodTheme: widget.foodTheme,
        selected: isSelected,
        onTap: () => widget.onSelect(restaurant.placeId),
      ),
    );
  }
}

/// Cream ground, sand blocks on a loose grid, a few lime parks and a sky
/// water band at the bottom. The grid moves with [shift]; the water does not.
class _MapBasePainter extends CustomPainter {
  const _MapBasePainter({required this.shift});

  final Offset shift;

  static const _cell = 132.0;
  static const _street = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppPrimitives.cream);

    final block = Paint()..color = AppPrimitives.sand;
    final park = Paint()..color = AppPrimitives.lime.withValues(alpha: 0.5);
    final startX = (shift.dx % _cell) - _cell;
    final startY = (shift.dy % _cell) - _cell;
    final firstCol = ((-shift.dx) / _cell).floor() - 1;
    final firstRow = ((-shift.dy) / _cell).floor() - 1;

    for (var i = 0; startX + i * _cell < size.width; i++) {
      for (var j = 0; startY + j * _cell < size.height; j++) {
        final col = firstCol + i;
        final row = firstRow + j;
        final hash = (col * 73856093) ^ (row * 19349663);
        // Every 5th cell is left open, like a square.
        if (hash.abs() % 5 == 0) continue;
        final rect = Rect.fromLTWH(
          startX + i * _cell + _street / 2,
          startY + j * _cell + _street / 2,
          _cell - _street,
          _cell - _street,
        );
        final isPark = hash.abs() % 11 == 3;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(16)),
          isPark ? park : block,
        );
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.92, size.width, size.height * 0.08),
      Paint()..color = AppPrimitives.sky,
    );
  }

  @override
  bool shouldRepaint(_MapBasePainter oldDelegate) => oldDelegate.shift != shift;
}
