import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/geolocator_location_repository.dart';
import 'package:rango_app/models/geo_point.dart';

class _MockGeolocator extends Mock implements GeolocatorPlatform {}

void main() {
  late _MockGeolocator geolocator;
  late GeolocatorLocationRepository repository;

  final position = Position(
    latitude: -30.0277,
    longitude: -51.2287,
    timestamp: DateTime(2026),
    accuracy: 10,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  const expected = GeoPoint(lat: -30.0277, lng: -51.2287);

  setUpAll(() {
    registerFallbackValue(const LocationSettings());
  });

  setUp(() {
    geolocator = _MockGeolocator();
    repository = GeolocatorLocationRepository(geolocator);
    when(geolocator.isLocationServiceEnabled).thenAnswer((_) async => true);
    when(
      () => geolocator.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) async => position);
  });

  void permission(LocationPermission check, [LocationPermission? request]) {
    when(geolocator.checkPermission).thenAnswer((_) async => check);
    if (request != null) {
      when(geolocator.requestPermission).thenAnswer((_) async => request);
    }
  }

  void gpsThrows(Object error) {
    when(
      () => geolocator.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenThrow(error);
  }

  test('throws when the phone location service is off', () async {
    when(geolocator.isLocationServiceEnabled).thenAnswer((_) async => false);

    await expectLater(
      repository.currentPosition(),
      throwsA(isA<LocationServiceDisabledFailure>()),
    );
    verifyNever(geolocator.checkPermission);
  });

  for (final granted in [
    LocationPermission.whileInUse,
    LocationPermission.always,
  ]) {
    test('returns the point without asking when already $granted', () async {
      permission(granted);

      expect(await repository.currentPosition(), expected);
      verifyNever(geolocator.requestPermission);
    });
  }

  test('asks for permission when denied and uses it once granted', () async {
    permission(LocationPermission.denied, LocationPermission.whileInUse);

    expect(await repository.currentPosition(), expected);
    verify(geolocator.requestPermission).called(1);
  });

  test('throws LocationDeniedFailure when the request is denied', () async {
    permission(LocationPermission.denied, LocationPermission.denied);

    await expectLater(
      repository.currentPosition(),
      throwsA(isA<LocationDeniedFailure>()),
    );
  });

  test('treats unableToDetermine as denied', () async {
    permission(
      LocationPermission.denied,
      LocationPermission.unableToDetermine,
    );

    await expectLater(
      repository.currentPosition(),
      throwsA(isA<LocationDeniedFailure>()),
    );
  });

  test('throws LocationDeniedForeverFailure without asking again', () async {
    permission(LocationPermission.deniedForever);

    await expectLater(
      repository.currentPosition(),
      throwsA(isA<LocationDeniedForeverFailure>()),
    );
    verifyNever(geolocator.requestPermission);
  });

  test('throws LocationDeniedForeverFailure when the request blocks', () async {
    permission(LocationPermission.denied, LocationPermission.deniedForever);

    await expectLater(
      repository.currentPosition(),
      throwsA(isA<LocationDeniedForeverFailure>()),
    );
  });

  test('maps a GPS timeout to UnexpectedFailure', () async {
    permission(LocationPermission.whileInUse);
    gpsThrows(TimeoutException('gps'));

    await expectLater(
      repository.currentPosition(),
      throwsA(isA<UnexpectedFailure>()),
    );
  });

  test('maps geolocator exceptions to the matching failures', () async {
    permission(LocationPermission.whileInUse);

    gpsThrows(const LocationServiceDisabledException());
    await expectLater(
      repository.currentPosition(),
      throwsA(isA<LocationServiceDisabledFailure>()),
    );

    gpsThrows(const PermissionDeniedException('no'));
    await expectLater(
      repository.currentPosition(),
      throwsA(isA<LocationDeniedFailure>()),
    );
  });

  test('settings calls delegate to geolocator', () async {
    when(geolocator.openAppSettings).thenAnswer((_) async => true);
    when(geolocator.openLocationSettings).thenAnswer((_) async => true);

    await repository.openAppSettings();
    await repository.openLocationSettings();

    verify(geolocator.openAppSettings).called(1);
    verify(geolocator.openLocationSettings).called(1);
  });
}
