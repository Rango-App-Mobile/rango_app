// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Restaurant {

 String get placeId; String get name; GeoPoint get location;/// Kind of place, e.g. "Restaurante italiano".
 String? get cuisine; String? get address; double? get rating;/// Reference that `RestaurantRepository.fetchPhotoUri` resolves to a URL.
 String? get photoName;/// Filled by `RestaurantRanking.rank`; 0 until then.
 double get distanceMeters;
/// Create a copy of Restaurant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantCopyWith<Restaurant> get copyWith => _$RestaurantCopyWithImpl<Restaurant>(this as Restaurant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Restaurant&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.cuisine, cuisine) || other.cuisine == cuisine)&&(identical(other.address, address) || other.address == address)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.photoName, photoName) || other.photoName == photoName)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters));
}


@override
int get hashCode => Object.hash(runtimeType,placeId,name,location,cuisine,address,rating,photoName,distanceMeters);

@override
String toString() {
  return 'Restaurant(placeId: $placeId, name: $name, location: $location, cuisine: $cuisine, address: $address, rating: $rating, photoName: $photoName, distanceMeters: $distanceMeters)';
}


}

/// @nodoc
abstract mixin class $RestaurantCopyWith<$Res>  {
  factory $RestaurantCopyWith(Restaurant value, $Res Function(Restaurant) _then) = _$RestaurantCopyWithImpl;
@useResult
$Res call({
 String placeId, String name, GeoPoint location, String? cuisine, String? address, double? rating, String? photoName, double distanceMeters
});


$GeoPointCopyWith<$Res> get location;

}
/// @nodoc
class _$RestaurantCopyWithImpl<$Res>
    implements $RestaurantCopyWith<$Res> {
  _$RestaurantCopyWithImpl(this._self, this._then);

  final Restaurant _self;
  final $Res Function(Restaurant) _then;

/// Create a copy of Restaurant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? name = null,Object? location = null,Object? cuisine = freezed,Object? address = freezed,Object? rating = freezed,Object? photoName = freezed,Object? distanceMeters = null,}) {
  return _then(_self.copyWith(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint,cuisine: freezed == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,photoName: freezed == photoName ? _self.photoName : photoName // ignore: cast_nullable_to_non_nullable
as String?,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of Restaurant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoPointCopyWith<$Res> get location {
  
  return $GeoPointCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [Restaurant].
extension RestaurantPatterns on Restaurant {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Restaurant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Restaurant() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Restaurant value)  $default,){
final _that = this;
switch (_that) {
case _Restaurant():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Restaurant value)?  $default,){
final _that = this;
switch (_that) {
case _Restaurant() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  String name,  GeoPoint location,  String? cuisine,  String? address,  double? rating,  String? photoName,  double distanceMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Restaurant() when $default != null:
return $default(_that.placeId,_that.name,_that.location,_that.cuisine,_that.address,_that.rating,_that.photoName,_that.distanceMeters);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  String name,  GeoPoint location,  String? cuisine,  String? address,  double? rating,  String? photoName,  double distanceMeters)  $default,) {final _that = this;
switch (_that) {
case _Restaurant():
return $default(_that.placeId,_that.name,_that.location,_that.cuisine,_that.address,_that.rating,_that.photoName,_that.distanceMeters);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  String name,  GeoPoint location,  String? cuisine,  String? address,  double? rating,  String? photoName,  double distanceMeters)?  $default,) {final _that = this;
switch (_that) {
case _Restaurant() when $default != null:
return $default(_that.placeId,_that.name,_that.location,_that.cuisine,_that.address,_that.rating,_that.photoName,_that.distanceMeters);case _:
  return null;

}
}

}

/// @nodoc


class _Restaurant implements Restaurant {
  const _Restaurant({required this.placeId, required this.name, required this.location, this.cuisine, this.address, this.rating, this.photoName, this.distanceMeters = 0});
  

@override final  String placeId;
@override final  String name;
@override final  GeoPoint location;
/// Kind of place, e.g. "Restaurante italiano".
@override final  String? cuisine;
@override final  String? address;
@override final  double? rating;
/// Reference that `RestaurantRepository.fetchPhotoUri` resolves to a URL.
@override final  String? photoName;
/// Filled by `RestaurantRanking.rank`; 0 until then.
@override@JsonKey() final  double distanceMeters;

/// Create a copy of Restaurant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantCopyWith<_Restaurant> get copyWith => __$RestaurantCopyWithImpl<_Restaurant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Restaurant&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.cuisine, cuisine) || other.cuisine == cuisine)&&(identical(other.address, address) || other.address == address)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.photoName, photoName) || other.photoName == photoName)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters));
}


@override
int get hashCode => Object.hash(runtimeType,placeId,name,location,cuisine,address,rating,photoName,distanceMeters);

@override
String toString() {
  return 'Restaurant(placeId: $placeId, name: $name, location: $location, cuisine: $cuisine, address: $address, rating: $rating, photoName: $photoName, distanceMeters: $distanceMeters)';
}


}

/// @nodoc
abstract mixin class _$RestaurantCopyWith<$Res> implements $RestaurantCopyWith<$Res> {
  factory _$RestaurantCopyWith(_Restaurant value, $Res Function(_Restaurant) _then) = __$RestaurantCopyWithImpl;
@override @useResult
$Res call({
 String placeId, String name, GeoPoint location, String? cuisine, String? address, double? rating, String? photoName, double distanceMeters
});


@override $GeoPointCopyWith<$Res> get location;

}
/// @nodoc
class __$RestaurantCopyWithImpl<$Res>
    implements _$RestaurantCopyWith<$Res> {
  __$RestaurantCopyWithImpl(this._self, this._then);

  final _Restaurant _self;
  final $Res Function(_Restaurant) _then;

/// Create a copy of Restaurant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? name = null,Object? location = null,Object? cuisine = freezed,Object? address = freezed,Object? rating = freezed,Object? photoName = freezed,Object? distanceMeters = null,}) {
  return _then(_Restaurant(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint,cuisine: freezed == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,photoName: freezed == photoName ? _self.photoName : photoName // ignore: cast_nullable_to_non_nullable
as String?,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of Restaurant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoPointCopyWith<$Res> get location {
  
  return $GeoPointCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

// dart format on
