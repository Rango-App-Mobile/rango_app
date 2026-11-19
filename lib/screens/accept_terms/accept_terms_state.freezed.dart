// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accept_terms_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AcceptTermsState {

/// The name the account already has, to prefill the field.
 String? get initialName; bool get termsAccepted; bool get submitting;/// Accepted or declined: the View closes the screen.
 bool get done; String? get nameError; String? get termsError; String? get alert;
/// Create a copy of AcceptTermsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcceptTermsStateCopyWith<AcceptTermsState> get copyWith => _$AcceptTermsStateCopyWithImpl<AcceptTermsState>(this as AcceptTermsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptTermsState&&(identical(other.initialName, initialName) || other.initialName == initialName)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.done, done) || other.done == done)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.termsError, termsError) || other.termsError == termsError)&&(identical(other.alert, alert) || other.alert == alert));
}


@override
int get hashCode => Object.hash(runtimeType,initialName,termsAccepted,submitting,done,nameError,termsError,alert);

@override
String toString() {
  return 'AcceptTermsState(initialName: $initialName, termsAccepted: $termsAccepted, submitting: $submitting, done: $done, nameError: $nameError, termsError: $termsError, alert: $alert)';
}


}

/// @nodoc
abstract mixin class $AcceptTermsStateCopyWith<$Res>  {
  factory $AcceptTermsStateCopyWith(AcceptTermsState value, $Res Function(AcceptTermsState) _then) = _$AcceptTermsStateCopyWithImpl;
@useResult
$Res call({
 String? initialName, bool termsAccepted, bool submitting, bool done, String? nameError, String? termsError, String? alert
});




}
/// @nodoc
class _$AcceptTermsStateCopyWithImpl<$Res>
    implements $AcceptTermsStateCopyWith<$Res> {
  _$AcceptTermsStateCopyWithImpl(this._self, this._then);

  final AcceptTermsState _self;
  final $Res Function(AcceptTermsState) _then;

/// Create a copy of AcceptTermsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? initialName = freezed,Object? termsAccepted = null,Object? submitting = null,Object? done = null,Object? nameError = freezed,Object? termsError = freezed,Object? alert = freezed,}) {
  return _then(_self.copyWith(
initialName: freezed == initialName ? _self.initialName : initialName // ignore: cast_nullable_to_non_nullable
as String?,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as String?,termsError: freezed == termsError ? _self.termsError : termsError // ignore: cast_nullable_to_non_nullable
as String?,alert: freezed == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AcceptTermsState].
extension AcceptTermsStatePatterns on AcceptTermsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcceptTermsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcceptTermsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcceptTermsState value)  $default,){
final _that = this;
switch (_that) {
case _AcceptTermsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcceptTermsState value)?  $default,){
final _that = this;
switch (_that) {
case _AcceptTermsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? initialName,  bool termsAccepted,  bool submitting,  bool done,  String? nameError,  String? termsError,  String? alert)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcceptTermsState() when $default != null:
return $default(_that.initialName,_that.termsAccepted,_that.submitting,_that.done,_that.nameError,_that.termsError,_that.alert);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? initialName,  bool termsAccepted,  bool submitting,  bool done,  String? nameError,  String? termsError,  String? alert)  $default,) {final _that = this;
switch (_that) {
case _AcceptTermsState():
return $default(_that.initialName,_that.termsAccepted,_that.submitting,_that.done,_that.nameError,_that.termsError,_that.alert);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? initialName,  bool termsAccepted,  bool submitting,  bool done,  String? nameError,  String? termsError,  String? alert)?  $default,) {final _that = this;
switch (_that) {
case _AcceptTermsState() when $default != null:
return $default(_that.initialName,_that.termsAccepted,_that.submitting,_that.done,_that.nameError,_that.termsError,_that.alert);case _:
  return null;

}
}

}

/// @nodoc


class _AcceptTermsState implements AcceptTermsState {
  const _AcceptTermsState({this.initialName, this.termsAccepted = false, this.submitting = false, this.done = false, this.nameError, this.termsError, this.alert});
  

/// The name the account already has, to prefill the field.
@override final  String? initialName;
@override@JsonKey() final  bool termsAccepted;
@override@JsonKey() final  bool submitting;
/// Accepted or declined: the View closes the screen.
@override@JsonKey() final  bool done;
@override final  String? nameError;
@override final  String? termsError;
@override final  String? alert;

/// Create a copy of AcceptTermsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptTermsStateCopyWith<_AcceptTermsState> get copyWith => __$AcceptTermsStateCopyWithImpl<_AcceptTermsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcceptTermsState&&(identical(other.initialName, initialName) || other.initialName == initialName)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.done, done) || other.done == done)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.termsError, termsError) || other.termsError == termsError)&&(identical(other.alert, alert) || other.alert == alert));
}


@override
int get hashCode => Object.hash(runtimeType,initialName,termsAccepted,submitting,done,nameError,termsError,alert);

@override
String toString() {
  return 'AcceptTermsState(initialName: $initialName, termsAccepted: $termsAccepted, submitting: $submitting, done: $done, nameError: $nameError, termsError: $termsError, alert: $alert)';
}


}

/// @nodoc
abstract mixin class _$AcceptTermsStateCopyWith<$Res> implements $AcceptTermsStateCopyWith<$Res> {
  factory _$AcceptTermsStateCopyWith(_AcceptTermsState value, $Res Function(_AcceptTermsState) _then) = __$AcceptTermsStateCopyWithImpl;
@override @useResult
$Res call({
 String? initialName, bool termsAccepted, bool submitting, bool done, String? nameError, String? termsError, String? alert
});




}
/// @nodoc
class __$AcceptTermsStateCopyWithImpl<$Res>
    implements _$AcceptTermsStateCopyWith<$Res> {
  __$AcceptTermsStateCopyWithImpl(this._self, this._then);

  final _AcceptTermsState _self;
  final $Res Function(_AcceptTermsState) _then;

/// Create a copy of AcceptTermsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? initialName = freezed,Object? termsAccepted = null,Object? submitting = null,Object? done = null,Object? nameError = freezed,Object? termsError = freezed,Object? alert = freezed,}) {
  return _then(_AcceptTermsState(
initialName: freezed == initialName ? _self.initialName : initialName // ignore: cast_nullable_to_non_nullable
as String?,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as String?,termsError: freezed == termsError ? _self.termsError : termsError // ignore: cast_nullable_to_non_nullable
as String?,alert: freezed == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
