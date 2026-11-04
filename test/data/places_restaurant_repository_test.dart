import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/places_restaurant_repository.dart';
import 'package:rango_app/models/geo_point.dart';

const fakeKey = 'fake-key-for-tests';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._respond);

  final ResponseBody Function(RequestOptions options) _respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

Map<String, Object?> _place(
  String id,
  String name,
  double lat,
  double lng, {
  bool full = true,
}) => {
  'id': id,
  'displayName': {'text': name},
  'location': {'latitude': lat, 'longitude': lng},
  if (full) ...{
    'rating': 4,
    'formattedAddress': 'Rua A, 1',
    'primaryTypeDisplayName': {'text': 'Restaurante italiano'},
    'photos': [
      {'name': 'places/$id/photos/p1'},
      {'name': 'places/$id/photos/p2'},
    ],
  },
};

void main() {
  const near = GeoPoint(lat: -30, lng: -51);
  late _FakeAdapter adapter;
  late PlacesRestaurantRepository repository;

  void setUpWith(ResponseBody Function(RequestOptions) respond) {
    adapter = _FakeAdapter(respond);
    final dio = Dio(BaseOptions(baseUrl: 'https://places.example/v1/'))
      ..httpClientAdapter = adapter;
    repository = PlacesRestaurantRepository(
      dio,
      apiKey: fakeKey,
      restrictionHeaders: {'X-Android-Package': 'br.example.app'},
    );
  }

  group('search', () {
    test('sends the expected request', () async {
      setUpWith((_) => _json({}));

      await repository.search(keyword: 'massa', near: near);

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, 'places:searchText');
      expect(request.headers['X-Goog-Api-Key'], fakeKey);
      expect(request.headers['X-Android-Package'], 'br.example.app');
      expect(
        request.headers['X-Goog-FieldMask'],
        'places.id,places.displayName,places.location,places.rating,'
        'places.formattedAddress,places.primaryTypeDisplayName,places.photos',
      );
      final data = request.data as Map<String, Object?>;
      expect(data['textQuery'], 'massa');
      expect(data['maxResultCount'], 20);
      expect(data['languageCode'], 'pt-BR');
      expect(data['regionCode'], 'BR');
      expect(data['locationBias'], {
        'circle': {
          'center': {'latitude': -30.0, 'longitude': -51.0},
          'radius': 3000.0,
        },
      });
    });

    test('maps a full place and one with only required fields', () async {
      setUpWith(
        (_) => _json({
          'places': [
            _place('a', 'Cantina', -30.001, -51),
            _place('b', 'Casa', -30.002, -51, full: false),
          ],
        }),
      );

      final result = await repository.search(keyword: 'massa', near: near);

      expect(result, hasLength(2));
      final full = result[0];
      expect(full.placeId, 'a');
      expect(full.name, 'Cantina');
      expect(full.location, const GeoPoint(lat: -30.001, lng: -51));
      expect(full.rating, 4.0);
      expect(full.address, 'Rua A, 1');
      expect(full.cuisine, 'Restaurante italiano');
      expect(full.photoName, 'places/a/photos/p1');
      expect(full.distanceMeters, greaterThan(0));
      final sparse = result[1];
      expect(sparse.name, 'Casa');
      expect(sparse.rating, isNull);
      expect(sparse.address, isNull);
      expect(sparse.cuisine, isNull);
      expect(sparse.photoName, isNull);
    });

    test('skips malformed entries', () async {
      const location = {'latitude': -30.0, 'longitude': -51.0};
      setUpWith(
        (_) => _json({
          'places': [
            {
              'displayName': {'text': 'No id'},
              'location': location,
            },
            {'id': 'x', 'location': location},
            {
              'id': 'y',
              'displayName': {'text': 'No location'},
            },
            'garbage',
            _place('ok', 'Ok', -30.001, -51),
          ],
        }),
      );

      final result = await repository.search(keyword: 'massa', near: near);

      expect(result.map((r) => r.placeId), ['ok']);
    });

    test('drops places beyond 3 km and sorts nearest first', () async {
      setUpWith(
        (_) => _json({
          'places': [
            _place('far', 'Far', -30.02, -51),
            _place('out', 'Out', -30.05, -51),
            _place('near', 'Near', -30.005, -51),
          ],
        }),
      );

      final result = await repository.search(keyword: 'massa', near: near);

      expect(result.map((r) => r.placeId), ['near', 'far']);
    });

    test('returns an empty list when there is no places key', () async {
      setUpWith((_) => _json({}));

      expect(await repository.search(keyword: 'x', near: near), isEmpty);
    });

    test('maps a timeout to NetworkFailure', () async {
      setUpWith(
        (o) => throw DioException.connectionTimeout(
          timeout: const Duration(seconds: 10),
          requestOptions: o,
        ),
      );

      await expectLater(
        repository.search(keyword: 'x', near: near),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('maps a 500 to UnexpectedFailure', () async {
      setUpWith((_) => _json({'error': 'boom'}, 500));

      await expectLater(
        repository.search(keyword: 'x', near: near),
        throwsA(isA<UnexpectedFailure>()),
      );
    });

    test('maps an unexpected JSON shape to UnexpectedFailure', () async {
      setUpWith((_) => _json({'places': 'nope'}));

      await expectLater(
        repository.search(keyword: 'x', near: near),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });

  group('fetchPhone', () {
    test('returns the national number', () async {
      setUpWith((_) => _json({'nationalPhoneNumber': '(51) 3333-0000'}));

      expect(await repository.fetchPhone('abc'), '(51) 3333-0000');
      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, 'places/abc');
      expect(request.headers['X-Goog-FieldMask'], 'nationalPhoneNumber');
      expect(request.headers['X-Goog-Api-Key'], fakeKey);
    });

    test('returns null when the place has no phone', () async {
      setUpWith((_) => _json({}));

      expect(await repository.fetchPhone('abc'), isNull);
    });
  });

  group('fetchPhotoUri', () {
    test('returns the photo uri', () async {
      setUpWith((_) => _json({'photoUri': 'https://photo.example/p.jpg'}));

      expect(
        await repository.fetchPhotoUri('places/a/photos/p1'),
        'https://photo.example/p.jpg',
      );
      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, 'places/a/photos/p1/media');
      expect(request.queryParameters, {
        'maxHeightPx': 400,
        'skipHttpRedirect': true,
      });
    });

    test('returns null on error', () async {
      setUpWith((_) => _json({'error': 'boom'}, 500));

      expect(await repository.fetchPhotoUri('places/a/photos/p1'), isNull);
    });
  });
}
