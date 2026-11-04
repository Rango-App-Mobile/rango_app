// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'like_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LikeState {

 FoodCategory get current;/// Cards after [current]. Never empty while the game is on: the game
/// deals the next round as soon as the last card of a round is on top.
 List<FoodCategory> get queue;/// Likes one food needs to win the game.
 int get likesToMatch;/// Likes per food id. They add up across rounds and never reset.
 Map<String, int> get likes;/// Ids of the foods passed in this session; they are out of the deck.
 Set<String> get passedIds; FoodCategory? get winner;
/// Create a copy of LikeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LikeStateCopyWith<LikeState> get copyWith => _$LikeStateCopyWithImpl<LikeState>(this as LikeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LikeState&&(identical(other.current, current) || other.current == current)&&const DeepCollectionEquality().equals(other.queue, queue)&&(identical(other.likesToMatch, likesToMatch) || other.likesToMatch == likesToMatch)&&const DeepCollectionEquality().equals(other.likes, likes)&&const DeepCollectionEquality().equals(other.passedIds, passedIds)&&(identical(other.winner, winner) || other.winner == winner));
}


@override
int get hashCode => Object.hash(runtimeType,current,const DeepCollectionEquality().hash(queue),likesToMatch,const DeepCollectionEquality().hash(likes),const DeepCollectionEquality().hash(passedIds),winner);

@override
String toString() {
  return 'LikeState(current: $current, queue: $queue, likesToMatch: $likesToMatch, likes: $likes, passedIds: $passedIds, winner: $winner)';
}


}

/// @nodoc
abstract mixin class $LikeStateCopyWith<$Res>  {
  factory $LikeStateCopyWith(LikeState value, $Res Function(LikeState) _then) = _$LikeStateCopyWithImpl;
@useResult
$Res call({
 FoodCategory current, List<FoodCategory> queue, int likesToMatch, Map<String, int> likes, Set<String> passedIds, FoodCategory? winner
});


$FoodCategoryCopyWith<$Res> get current;$FoodCategoryCopyWith<$Res>? get winner;

}
/// @nodoc
class _$LikeStateCopyWithImpl<$Res>
    implements $LikeStateCopyWith<$Res> {
  _$LikeStateCopyWithImpl(this._self, this._then);

  final LikeState _self;
  final $Res Function(LikeState) _then;

/// Create a copy of LikeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? queue = null,Object? likesToMatch = null,Object? likes = null,Object? passedIds = null,Object? winner = freezed,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as FoodCategory,queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<FoodCategory>,likesToMatch: null == likesToMatch ? _self.likesToMatch : likesToMatch // ignore: cast_nullable_to_non_nullable
as int,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as Map<String, int>,passedIds: null == passedIds ? _self.passedIds : passedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,winner: freezed == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as FoodCategory?,
  ));
}
/// Create a copy of LikeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get current {
  
  return $FoodCategoryCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of LikeState
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


/// Adds pattern-matching-related methods to [LikeState].
extension LikeStatePatterns on LikeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LikeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LikeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LikeState value)  $default,){
final _that = this;
switch (_that) {
case _LikeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LikeState value)?  $default,){
final _that = this;
switch (_that) {
case _LikeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FoodCategory current,  List<FoodCategory> queue,  int likesToMatch,  Map<String, int> likes,  Set<String> passedIds,  FoodCategory? winner)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LikeState() when $default != null:
return $default(_that.current,_that.queue,_that.likesToMatch,_that.likes,_that.passedIds,_that.winner);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FoodCategory current,  List<FoodCategory> queue,  int likesToMatch,  Map<String, int> likes,  Set<String> passedIds,  FoodCategory? winner)  $default,) {final _that = this;
switch (_that) {
case _LikeState():
return $default(_that.current,_that.queue,_that.likesToMatch,_that.likes,_that.passedIds,_that.winner);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FoodCategory current,  List<FoodCategory> queue,  int likesToMatch,  Map<String, int> likes,  Set<String> passedIds,  FoodCategory? winner)?  $default,) {final _that = this;
switch (_that) {
case _LikeState() when $default != null:
return $default(_that.current,_that.queue,_that.likesToMatch,_that.likes,_that.passedIds,_that.winner);case _:
  return null;

}
}

}

/// @nodoc


class _LikeState extends LikeState {
  const _LikeState({required this.current, required final  List<FoodCategory> queue, required this.likesToMatch, final  Map<String, int> likes = const <String, int>{}, final  Set<String> passedIds = const <String>{}, this.winner}): _queue = queue,_likes = likes,_passedIds = passedIds,super._();
  

@override final  FoodCategory current;
/// Cards after [current]. Never empty while the game is on: the game
/// deals the next round as soon as the last card of a round is on top.
 final  List<FoodCategory> _queue;
/// Cards after [current]. Never empty while the game is on: the game
/// deals the next round as soon as the last card of a round is on top.
@override List<FoodCategory> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

/// Likes one food needs to win the game.
@override final  int likesToMatch;
/// Likes per food id. They add up across rounds and never reset.
 final  Map<String, int> _likes;
/// Likes per food id. They add up across rounds and never reset.
@override@JsonKey() Map<String, int> get likes {
  if (_likes is EqualUnmodifiableMapView) return _likes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_likes);
}

/// Ids of the foods passed in this session; they are out of the deck.
 final  Set<String> _passedIds;
/// Ids of the foods passed in this session; they are out of the deck.
@override@JsonKey() Set<String> get passedIds {
  if (_passedIds is EqualUnmodifiableSetView) return _passedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_passedIds);
}

@override final  FoodCategory? winner;

/// Create a copy of LikeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LikeStateCopyWith<_LikeState> get copyWith => __$LikeStateCopyWithImpl<_LikeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LikeState&&(identical(other.current, current) || other.current == current)&&const DeepCollectionEquality().equals(other._queue, _queue)&&(identical(other.likesToMatch, likesToMatch) || other.likesToMatch == likesToMatch)&&const DeepCollectionEquality().equals(other._likes, _likes)&&const DeepCollectionEquality().equals(other._passedIds, _passedIds)&&(identical(other.winner, winner) || other.winner == winner));
}


@override
int get hashCode => Object.hash(runtimeType,current,const DeepCollectionEquality().hash(_queue),likesToMatch,const DeepCollectionEquality().hash(_likes),const DeepCollectionEquality().hash(_passedIds),winner);

@override
String toString() {
  return 'LikeState(current: $current, queue: $queue, likesToMatch: $likesToMatch, likes: $likes, passedIds: $passedIds, winner: $winner)';
}


}

/// @nodoc
abstract mixin class _$LikeStateCopyWith<$Res> implements $LikeStateCopyWith<$Res> {
  factory _$LikeStateCopyWith(_LikeState value, $Res Function(_LikeState) _then) = __$LikeStateCopyWithImpl;
@override @useResult
$Res call({
 FoodCategory current, List<FoodCategory> queue, int likesToMatch, Map<String, int> likes, Set<String> passedIds, FoodCategory? winner
});


@override $FoodCategoryCopyWith<$Res> get current;@override $FoodCategoryCopyWith<$Res>? get winner;

}
/// @nodoc
class __$LikeStateCopyWithImpl<$Res>
    implements _$LikeStateCopyWith<$Res> {
  __$LikeStateCopyWithImpl(this._self, this._then);

  final _LikeState _self;
  final $Res Function(_LikeState) _then;

/// Create a copy of LikeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? queue = null,Object? likesToMatch = null,Object? likes = null,Object? passedIds = null,Object? winner = freezed,}) {
  return _then(_LikeState(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as FoodCategory,queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<FoodCategory>,likesToMatch: null == likesToMatch ? _self.likesToMatch : likesToMatch // ignore: cast_nullable_to_non_nullable
as int,likes: null == likes ? _self._likes : likes // ignore: cast_nullable_to_non_nullable
as Map<String, int>,passedIds: null == passedIds ? _self._passedIds : passedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,winner: freezed == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as FoodCategory?,
  ));
}

/// Create a copy of LikeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<$Res> get current {
  
  return $FoodCategoryCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of LikeState
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
