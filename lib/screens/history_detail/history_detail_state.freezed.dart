// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HistoryDetailState {

 HistoryEntry get entry; FoodCategory get food;/// "O caminho até aqui": the group, then the food ("Salgado", "Macarrão").
 List<String> get path;
/// Create a copy of HistoryDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryDetailStateCopyWith<HistoryDetailState> get copyWith => _$HistoryDetailStateCopyWithImpl<HistoryDetailState>(this as HistoryDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryDetailState&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.food, food) || other.food == food)&&const DeepCollectionEquality().equals(other.path, path));
}


@override
int get hashCode => Object.hash(runtimeType,entry,food,const DeepCollectionEquality().hash(path));

@override
String toString() {
  return 'HistoryDetailState(entry: $entry, food: $food, path: $path)';
}


}

/// @nodoc
abstract mixin class $HistoryDetailStateCopyWith<$Res>  {
  factory $HistoryDetailStateCopyWith(HistoryDetailState value, $Res Function(HistoryDetailState) _then) = _$HistoryDetailStateCopyWithImpl;
@useResult
$Res call({
 HistoryEntry entry, FoodCategory food, List<String> path
});


$HistoryEntryCopyWith<$Res> get entry;$FoodCategoryCopyWith<$Res> get food;

}
/// @nodoc
class _$HistoryDetailStateCopyWithImpl<$Res>
    implements $HistoryDetailStateCopyWith<$Res> {
  _$HistoryDetailStateCopyWithImpl(this._self, this._then);

  final HistoryDetailState _self;
  final $Res Function(HistoryDetailState) _then;

/// Create a copy of HistoryDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entry = null,Object? food = null,Object? path = null,}) {
  return _then(_self.copyWith(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as HistoryEntry,food: null == food ? _self.food : food // ignore: cast_nullable_to_non_nullable
as FoodCategory,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of HistoryDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HistoryEntryCopyWith<$Res> get entry {
  
  return $HistoryEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}/// Create a copy of HistoryDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get food {
  
  return $FoodCategoryCopyWith<$Res>(_self.food, (value) {
    return _then(_self.copyWith(food: value));
  });
}
}


/// Adds pattern-matching-related methods to [HistoryDetailState].
extension HistoryDetailStatePatterns on HistoryDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryDetailState value)  $default,){
final _that = this;
switch (_that) {
case _HistoryDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HistoryEntry entry,  FoodCategory food,  List<String> path)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryDetailState() when $default != null:
return $default(_that.entry,_that.food,_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HistoryEntry entry,  FoodCategory food,  List<String> path)  $default,) {final _that = this;
switch (_that) {
case _HistoryDetailState():
return $default(_that.entry,_that.food,_that.path);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HistoryEntry entry,  FoodCategory food,  List<String> path)?  $default,) {final _that = this;
switch (_that) {
case _HistoryDetailState() when $default != null:
return $default(_that.entry,_that.food,_that.path);case _:
  return null;

}
}

}

/// @nodoc


class _HistoryDetailState extends HistoryDetailState {
  const _HistoryDetailState({required this.entry, required this.food, required final  List<String> path}): _path = path,super._();
  

@override final  HistoryEntry entry;
@override final  FoodCategory food;
/// "O caminho até aqui": the group, then the food ("Salgado", "Macarrão").
 final  List<String> _path;
/// "O caminho até aqui": the group, then the food ("Salgado", "Macarrão").
@override List<String> get path {
  if (_path is EqualUnmodifiableListView) return _path;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_path);
}


/// Create a copy of HistoryDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryDetailStateCopyWith<_HistoryDetailState> get copyWith => __$HistoryDetailStateCopyWithImpl<_HistoryDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryDetailState&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.food, food) || other.food == food)&&const DeepCollectionEquality().equals(other._path, _path));
}


@override
int get hashCode => Object.hash(runtimeType,entry,food,const DeepCollectionEquality().hash(_path));

@override
String toString() {
  return 'HistoryDetailState(entry: $entry, food: $food, path: $path)';
}


}

/// @nodoc
abstract mixin class _$HistoryDetailStateCopyWith<$Res> implements $HistoryDetailStateCopyWith<$Res> {
  factory _$HistoryDetailStateCopyWith(_HistoryDetailState value, $Res Function(_HistoryDetailState) _then) = __$HistoryDetailStateCopyWithImpl;
@override @useResult
$Res call({
 HistoryEntry entry, FoodCategory food, List<String> path
});


@override $HistoryEntryCopyWith<$Res> get entry;@override $FoodCategoryCopyWith<$Res> get food;

}
/// @nodoc
class __$HistoryDetailStateCopyWithImpl<$Res>
    implements _$HistoryDetailStateCopyWith<$Res> {
  __$HistoryDetailStateCopyWithImpl(this._self, this._then);

  final _HistoryDetailState _self;
  final $Res Function(_HistoryDetailState) _then;

/// Create a copy of HistoryDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entry = null,Object? food = null,Object? path = null,}) {
  return _then(_HistoryDetailState(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as HistoryEntry,food: null == food ? _self.food : food // ignore: cast_nullable_to_non_nullable
as FoodCategory,path: null == path ? _self._path : path // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of HistoryDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HistoryEntryCopyWith<$Res> get entry {
  
  return $HistoryEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}/// Create a copy of HistoryDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get food {
  
  return $FoodCategoryCopyWith<$Res>(_self.food, (value) {
    return _then(_self.copyWith(food: value));
  });
}
}

// dart format on
