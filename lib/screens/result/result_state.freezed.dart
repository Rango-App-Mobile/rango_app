// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResultState {

 FoodCategory get result; List<FoodCategory> get path;
/// Create a copy of ResultState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultStateCopyWith<ResultState> get copyWith => _$ResultStateCopyWithImpl<ResultState>(this as ResultState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultState&&(identical(other.result, result) || other.result == result)&&const DeepCollectionEquality().equals(other.path, path));
}


@override
int get hashCode => Object.hash(runtimeType,result,const DeepCollectionEquality().hash(path));

@override
String toString() {
  return 'ResultState(result: $result, path: $path)';
}


}

/// @nodoc
abstract mixin class $ResultStateCopyWith<$Res>  {
  factory $ResultStateCopyWith(ResultState value, $Res Function(ResultState) _then) = _$ResultStateCopyWithImpl;
@useResult
$Res call({
 FoodCategory result, List<FoodCategory> path
});


$FoodCategoryCopyWith<$Res> get result;

}
/// @nodoc
class _$ResultStateCopyWithImpl<$Res>
    implements $ResultStateCopyWith<$Res> {
  _$ResultStateCopyWithImpl(this._self, this._then);

  final ResultState _self;
  final $Res Function(ResultState) _then;

/// Create a copy of ResultState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? result = null,Object? path = null,}) {
  return _then(_self.copyWith(
result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as FoodCategory,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as List<FoodCategory>,
  ));
}
/// Create a copy of ResultState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get result {
  
  return $FoodCategoryCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [ResultState].
extension ResultStatePatterns on ResultState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultState value)  $default,){
final _that = this;
switch (_that) {
case _ResultState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultState value)?  $default,){
final _that = this;
switch (_that) {
case _ResultState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FoodCategory result,  List<FoodCategory> path)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultState() when $default != null:
return $default(_that.result,_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FoodCategory result,  List<FoodCategory> path)  $default,) {final _that = this;
switch (_that) {
case _ResultState():
return $default(_that.result,_that.path);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FoodCategory result,  List<FoodCategory> path)?  $default,) {final _that = this;
switch (_that) {
case _ResultState() when $default != null:
return $default(_that.result,_that.path);case _:
  return null;

}
}

}

/// @nodoc


class _ResultState extends ResultState {
  const _ResultState({required this.result, required final  List<FoodCategory> path}): _path = path,super._();
  

@override final  FoodCategory result;
 final  List<FoodCategory> _path;
@override List<FoodCategory> get path {
  if (_path is EqualUnmodifiableListView) return _path;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_path);
}


/// Create a copy of ResultState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultStateCopyWith<_ResultState> get copyWith => __$ResultStateCopyWithImpl<_ResultState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultState&&(identical(other.result, result) || other.result == result)&&const DeepCollectionEquality().equals(other._path, _path));
}


@override
int get hashCode => Object.hash(runtimeType,result,const DeepCollectionEquality().hash(_path));

@override
String toString() {
  return 'ResultState(result: $result, path: $path)';
}


}

/// @nodoc
abstract mixin class _$ResultStateCopyWith<$Res> implements $ResultStateCopyWith<$Res> {
  factory _$ResultStateCopyWith(_ResultState value, $Res Function(_ResultState) _then) = __$ResultStateCopyWithImpl;
@override @useResult
$Res call({
 FoodCategory result, List<FoodCategory> path
});


@override $FoodCategoryCopyWith<$Res> get result;

}
/// @nodoc
class __$ResultStateCopyWithImpl<$Res>
    implements _$ResultStateCopyWith<$Res> {
  __$ResultStateCopyWithImpl(this._self, this._then);

  final _ResultState _self;
  final $Res Function(_ResultState) _then;

/// Create a copy of ResultState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? result = null,Object? path = null,}) {
  return _then(_ResultState(
result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as FoodCategory,path: null == path ? _self._path : path // ignore: cast_nullable_to_non_nullable
as List<FoodCategory>,
  ));
}

/// Create a copy of ResultState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get result {
  
  return $FoodCategoryCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

// dart format on
