import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/location_repository.dart';
import 'package:rango_app/models/geo_point.dart';

class GeolocatorLocationRepository implements LocationRepository {
  GeolocatorLocationRepository(this._geolocator);

  final GeolocatorPlatform _geolocator;

  @override
  Future<GeoPoint> currentPosition() async {
    if (!await _geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledFailure();
    }
    await _ensurePermission();
    try {
      final position = await _geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return GeoPoint(lat: position.latitude, lng: position.longitude);
    } on LocationServiceDisabledException {
      throw const LocationServiceDisabledFailure();
    } on PermissionDeniedException {
      throw const LocationDeniedFailure();
    } on TimeoutException {
      throw const UnexpectedFailure('Não deu para achar sua localização.');
    }
  }

  Future<void> _ensurePermission() async {
    var permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.deniedForever:
        throw const LocationDeniedForeverFailure();
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        throw const LocationDeniedFailure();
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return;
    }
  }

  @override
  Future<void> openAppSettings() => _geolocator.openAppSettings();

  @override
  Future<void> openLocationSettings() => _geolocator.openLocationSettings();
}
