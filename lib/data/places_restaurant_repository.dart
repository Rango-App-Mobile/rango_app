import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rango_app/core/config/env.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/restaurant_repository.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/models/restaurant_ranking.dart';

/// Google Places API (New) over REST. The key and the app-restriction headers
/// go on every request; nothing is logged.
class PlacesRestaurantRepository implements RestaurantRepository {
  PlacesRestaurantRepository(
    this._dio, {
    required String apiKey,
    required Map<String, String> restrictionHeaders,
  }) : _headers = {'X-Goog-Api-Key': apiKey, ...restrictionHeaders};

  factory PlacesRestaurantRepository.create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://places.googleapis.com/v1/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    final headers = switch (defaultTargetPlatform) {
      TargetPlatform.android => {
        'X-Android-Package': 'br.senac.rango_app',
        if (Env.androidCertSha1.isNotEmpty)
          'X-Android-Cert': Env.androidCertSha1,
      },
      TargetPlatform.iOS => {'X-Ios-Bundle-Identifier': 'br.senac.rangoApp'},
      _ => <String, String>{},
    };
    return PlacesRestaurantRepository(
      dio,
      apiKey: Env.googleApiKey,
      restrictionHeaders: headers,
    );
  }

  static const _searchFieldMask =
      'places.id,places.displayName,places.location,places.rating,'
      'places.formattedAddress,places.primaryTypeDisplayName,places.photos';

  final Dio _dio;
  final Map<String, String> _headers;

  @override
  Future<List<Restaurant>> search({
    required String keyword,
    required GeoPoint near,
  }) async {
    final body = await _send(
      'places:searchText',
      method: 'POST',
      fieldMask: _searchFieldMask,
      data: {
        'textQuery': keyword,
        'locationBias': {
          'circle': {
            'center': {'latitude': near.lat, 'longitude': near.lng},
            'radius': RestaurantRanking.searchRadiusMeters.toDouble(),
          },
        },
        'maxResultCount': RestaurantRanking.maxResults,
        'languageCode': 'pt-BR',
        'regionCode': 'BR',
      },
    );
    final places = body['places'];
    if (places == null) return const [];
    if (places is! List<Object?>) throw const UnexpectedFailure();
    final parsed = <Restaurant>[
      for (final place in places)
        if (place is Map<String, Object?>) ?_parsePlace(place),
    ];
    return RestaurantRanking.rank(parsed, near);
  }

  @override
  Future<String?> fetchPhone(String placeId) async {
    final body = await _send(
      'places/$placeId',
      method: 'GET',
      fieldMask: 'nationalPhoneNumber',
    );
    return switch (body['nationalPhoneNumber']) {
      final String phone when phone.isNotEmpty => phone,
      _ => null,
    };
  }

  @override
  Future<String?> fetchPhotoUri(String photoName) async {
    try {
      final body = await _send(
        '$photoName/media',
        method: 'GET',
        query: {'maxHeightPx': 400, 'skipHttpRedirect': true},
      );
      return switch (body['photoUri']) {
        final String uri when uri.isNotEmpty => uri,
        _ => null,
      };
    } on Failure {
      return null;
    }
  }

  Restaurant? _parsePlace(Map<String, Object?> place) {
    final id = place['id'];
    final name = switch (place['displayName']) {
      {'text': final String text} when text.isNotEmpty => text,
      _ => null,
    };
    final location = switch (place['location']) {
      {'latitude': final num lat, 'longitude': final num lng} => GeoPoint(
        lat: lat.toDouble(),
        lng: lng.toDouble(),
      ),
      _ => null,
    };
    if (id is! String || id.isEmpty || name == null || location == null) {
      return null;
    }
    return Restaurant(
      placeId: id,
      name: name,
      location: location,
      cuisine: switch (place['primaryTypeDisplayName']) {
        {'text': final String text} => text,
        _ => null,
      },
      address: switch (place['formattedAddress']) {
        final String address => address,
        _ => null,
      },
      rating: switch (place['rating']) {
        final num rating => rating.toDouble(),
        _ => null,
      },
      photoName: switch (place['photos']) {
        [{'name': final String photo}, ...] => photo,
        _ => null,
      },
    );
  }

  Future<Map<String, Object?>> _send(
    String path, {
    required String method,
    String? fieldMask,
    Map<String, Object?>? data,
    Map<String, Object?>? query,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          headers: {
            ..._headers,
            'X-Goog-FieldMask': ?fieldMask,
          },
        ),
      );
      final body = response.data;
      if (body is Map<String, Object?>) return body;
      throw const UnexpectedFailure();
    } on DioException catch (error) {
      throw switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError => const NetworkFailure(),
        _ => const UnexpectedFailure(),
      };
    }
  }
}
