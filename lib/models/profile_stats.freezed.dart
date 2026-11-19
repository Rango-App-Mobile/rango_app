// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileStats {

 int get decisionCount; String? get favoriteFood; String? get favoriteRestaurant;
/// Create a copy of ProfileStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileStatsCopyWith<ProfileStats> get copyWith => _$ProfileStatsCopyWithImpl<ProfileStats>(this as ProfileStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileStats&&(identical(other.decisionCount, decisionCount) || other.decisionCount == decisionCount)&&(identical(other.favoriteFood, favoriteFood) || other.favoriteFood == favoriteFood)&&(identical(other.favoriteRestaurant, favoriteRestaurant) || other.favoriteRestaurant == favoriteRestaurant));
}


@override
int get hashCode => Object.hash(runtimeType,decisionCount,favoriteFood,favoriteRestaurant);

@override
String toString() {
  return 'ProfileStats(decisionCount: $decisionCount, favoriteFood: $favoriteFood, favoriteRestaurant: $favoriteRestaurant)';
}


}

/// @nodoc
abstract mixin class $ProfileStatsCopyWith<$Res>  {
  factory $ProfileStatsCopyWith(ProfileStats value, $Res Function(ProfileStats) _then) = _$ProfileStatsCopyWithImpl;
@useResult
$Res call({
 int decisionCount, String? favoriteFood, String? favoriteRestaurant
});




}
/// @nodoc
class _$ProfileStatsCopyWithImpl<$Res>
    implements $ProfileStatsCopyWith<$Res> {
  _$ProfileStatsCopyWithImpl(this._self, this._then);

  final ProfileStats _self;
  final $Res Function(ProfileStats) _then;

/// Create a copy of ProfileStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? decisionCount = null,Object? favoriteFood = freezed,Object? favoriteRestaurant = freezed,}) {
  return _then(_self.copyWith(
decisionCount: null == decisionCount ? _self.decisionCount : decisionCount // ignore: cast_nullable_to_non_nullable
as int,favoriteFood: freezed == favoriteFood ? _self.favoriteFood : favoriteFood // ignore: cast_nullable_to_non_nullable
as String?,favoriteRestaurant: freezed == favoriteRestaurant ? _self.favoriteRestaurant : favoriteRestaurant // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileStats].
extension ProfileStatsPatterns on ProfileStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileStats value)  $default,){
final _that = this;
switch (_that) {
case _ProfileStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileStats value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int decisionCount,  String? favoriteFood,  String? favoriteRestaurant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileStats() when $default != null:
return $default(_that.decisionCount,_that.favoriteFood,_that.favoriteRestaurant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int decisionCount,  String? favoriteFood,  String? favoriteRestaurant)  $default,) {final _that = this;
switch (_that) {
case _ProfileStats():
return $default(_that.decisionCount,_that.favoriteFood,_that.favoriteRestaurant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int decisionCount,  String? favoriteFood,  String? favoriteRestaurant)?  $default,) {final _that = this;
switch (_that) {
case _ProfileStats() when $default != null:
return $default(_that.decisionCount,_that.favoriteFood,_that.favoriteRestaurant);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileStats implements ProfileStats {
  const _ProfileStats({required this.decisionCount, this.favoriteFood, this.favoriteRestaurant});


@override final  int decisionCount;
@override final  String? favoriteFood;
@override final  String? favoriteRestaurant;

/// Create a copy of ProfileStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStatsCopyWith<_ProfileStats> get copyWith => __$ProfileStatsCopyWithImpl<_ProfileStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileStats&&(identical(other.decisionCount, decisionCount) || other.decisionCount == decisionCount)&&(identical(other.favoriteFood, favoriteFood) || other.favoriteFood == favoriteFood)&&(identical(other.favoriteRestaurant, favoriteRestaurant) || other.favoriteRestaurant == favoriteRestaurant));
}


@override
int get hashCode => Object.hash(runtimeType,decisionCount,favoriteFood,favoriteRestaurant);

@override
String toString() {
  return 'ProfileStats(decisionCount: $decisionCount, favoriteFood: $favoriteFood, favoriteRestaurant: $favoriteRestaurant)';
}


}

/// @nodoc
abstract mixin class _$ProfileStatsCopyWith<$Res> implements $ProfileStatsCopyWith<$Res> {
  factory _$ProfileStatsCopyWith(_ProfileStats value, $Res Function(_ProfileStats) _then) = __$ProfileStatsCopyWithImpl;
@override @useResult
$Res call({
 int decisionCount, String? favoriteFood, String? favoriteRestaurant
});




}
/// @nodoc
class __$ProfileStatsCopyWithImpl<$Res>
    implements _$ProfileStatsCopyWith<$Res> {
  __$ProfileStatsCopyWithImpl(this._self, this._then);

  final _ProfileStats _self;
  final $Res Function(_ProfileStats) _then;

/// Create a copy of ProfileStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? decisionCount = null,Object? favoriteFood = freezed,Object? favoriteRestaurant = freezed,}) {
  return _then(_ProfileStats(
decisionCount: null == decisionCount ? _self.decisionCount : decisionCount // ignore: cast_nullable_to_non_nullable
as int,favoriteFood: freezed == favoriteFood ? _self.favoriteFood : favoriteFood // ignore: cast_nullable_to_non_nullable
as String?,favoriteRestaurant: freezed == favoriteRestaurant ? _self.favoriteRestaurant : favoriteRestaurant // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
