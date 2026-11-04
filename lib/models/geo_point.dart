import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo_point.freezed.dart';

/// A position on Earth in decimal degrees.
@freezed
abstract class GeoPoint with _$GeoPoint {
  const factory GeoPoint({required double lat, required double lng}) =
      _GeoPoint;
  const GeoPoint._();

  static const _earthRadiusMeters = 6371000.0;

  /// Great-circle distance to [other] in meters (haversine formula).
  double distanceTo(GeoPoint other) {
    final dLat = _radians(other.lat - lat);
    final dLng = _radians(other.lng - lng);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_radians(lat)) *
            math.cos(_radians(other.lat)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * _earthRadiusMeters * math.asin(math.sqrt(a));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
