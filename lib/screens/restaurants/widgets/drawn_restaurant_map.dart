import 'dart:async';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_primitives.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/screens/restaurants/widgets/map_pin.dart';

/// Map drawn with Flutter only (Figma "Map base" look), used while there is no
/// Google key and in tests. The streets are decorative and deterministic; the
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

class _DrawnRestaurantMapState extends State<DrawnRestaurantMap>
    with SingleTickerProviderStateMixin {
  // Created in initState (not lazily) so dispose never builds a ticker.
  late final AnimationController _pulse;
  bool _pulsing = false;

  /// Pixel offset, from the origin, of what sits at the centre of the view.
  Offset _focus = Offset.zero;
  double _scale = 0.05;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

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
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && _pulsing) {
      _pulse.stop();
      _pulsing = false;
    } else if (!reduceMotion && !_pulsing && widget.origin != null) {
      _pulse.repeat(reverse: true).ignore();
      _pulsing = true;
    }

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
                      left: originOnScreen.dx - _UserLocation.size / 2,
                      top: originOnScreen.dy - _UserLocation.size / 2,
                      child: _UserLocation(pulse: _pulse),
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

/// Figma "User Location": ink dot with a cream border inside a sky halo that
/// breathes from 1 to 1.15 every 2 s.
class _UserLocation extends StatelessWidget {
  const _UserLocation({required this.pulse});

  final Animation<double> pulse;

  static const size = 64.0;
  static const _dot = 16.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Você está aqui',
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.15).animate(pulse),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPrimitives.sky.withValues(alpha: 0.5),
                  border: Border.all(
                    color: AppPrimitives.sky,
                    width: 1.5,
                  ),
                ),
                child: const SizedBox.square(dimension: size),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPrimitives.ink900,
                border: Border.all(color: AppPrimitives.cream, width: 3),
              ),
              child: const SizedBox.square(dimension: _dot + 6),
            ),
          ],
        ),
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
