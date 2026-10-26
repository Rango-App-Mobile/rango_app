// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'duel_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DuelState {

 FoodCategory get champion; FoodCategory get challenger; List<FoodCategory> get queue; int get streak; FoodCategory? get winner;
/// Create a copy of DuelState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DuelStateCopyWith<DuelState> get copyWith => _$DuelStateCopyWithImpl<DuelState>(this as DuelState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DuelState&&(identical(other.champion, champion) || other.champion == champion)&&(identical(other.challenger, challenger) || other.challenger == challenger)&&const DeepCollectionEquality().equals(other.queue, queue)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.winner, winner) || other.winner == winner));
}


@override
int get hashCode => Object.hash(runtimeType,champion,challenger,const DeepCollectionEquality().hash(queue),streak,winner);

@override
String toString() {
  return 'DuelState(champion: $champion, challenger: $challenger, queue: $queue, streak: $streak, winner: $winner)';
}


}

/// @nodoc
abstract mixin class $DuelStateCopyWith<$Res>  {
  factory $DuelStateCopyWith(DuelState value, $Res Function(DuelState) _then) = _$DuelStateCopyWithImpl;
@useResult
$Res call({
 FoodCategory champion, FoodCategory challenger, List<FoodCategory> queue, int streak, FoodCategory? winner
});


$FoodCategoryCopyWith<$Res> get champion;$FoodCategoryCopyWith<$Res> get challenger;$FoodCategoryCopyWith<$Res>? get winner;

}
/// @nodoc
class _$DuelStateCopyWithImpl<$Res>
    implements $DuelStateCopyWith<$Res> {
  _$DuelStateCopyWithImpl(this._self, this._then);

  final DuelState _self;
  final $Res Function(DuelState) _then;

/// Create a copy of DuelState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? champion = null,Object? challenger = null,Object? queue = null,Object? streak = null,Object? winner = freezed,}) {
  return _then(_self.copyWith(
champion: null == champion ? _self.champion : champion // ignore: cast_nullable_to_non_nullable
as FoodCategory,challenger: null == challenger ? _self.challenger : challenger // ignore: cast_nullable_to_non_nullable
as FoodCategory,queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<FoodCategory>,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,winner: freezed == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as FoodCategory?,
  ));
}
/// Create a copy of DuelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get champion {
  
  return $FoodCategoryCopyWith<$Res>(_self.champion, (value) {
    return _then(_self.copyWith(champion: value));
  });
}/// Create a copy of DuelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get challenger {
  
  return $FoodCategoryCopyWith<$Res>(_self.challenger, (value) {
    return _then(_self.copyWith(challenger: value));
  });
}/// Create a copy of DuelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res>? get winner {
    if (_self.winner == null) {
    return null;
  }

  return $FoodCategoryCopyWith<$Res>(_self.winner!, (value) {
    return _then(_self.copyWith(winner: value));
  });
}
}


/// Adds pattern-matching-related methods to [DuelState].
extension DuelStatePatterns on DuelState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DuelState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DuelState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DuelState value)  $default,){
final _that = this;
switch (_that) {
case _DuelState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DuelState value)?  $default,){
final _that = this;
switch (_that) {
case _DuelState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FoodCategory champion,  FoodCategory challenger,  List<FoodCategory> queue,  int streak,  FoodCategory? winner)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DuelState() when $default != null:
return $default(_that.champion,_that.challenger,_that.queue,_that.streak,_that.winner);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FoodCategory champion,  FoodCategory challenger,  List<FoodCategory> queue,  int streak,  FoodCategory? winner)  $default,) {final _that = this;
switch (_that) {
case _DuelState():
return $default(_that.champion,_that.challenger,_that.queue,_that.streak,_that.winner);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FoodCategory champion,  FoodCategory challenger,  List<FoodCategory> queue,  int streak,  FoodCategory? winner)?  $default,) {final _that = this;
switch (_that) {
case _DuelState() when $default != null:
return $default(_that.champion,_that.challenger,_that.queue,_that.streak,_that.winner);case _:
  return null;

}
}

}

/// @nodoc


class _DuelState extends DuelState {
  const _DuelState({required this.champion, required this.challenger, required final  List<FoodCategory> queue, this.streak = 0, this.winner}): _queue = queue,super._();
  

@override final  FoodCategory champion;
@override final  FoodCategory challenger;
 final  List<FoodCategory> _queue;
@override List<FoodCategory> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

@override@JsonKey() final  int streak;
@override final  FoodCategory? winner;

/// Create a copy of DuelState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DuelStateCopyWith<_DuelState> get copyWith => __$DuelStateCopyWithImpl<_DuelState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DuelState&&(identical(other.champion, champion) || other.champion == champion)&&(identical(other.challenger, challenger) || other.challenger == challenger)&&const DeepCollectionEquality().equals(other._queue, _queue)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.winner, winner) || other.winner == winner));
}


@override
int get hashCode => Object.hash(runtimeType,champion,challenger,const DeepCollectionEquality().hash(_queue),streak,winner);

@override
String toString() {
  return 'DuelState(champion: $champion, challenger: $challenger, queue: $queue, streak: $streak, winner: $winner)';
}


}

/// @nodoc
abstract mixin class _$DuelStateCopyWith<$Res> implements $DuelStateCopyWith<$Res> {
  factory _$DuelStateCopyWith(_DuelState value, $Res Function(_DuelState) _then) = __$DuelStateCopyWithImpl;
@override @useResult
$Res call({
 FoodCategory champion, FoodCategory challenger, List<FoodCategory> queue, int streak, FoodCategory? winner
});


@override $FoodCategoryCopyWith<$Res> get champion;@override $FoodCategoryCopyWith<$Res> get challenger;@override $FoodCategoryCopyWith<$Res>? get winner;

}
/// @nodoc
class __$DuelStateCopyWithImpl<$Res>
    implements _$DuelStateCopyWith<$Res> {
  __$DuelStateCopyWithImpl(this._self, this._then);

  final _DuelState _self;
  final $Res Function(_DuelState) _then;

/// Create a copy of DuelState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? champion = null,Object? challenger = null,Object? queue = null,Object? streak = null,Object? winner = freezed,}) {
  return _then(_DuelState(
champion: null == champion ? _self.champion : champion // ignore: cast_nullable_to_non_nullable
as FoodCategory,challenger: null == challenger ? _self.challenger : challenger // ignore: cast_nullable_to_non_nullable
as FoodCategory,queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<FoodCategory>,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,winner: freezed == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as FoodCategory?,
  ));
}

/// Create a copy of DuelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get champion {
  
  return $FoodCategoryCopyWith<$Res>(_self.champion, (value) {
    return _then(_self.copyWith(champion: value));
  });
}/// Create a copy of DuelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get challenger {
  
  return $FoodCategoryCopyWith<$Res>(_self.challenger, (value) {
    return _then(_self.copyWith(challenger: value));
  });
}/// Create a copy of DuelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res>? get winner {
    if (_self.winner == null) {
    return null;
  }

  return $FoodCategoryCopyWith<$Res>(_self.winner!, (value) {
    return _then(_self.copyWith(winner: value));
  });
}
}

// dart format on
