// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurants_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RestaurantsState {

 RestaurantsStatus get status; String get foodLabel; String? get foodTheme;/// Category photo asset name, the preview fallback when the place has none.
 String? get foodPhoto; GeoPoint? get origin; List<Restaurant> get restaurants; String? get selectedId;/// Photo URL of the selected restaurant, once fetched.
 String? get photoUri; String? get errorMessage;
/// Create a copy of RestaurantsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantsStateCopyWith<RestaurantsState> get copyWith => _$RestaurantsStateCopyWithImpl<RestaurantsState>(this as RestaurantsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantsState&&(identical(other.status, status) || other.status == status)&&(identical(other.foodLabel, foodLabel) || other.foodLabel == foodLabel)&&(identical(other.foodTheme, foodTheme) || other.foodTheme == foodTheme)&&(identical(other.foodPhoto, foodPhoto) || other.foodPhoto == foodPhoto)&&(identical(other.origin, origin) || other.origin == origin)&&const DeepCollectionEquality().equals(other.restaurants, restaurants)&&(identical(other.selectedId, selectedId) || other.selectedId == selectedId)&&(identical(other.photoUri, photoUri) || other.photoUri == photoUri)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,foodLabel,foodTheme,foodPhoto,origin,const DeepCollectionEquality().hash(restaurants),selectedId,photoUri,errorMessage);

@override
String toString() {
  return 'RestaurantsState(status: $status, foodLabel: $foodLabel, foodTheme: $foodTheme, foodPhoto: $foodPhoto, origin: $origin, restaurants: $restaurants, selectedId: $selectedId, photoUri: $photoUri, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $RestaurantsStateCopyWith<$Res>  {
  factory $RestaurantsStateCopyWith(RestaurantsState value, $Res Function(RestaurantsState) _then) = _$RestaurantsStateCopyWithImpl;
@useResult
$Res call({
 RestaurantsStatus status, String foodLabel, String? foodTheme, String? foodPhoto, GeoPoint? origin, List<Restaurant> restaurants, String? selectedId, String? photoUri, String? errorMessage
});


$GeoPointCopyWith<$Res>? get origin;

}
/// @nodoc
class _$RestaurantsStateCopyWithImpl<$Res>
    implements $RestaurantsStateCopyWith<$Res> {
  _$RestaurantsStateCopyWithImpl(this._self, this._then);

  final RestaurantsState _self;
  final $Res Function(RestaurantsState) _then;

/// Create a copy of RestaurantsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? foodLabel = null,Object? foodTheme = freezed,Object? foodPhoto = freezed,Object? origin = freezed,Object? restaurants = null,Object? selectedId = freezed,Object? photoUri = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RestaurantsStatus,foodLabel: null == foodLabel ? _self.foodLabel : foodLabel // ignore: cast_nullable_to_non_nullable
as String,foodTheme: freezed == foodTheme ? _self.foodTheme : foodTheme // ignore: cast_nullable_to_non_nullable
as String?,foodPhoto: freezed == foodPhoto ? _self.foodPhoto : foodPhoto // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as GeoPoint?,restaurants: null == restaurants ? _self.restaurants : restaurants // ignore: cast_nullable_to_non_nullable
as List<Restaurant>,selectedId: freezed == selectedId ? _self.selectedId : selectedId // ignore: cast_nullable_to_non_nullable
as String?,photoUri: freezed == photoUri ? _self.photoUri : photoUri // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RestaurantsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoPointCopyWith<$Res>? get origin {
    if (_self.origin == null) {
    return null;
  }

  return $GeoPointCopyWith<$Res>(_self.origin!, (value) {
    return _then(_self.copyWith(origin: value));
  });
}
}


/// Adds pattern-matching-related methods to [RestaurantsState].
extension RestaurantsStatePatterns on RestaurantsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantsState value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantsState value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RestaurantsStatus status,  String foodLabel,  String? foodTheme,  String? foodPhoto,  GeoPoint? origin,  List<Restaurant> restaurants,  String? selectedId,  String? photoUri,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantsState() when $default != null:
return $default(_that.status,_that.foodLabel,_that.foodTheme,_that.foodPhoto,_that.origin,_that.restaurants,_that.selectedId,_that.photoUri,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RestaurantsStatus status,  String foodLabel,  String? foodTheme,  String? foodPhoto,  GeoPoint? origin,  List<Restaurant> restaurants,  String? selectedId,  String? photoUri,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _RestaurantsState():
return $default(_that.status,_that.foodLabel,_that.foodTheme,_that.foodPhoto,_that.origin,_that.restaurants,_that.selectedId,_that.photoUri,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RestaurantsStatus status,  String foodLabel,  String? foodTheme,  String? foodPhoto,  GeoPoint? origin,  List<Restaurant> restaurants,  String? selectedId,  String? photoUri,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantsState() when $default != null:
return $default(_that.status,_that.foodLabel,_that.foodTheme,_that.foodPhoto,_that.origin,_that.restaurants,_that.selectedId,_that.photoUri,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _RestaurantsState extends RestaurantsState {
  const _RestaurantsState({required this.status, this.foodLabel = '', this.foodTheme, this.foodPhoto, this.origin, final  List<Restaurant> restaurants = const [], this.selectedId, this.photoUri, this.errorMessage}): _restaurants = restaurants,super._();
  

@override final  RestaurantsStatus status;
@override@JsonKey() final  String foodLabel;
@override final  String? foodTheme;
/// Category photo asset name, the preview fallback when the place has none.
@override final  String? foodPhoto;
@override final  GeoPoint? origin;
 final  List<Restaurant> _restaurants;
@override@JsonKey() List<Restaurant> get restaurants {
  if (_restaurants is EqualUnmodifiableListView) return _restaurants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_restaurants);
}

@override final  String? selectedId;
/// Photo URL of the selected restaurant, once fetched.
@override final  String? photoUri;
@override final  String? errorMessage;

/// Create a copy of RestaurantsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantsStateCopyWith<_RestaurantsState> get copyWith => __$RestaurantsStateCopyWithImpl<_RestaurantsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantsState&&(identical(other.status, status) || other.status == status)&&(identical(other.foodLabel, foodLabel) || other.foodLabel == foodLabel)&&(identical(other.foodTheme, foodTheme) || other.foodTheme == foodTheme)&&(identical(other.foodPhoto, foodPhoto) || other.foodPhoto == foodPhoto)&&(identical(other.origin, origin) || other.origin == origin)&&const DeepCollectionEquality().equals(other._restaurants, _restaurants)&&(identical(other.selectedId, selectedId) || other.selectedId == selectedId)&&(identical(other.photoUri, photoUri) || other.photoUri == photoUri)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,foodLabel,foodTheme,foodPhoto,origin,const DeepCollectionEquality().hash(_restaurants),selectedId,photoUri,errorMessage);

@override
String toString() {
  return 'RestaurantsState(status: $status, foodLabel: $foodLabel, foodTheme: $foodTheme, foodPhoto: $foodPhoto, origin: $origin, restaurants: $restaurants, selectedId: $selectedId, photoUri: $photoUri, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$RestaurantsStateCopyWith<$Res> implements $RestaurantsStateCopyWith<$Res> {
  factory _$RestaurantsStateCopyWith(_RestaurantsState value, $Res Function(_RestaurantsState) _then) = __$RestaurantsStateCopyWithImpl;
@override @useResult
$Res call({
 RestaurantsStatus status, String foodLabel, String? foodTheme, String? foodPhoto, GeoPoint? origin, List<Restaurant> restaurants, String? selectedId, String? photoUri, String? errorMessage
});


@override $GeoPointCopyWith<$Res>? get origin;

}
/// @nodoc
class __$RestaurantsStateCopyWithImpl<$Res>
    implements _$RestaurantsStateCopyWith<$Res> {
  __$RestaurantsStateCopyWithImpl(this._self, this._then);

  final _RestaurantsState _self;
  final $Res Function(_RestaurantsState) _then;

/// Create a copy of RestaurantsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? foodLabel = null,Object? foodTheme = freezed,Object? foodPhoto = freezed,Object? origin = freezed,Object? restaurants = null,Object? selectedId = freezed,Object? photoUri = freezed,Object? errorMessage = freezed,}) {
  return _then(_RestaurantsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RestaurantsStatus,foodLabel: null == foodLabel ? _self.foodLabel : foodLabel // ignore: cast_nullable_to_non_nullable
as String,foodTheme: freezed == foodTheme ? _self.foodTheme : foodTheme // ignore: cast_nullable_to_non_nullable
as String?,foodPhoto: freezed == foodPhoto ? _self.foodPhoto : foodPhoto // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as GeoPoint?,restaurants: null == restaurants ? _self._restaurants : restaurants // ignore: cast_nullable_to_non_nullable
as List<Restaurant>,selectedId: freezed == selectedId ? _self.selectedId : selectedId // ignore: cast_nullable_to_non_nullable
as String?,photoUri: freezed == photoUri ? _self.photoUri : photoUri // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RestaurantsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoPointCopyWith<$Res>? get origin {
    if (_self.origin == null) {
    return null;
  }

  return $GeoPointCopyWith<$Res>(_self.origin!, (value) {
    return _then(_self.copyWith(origin: value));
  });
}
}

// dart format on
