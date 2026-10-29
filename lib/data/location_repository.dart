import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rango_app/data/geolocator_location_repository.dart';
import 'package:rango_app/models/geo_point.dart';

abstract interface class LocationRepository {
  /// Returns where the person is now. Checks that the phone's location is on
  /// and asks for permission only here, when the person reaches the
  /// restaurant search. The position is used only for the search and is never
  /// persisted. Throws `LocationServiceDisabledFailure`,
  /// `LocationDeniedFailure` or `LocationDeniedForeverFailure` (or
  /// `UnexpectedFailure` when the GPS gives up).
  Future<GeoPoint> currentPosition();

  /// Opens the app's page in the system settings (denied forever).
  Future<void> openAppSettings();

  /// Opens the system's location settings (location turned off).
  Future<void> openLocationSettings();
}

/// GPS needs no key, so the real implementation is the default; tests
/// override this provider with `FakeLocationRepository` or a mock.
final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => GeolocatorLocationRepository(GeolocatorPlatform.instance),
);
