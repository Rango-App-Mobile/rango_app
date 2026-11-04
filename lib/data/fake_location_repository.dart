import 'package:rango_app/data/location_repository.dart';
import 'package:rango_app/models/geo_point.dart';

/// Always answers with a fixed point in Porto Alegre. Used by tests and when
/// the real GPS is not wanted.
class FakeLocationRepository implements LocationRepository {
  const FakeLocationRepository();

  static const point = GeoPoint(lat: -30.0277, lng: -51.2287);

  @override
  Future<GeoPoint> currentPosition() async => point;

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}
}
