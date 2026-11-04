// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant_contact_args.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RestaurantContactArgs {

 Restaurant get restaurant;/// `FoodCategory.foodTheme` of the chosen food, for the photo placeholder.
 String? get foodTheme;/// Photo URL the map already fetched for the selected pin, if any.
 String? get photoUri;
/// Create a copy of RestaurantContactArgs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantContactArgsCopyWith<RestaurantContactArgs> get copyWith => _$RestaurantContactArgsCopyWithImpl<RestaurantContactArgs>(this as RestaurantContactArgs, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantContactArgs&&(identical(other.restaurant, restaurant) || other.restaurant == restaurant)&&(identical(other.foodTheme, foodTheme) || other.foodTheme == foodTheme)&&(identical(other.photoUri, photoUri) || other.photoUri == photoUri));
}


@override
int get hashCode => Object.hash(runtimeType,restaurant,foodTheme,photoUri);

@override
String toString() {
  return 'RestaurantContactArgs(restaurant: $restaurant, foodTheme: $foodTheme, photoUri: $photoUri)';
}


}

/// @nodoc
abstract mixin class $RestaurantContactArgsCopyWith<$Res>  {
  factory $RestaurantContactArgsCopyWith(RestaurantContactArgs value, $Res Function(RestaurantContactArgs) _then) = _$RestaurantContactArgsCopyWithImpl;
@useResult
$Res call({
 Restaurant restaurant, String? foodTheme, String? photoUri
});


$RestaurantCopyWith<$Res> get restaurant;

}
/// @nodoc
class _$RestaurantContactArgsCopyWithImpl<$Res>
    implements $RestaurantContactArgsCopyWith<$Res> {
  _$RestaurantContactArgsCopyWithImpl(this._self, this._then);

  final RestaurantContactArgs _self;
  final $Res Function(RestaurantContactArgs) _then;

/// Create a copy of RestaurantContactArgs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? restaurant = null,Object? foodTheme = freezed,Object? photoUri = freezed,}) {
  return _then(_self.copyWith(
restaurant: null == restaurant ? _self.restaurant : restaurant // ignore: cast_nullable_to_non_nullable
as Restaurant,foodTheme: freezed == foodTheme ? _self.foodTheme : foodTheme // ignore: cast_nullable_to_non_nullable
as String?,photoUri: freezed == photoUri ? _self.photoUri : photoUri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RestaurantContactArgs
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantCopyWith<$Res> get restaurant {
  
  return $RestaurantCopyWith<$Res>(_self.restaurant, (value) {
    return _then(_self.copyWith(restaurant: value));
  });
}
}


/// Adds pattern-matching-related methods to [RestaurantContactArgs].
extension RestaurantContactArgsPatterns on RestaurantContactArgs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantContactArgs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantContactArgs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantContactArgs value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantContactArgs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantContactArgs value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantContactArgs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Restaurant restaurant,  String? foodTheme,  String? photoUri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantContactArgs() when $default != null:
return $default(_that.restaurant,_that.foodTheme,_that.photoUri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Restaurant restaurant,  String? foodTheme,  String? photoUri)  $default,) {final _that = this;
switch (_that) {
case _RestaurantContactArgs():
return $default(_that.restaurant,_that.foodTheme,_that.photoUri);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Restaurant restaurant,  String? foodTheme,  String? photoUri)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantContactArgs() when $default != null:
return $default(_that.restaurant,_that.foodTheme,_that.photoUri);case _:
  return null;

}
}

}

/// @nodoc


class _RestaurantContactArgs implements RestaurantContactArgs {
  const _RestaurantContactArgs({required this.restaurant, this.foodTheme, this.photoUri});
  

@override final  Restaurant restaurant;
/// `FoodCategory.foodTheme` of the chosen food, for the photo placeholder.
@override final  String? foodTheme;
/// Photo URL the map already fetched for the selected pin, if any.
@override final  String? photoUri;

/// Create a copy of RestaurantContactArgs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantContactArgsCopyWith<_RestaurantContactArgs> get copyWith => __$RestaurantContactArgsCopyWithImpl<_RestaurantContactArgs>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantContactArgs&&(identical(other.restaurant, restaurant) || other.restaurant == restaurant)&&(identical(other.foodTheme, foodTheme) || other.foodTheme == foodTheme)&&(identical(other.photoUri, photoUri) || other.photoUri == photoUri));
}


@override
int get hashCode => Object.hash(runtimeType,restaurant,foodTheme,photoUri);

@override
String toString() {
  return 'RestaurantContactArgs(restaurant: $restaurant, foodTheme: $foodTheme, photoUri: $photoUri)';
}


}

/// @nodoc
abstract mixin class _$RestaurantContactArgsCopyWith<$Res> implements $RestaurantContactArgsCopyWith<$Res> {
  factory _$RestaurantContactArgsCopyWith(_RestaurantContactArgs value, $Res Function(_RestaurantContactArgs) _then) = __$RestaurantContactArgsCopyWithImpl;
@override @useResult
$Res call({
 Restaurant restaurant, String? foodTheme, String? photoUri
});


@override $RestaurantCopyWith<$Res> get restaurant;

}
/// @nodoc
class __$RestaurantContactArgsCopyWithImpl<$Res>
    implements _$RestaurantContactArgsCopyWith<$Res> {
  __$RestaurantContactArgsCopyWithImpl(this._self, this._then);

  final _RestaurantContactArgs _self;
  final $Res Function(_RestaurantContactArgs) _then;

/// Create a copy of RestaurantContactArgs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? restaurant = null,Object? foodTheme = freezed,Object? photoUri = freezed,}) {
  return _then(_RestaurantContactArgs(
restaurant: null == restaurant ? _self.restaurant : restaurant // ignore: cast_nullable_to_non_nullable
as Restaurant,foodTheme: freezed == foodTheme ? _self.foodTheme : foodTheme // ignore: cast_nullable_to_non_nullable
as String?,photoUri: freezed == photoUri ? _self.photoUri : photoUri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RestaurantContactArgs
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantCopyWith<$Res> get restaurant {
  
  return $RestaurantCopyWith<$Res>(_self.restaurant, (value) {
    return _then(_self.copyWith(restaurant: value));
  });
}
}

// dart format on
