// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant_contact_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RestaurantContactState {

 RestaurantContactArgs get args;/// True until phone, links and photo have resolved.
 bool get loadingDetails; DeliveryLinks? get links; String? get phone; String? get photoUri;/// An external app could not be opened; the View shows a message once.
 bool get openFailed;
/// Create a copy of RestaurantContactState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantContactStateCopyWith<RestaurantContactState> get copyWith => _$RestaurantContactStateCopyWithImpl<RestaurantContactState>(this as RestaurantContactState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantContactState&&(identical(other.args, args) || other.args == args)&&(identical(other.loadingDetails, loadingDetails) || other.loadingDetails == loadingDetails)&&(identical(other.links, links) || other.links == links)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoUri, photoUri) || other.photoUri == photoUri)&&(identical(other.openFailed, openFailed) || other.openFailed == openFailed));
}


@override
int get hashCode => Object.hash(runtimeType,args,loadingDetails,links,phone,photoUri,openFailed);

@override
String toString() {
  return 'RestaurantContactState(args: $args, loadingDetails: $loadingDetails, links: $links, phone: $phone, photoUri: $photoUri, openFailed: $openFailed)';
}


}

/// @nodoc
abstract mixin class $RestaurantContactStateCopyWith<$Res>  {
  factory $RestaurantContactStateCopyWith(RestaurantContactState value, $Res Function(RestaurantContactState) _then) = _$RestaurantContactStateCopyWithImpl;
@useResult
$Res call({
 RestaurantContactArgs args, bool loadingDetails, DeliveryLinks? links, String? phone, String? photoUri, bool openFailed
});


$RestaurantContactArgsCopyWith<$Res> get args;$DeliveryLinksCopyWith<$Res>? get links;

}
/// @nodoc
class _$RestaurantContactStateCopyWithImpl<$Res>
    implements $RestaurantContactStateCopyWith<$Res> {
  _$RestaurantContactStateCopyWithImpl(this._self, this._then);

  final RestaurantContactState _self;
  final $Res Function(RestaurantContactState) _then;

/// Create a copy of RestaurantContactState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? args = null,Object? loadingDetails = null,Object? links = freezed,Object? phone = freezed,Object? photoUri = freezed,Object? openFailed = null,}) {
  return _then(_self.copyWith(
args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as RestaurantContactArgs,loadingDetails: null == loadingDetails ? _self.loadingDetails : loadingDetails // ignore: cast_nullable_to_non_nullable
as bool,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as DeliveryLinks?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoUri: freezed == photoUri ? _self.photoUri : photoUri // ignore: cast_nullable_to_non_nullable
as String?,openFailed: null == openFailed ? _self.openFailed : openFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RestaurantContactState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantContactArgsCopyWith<$Res> get args {
  
  return $RestaurantContactArgsCopyWith<$Res>(_self.args, (value) {
    return _then(_self.copyWith(args: value));
  });
}/// Create a copy of RestaurantContactState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryLinksCopyWith<$Res>? get links {
    if (_self.links == null) {
    return null;
  }

  return $DeliveryLinksCopyWith<$Res>(_self.links!, (value) {
    return _then(_self.copyWith(links: value));
  });
}
}


/// Adds pattern-matching-related methods to [RestaurantContactState].
extension RestaurantContactStatePatterns on RestaurantContactState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantContactState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantContactState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantContactState value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantContactState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantContactState value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantContactState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RestaurantContactArgs args,  bool loadingDetails,  DeliveryLinks? links,  String? phone,  String? photoUri,  bool openFailed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantContactState() when $default != null:
return $default(_that.args,_that.loadingDetails,_that.links,_that.phone,_that.photoUri,_that.openFailed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RestaurantContactArgs args,  bool loadingDetails,  DeliveryLinks? links,  String? phone,  String? photoUri,  bool openFailed)  $default,) {final _that = this;
switch (_that) {
case _RestaurantContactState():
return $default(_that.args,_that.loadingDetails,_that.links,_that.phone,_that.photoUri,_that.openFailed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RestaurantContactArgs args,  bool loadingDetails,  DeliveryLinks? links,  String? phone,  String? photoUri,  bool openFailed)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantContactState() when $default != null:
return $default(_that.args,_that.loadingDetails,_that.links,_that.phone,_that.photoUri,_that.openFailed);case _:
  return null;

}
}

}

/// @nodoc


class _RestaurantContactState extends RestaurantContactState {
  const _RestaurantContactState({required this.args, this.loadingDetails = true, this.links, this.phone, this.photoUri, this.openFailed = false}): super._();
  

@override final  RestaurantContactArgs args;
/// True until phone, links and photo have resolved.
@override@JsonKey() final  bool loadingDetails;
@override final  DeliveryLinks? links;
@override final  String? phone;
@override final  String? photoUri;
/// An external app could not be opened; the View shows a message once.
@override@JsonKey() final  bool openFailed;

/// Create a copy of RestaurantContactState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantContactStateCopyWith<_RestaurantContactState> get copyWith => __$RestaurantContactStateCopyWithImpl<_RestaurantContactState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantContactState&&(identical(other.args, args) || other.args == args)&&(identical(other.loadingDetails, loadingDetails) || other.loadingDetails == loadingDetails)&&(identical(other.links, links) || other.links == links)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoUri, photoUri) || other.photoUri == photoUri)&&(identical(other.openFailed, openFailed) || other.openFailed == openFailed));
}


@override
int get hashCode => Object.hash(runtimeType,args,loadingDetails,links,phone,photoUri,openFailed);

@override
String toString() {
  return 'RestaurantContactState(args: $args, loadingDetails: $loadingDetails, links: $links, phone: $phone, photoUri: $photoUri, openFailed: $openFailed)';
}


}

/// @nodoc
abstract mixin class _$RestaurantContactStateCopyWith<$Res> implements $RestaurantContactStateCopyWith<$Res> {
  factory _$RestaurantContactStateCopyWith(_RestaurantContactState value, $Res Function(_RestaurantContactState) _then) = __$RestaurantContactStateCopyWithImpl;
@override @useResult
$Res call({
 RestaurantContactArgs args, bool loadingDetails, DeliveryLinks? links, String? phone, String? photoUri, bool openFailed
});


@override $RestaurantContactArgsCopyWith<$Res> get args;@override $DeliveryLinksCopyWith<$Res>? get links;

}
/// @nodoc
class __$RestaurantContactStateCopyWithImpl<$Res>
    implements _$RestaurantContactStateCopyWith<$Res> {
  __$RestaurantContactStateCopyWithImpl(this._self, this._then);

  final _RestaurantContactState _self;
  final $Res Function(_RestaurantContactState) _then;

/// Create a copy of RestaurantContactState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? args = null,Object? loadingDetails = null,Object? links = freezed,Object? phone = freezed,Object? photoUri = freezed,Object? openFailed = null,}) {
  return _then(_RestaurantContactState(
args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as RestaurantContactArgs,loadingDetails: null == loadingDetails ? _self.loadingDetails : loadingDetails // ignore: cast_nullable_to_non_nullable
as bool,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as DeliveryLinks?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoUri: freezed == photoUri ? _self.photoUri : photoUri // ignore: cast_nullable_to_non_nullable
as String?,openFailed: null == openFailed ? _self.openFailed : openFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RestaurantContactState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantContactArgsCopyWith<$Res> get args {
  
  return $RestaurantContactArgsCopyWith<$Res>(_self.args, (value) {
    return _then(_self.copyWith(args: value));
  });
}/// Create a copy of RestaurantContactState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryLinksCopyWith<$Res>? get links {
    if (_self.links == null) {
    return null;
  }

  return $DeliveryLinksCopyWith<$Res>(_self.links!, (value) {
    return _then(_self.copyWith(links: value));
  });
}
}

// dart format on
