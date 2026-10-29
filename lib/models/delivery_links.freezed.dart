// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_links.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeliveryLinks {

 String? get ifood; List<String> get others;
/// Create a copy of DeliveryLinks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryLinksCopyWith<DeliveryLinks> get copyWith => _$DeliveryLinksCopyWithImpl<DeliveryLinks>(this as DeliveryLinks, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryLinks&&(identical(other.ifood, ifood) || other.ifood == ifood)&&const DeepCollectionEquality().equals(other.others, others));
}


@override
int get hashCode => Object.hash(runtimeType,ifood,const DeepCollectionEquality().hash(others));

@override
String toString() {
  return 'DeliveryLinks(ifood: $ifood, others: $others)';
}


}

/// @nodoc
abstract mixin class $DeliveryLinksCopyWith<$Res>  {
  factory $DeliveryLinksCopyWith(DeliveryLinks value, $Res Function(DeliveryLinks) _then) = _$DeliveryLinksCopyWithImpl;
@useResult
$Res call({
 String? ifood, List<String> others
});




}
/// @nodoc
class _$DeliveryLinksCopyWithImpl<$Res>
    implements $DeliveryLinksCopyWith<$Res> {
  _$DeliveryLinksCopyWithImpl(this._self, this._then);

  final DeliveryLinks _self;
  final $Res Function(DeliveryLinks) _then;

/// Create a copy of DeliveryLinks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ifood = freezed,Object? others = null,}) {
  return _then(_self.copyWith(
ifood: freezed == ifood ? _self.ifood : ifood // ignore: cast_nullable_to_non_nullable
as String?,others: null == others ? _self.others : others // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryLinks].
extension DeliveryLinksPatterns on DeliveryLinks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryLinks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryLinks() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryLinks value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryLinks():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryLinks value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryLinks() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? ifood,  List<String> others)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryLinks() when $default != null:
return $default(_that.ifood,_that.others);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? ifood,  List<String> others)  $default,) {final _that = this;
switch (_that) {
case _DeliveryLinks():
return $default(_that.ifood,_that.others);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? ifood,  List<String> others)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryLinks() when $default != null:
return $default(_that.ifood,_that.others);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryLinks implements DeliveryLinks {
  const _DeliveryLinks({this.ifood, final  List<String> others = const <String>[]}): _others = others;
  

@override final  String? ifood;
 final  List<String> _others;
@override@JsonKey() List<String> get others {
  if (_others is EqualUnmodifiableListView) return _others;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_others);
}


/// Create a copy of DeliveryLinks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryLinksCopyWith<_DeliveryLinks> get copyWith => __$DeliveryLinksCopyWithImpl<_DeliveryLinks>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryLinks&&(identical(other.ifood, ifood) || other.ifood == ifood)&&const DeepCollectionEquality().equals(other._others, _others));
}


@override
int get hashCode => Object.hash(runtimeType,ifood,const DeepCollectionEquality().hash(_others));

@override
String toString() {
  return 'DeliveryLinks(ifood: $ifood, others: $others)';
}


}

/// @nodoc
abstract mixin class _$DeliveryLinksCopyWith<$Res> implements $DeliveryLinksCopyWith<$Res> {
  factory _$DeliveryLinksCopyWith(_DeliveryLinks value, $Res Function(_DeliveryLinks) _then) = __$DeliveryLinksCopyWithImpl;
@override @useResult
$Res call({
 String? ifood, List<String> others
});




}
/// @nodoc
class __$DeliveryLinksCopyWithImpl<$Res>
    implements _$DeliveryLinksCopyWith<$Res> {
  __$DeliveryLinksCopyWithImpl(this._self, this._then);

  final _DeliveryLinks _self;
  final $Res Function(_DeliveryLinks) _then;

/// Create a copy of DeliveryLinks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ifood = freezed,Object? others = null,}) {
  return _then(_DeliveryLinks(
ifood: freezed == ifood ? _self.ifood : ifood // ignore: cast_nullable_to_non_nullable
as String?,others: null == others ? _self._others : others // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
