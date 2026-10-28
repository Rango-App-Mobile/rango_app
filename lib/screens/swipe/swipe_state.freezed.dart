// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swipe_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SwipeState {

 FoodCategory get current; List<FoodCategory> get options; List<FoodCategory> get history;/// Null at the root; set once the user picks Salgado or Doce.
 DuelState? get duel; FoodCategory? get result;
/// Create a copy of SwipeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwipeStateCopyWith<SwipeState> get copyWith => _$SwipeStateCopyWithImpl<SwipeState>(this as SwipeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwipeState&&(identical(other.current, current) || other.current == current)&&const DeepCollectionEquality().equals(other.options, options)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.duel, duel) || other.duel == duel)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,current,const DeepCollectionEquality().hash(options),const DeepCollectionEquality().hash(history),duel,result);

@override
String toString() {
  return 'SwipeState(current: $current, options: $options, history: $history, duel: $duel, result: $result)';
}


}

/// @nodoc
abstract mixin class $SwipeStateCopyWith<$Res>  {
  factory $SwipeStateCopyWith(SwipeState value, $Res Function(SwipeState) _then) = _$SwipeStateCopyWithImpl;
@useResult
$Res call({
 FoodCategory current, List<FoodCategory> options, List<FoodCategory> history, DuelState? duel, FoodCategory? result
});


$FoodCategoryCopyWith<$Res> get current;$DuelStateCopyWith<$Res>? get duel;$FoodCategoryCopyWith<$Res>? get result;

}
/// @nodoc
class _$SwipeStateCopyWithImpl<$Res>
    implements $SwipeStateCopyWith<$Res> {
  _$SwipeStateCopyWithImpl(this._self, this._then);

  final SwipeState _self;
  final $Res Function(SwipeState) _then;

/// Create a copy of SwipeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? options = null,Object? history = null,Object? duel = freezed,Object? result = freezed,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as FoodCategory,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<FoodCategory>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<FoodCategory>,duel: freezed == duel ? _self.duel : duel // ignore: cast_nullable_to_non_nullable
as DuelState?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as FoodCategory?,
  ));
}
/// Create a copy of SwipeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get current {
  
  return $FoodCategoryCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of SwipeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DuelStateCopyWith<$Res>? get duel {
    if (_self.duel == null) {
    return null;
  }

  return $DuelStateCopyWith<$Res>(_self.duel!, (value) {
    return _then(_self.copyWith(duel: value));
  });
}/// Create a copy of SwipeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $FoodCategoryCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [SwipeState].
extension SwipeStatePatterns on SwipeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwipeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwipeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwipeState value)  $default,){
final _that = this;
switch (_that) {
case _SwipeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwipeState value)?  $default,){
final _that = this;
switch (_that) {
case _SwipeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FoodCategory current,  List<FoodCategory> options,  List<FoodCategory> history,  DuelState? duel,  FoodCategory? result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwipeState() when $default != null:
return $default(_that.current,_that.options,_that.history,_that.duel,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FoodCategory current,  List<FoodCategory> options,  List<FoodCategory> history,  DuelState? duel,  FoodCategory? result)  $default,) {final _that = this;
switch (_that) {
case _SwipeState():
return $default(_that.current,_that.options,_that.history,_that.duel,_that.result);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FoodCategory current,  List<FoodCategory> options,  List<FoodCategory> history,  DuelState? duel,  FoodCategory? result)?  $default,) {final _that = this;
switch (_that) {
case _SwipeState() when $default != null:
return $default(_that.current,_that.options,_that.history,_that.duel,_that.result);case _:
  return null;

}
}

}

/// @nodoc


class _SwipeState extends SwipeState {
  const _SwipeState({required this.current, required final  List<FoodCategory> options, final  List<FoodCategory> history = const <FoodCategory>[], this.duel, this.result}): _options = options,_history = history,super._();
  

@override final  FoodCategory current;
 final  List<FoodCategory> _options;
@override List<FoodCategory> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  List<FoodCategory> _history;
@override@JsonKey() List<FoodCategory> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

/// Null at the root; set once the user picks Salgado or Doce.
@override final  DuelState? duel;
@override final  FoodCategory? result;

/// Create a copy of SwipeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwipeStateCopyWith<_SwipeState> get copyWith => __$SwipeStateCopyWithImpl<_SwipeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwipeState&&(identical(other.current, current) || other.current == current)&&const DeepCollectionEquality().equals(other._options, _options)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.duel, duel) || other.duel == duel)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,current,const DeepCollectionEquality().hash(_options),const DeepCollectionEquality().hash(_history),duel,result);

@override
String toString() {
  return 'SwipeState(current: $current, options: $options, history: $history, duel: $duel, result: $result)';
}


}

/// @nodoc
abstract mixin class _$SwipeStateCopyWith<$Res> implements $SwipeStateCopyWith<$Res> {
  factory _$SwipeStateCopyWith(_SwipeState value, $Res Function(_SwipeState) _then) = __$SwipeStateCopyWithImpl;
@override @useResult
$Res call({
 FoodCategory current, List<FoodCategory> options, List<FoodCategory> history, DuelState? duel, FoodCategory? result
});


@override $FoodCategoryCopyWith<$Res> get current;@override $DuelStateCopyWith<$Res>? get duel;@override $FoodCategoryCopyWith<$Res>? get result;

}
/// @nodoc
class __$SwipeStateCopyWithImpl<$Res>
    implements _$SwipeStateCopyWith<$Res> {
  __$SwipeStateCopyWithImpl(this._self, this._then);

  final _SwipeState _self;
  final $Res Function(_SwipeState) _then;

/// Create a copy of SwipeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? options = null,Object? history = null,Object? duel = freezed,Object? result = freezed,}) {
  return _then(_SwipeState(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as FoodCategory,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<FoodCategory>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<FoodCategory>,duel: freezed == duel ? _self.duel : duel // ignore: cast_nullable_to_non_nullable
as DuelState?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as FoodCategory?,
  ));
}

/// Create a copy of SwipeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get current {
  
  return $FoodCategoryCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of SwipeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DuelStateCopyWith<$Res>? get duel {
    if (_self.duel == null) {
    return null;
  }

  return $DuelStateCopyWith<$Res>(_self.duel!, (value) {
    return _then(_self.copyWith(duel: value));
  });
}/// Create a copy of SwipeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $FoodCategoryCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

// dart format on
