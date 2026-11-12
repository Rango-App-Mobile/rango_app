// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthFormState {

 bool get submitting; bool get done; String? get nameError; String? get emailError; String? get passwordError;/// An error that is not about one field: no network, or unexpected.
 String? get alert;
/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFormStateCopyWith<AuthFormState> get copyWith => _$AuthFormStateCopyWithImpl<AuthFormState>(this as AuthFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFormState&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.done, done) || other.done == done)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.alert, alert) || other.alert == alert));
}


@override
int get hashCode => Object.hash(runtimeType,submitting,done,nameError,emailError,passwordError,alert);

@override
String toString() {
  return 'AuthFormState(submitting: $submitting, done: $done, nameError: $nameError, emailError: $emailError, passwordError: $passwordError, alert: $alert)';
}


}

/// @nodoc
abstract mixin class $AuthFormStateCopyWith<$Res>  {
  factory $AuthFormStateCopyWith(AuthFormState value, $Res Function(AuthFormState) _then) = _$AuthFormStateCopyWithImpl;
@useResult
$Res call({
 bool submitting, bool done, String? nameError, String? emailError, String? passwordError, String? alert
});




}
/// @nodoc
class _$AuthFormStateCopyWithImpl<$Res>
    implements $AuthFormStateCopyWith<$Res> {
  _$AuthFormStateCopyWithImpl(this._self, this._then);

  final AuthFormState _self;
  final $Res Function(AuthFormState) _then;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? submitting = null,Object? done = null,Object? nameError = freezed,Object? emailError = freezed,Object? passwordError = freezed,Object? alert = freezed,}) {
  return _then(_self.copyWith(
submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as String?,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,alert: freezed == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthFormState].
extension AuthFormStatePatterns on AuthFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthFormState value)  $default,){
final _that = this;
switch (_that) {
case _AuthFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthFormState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool submitting,  bool done,  String? nameError,  String? emailError,  String? passwordError,  String? alert)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
return $default(_that.submitting,_that.done,_that.nameError,_that.emailError,_that.passwordError,_that.alert);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool submitting,  bool done,  String? nameError,  String? emailError,  String? passwordError,  String? alert)  $default,) {final _that = this;
switch (_that) {
case _AuthFormState():
return $default(_that.submitting,_that.done,_that.nameError,_that.emailError,_that.passwordError,_that.alert);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool submitting,  bool done,  String? nameError,  String? emailError,  String? passwordError,  String? alert)?  $default,) {final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
return $default(_that.submitting,_that.done,_that.nameError,_that.emailError,_that.passwordError,_that.alert);case _:
  return null;

}
}

}

/// @nodoc


class _AuthFormState implements AuthFormState {
  const _AuthFormState({this.submitting = false, this.done = false, this.nameError, this.emailError, this.passwordError, this.alert});
  

@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool done;
@override final  String? nameError;
@override final  String? emailError;
@override final  String? passwordError;
/// An error that is not about one field: no network, or unexpected.
@override final  String? alert;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthFormStateCopyWith<_AuthFormState> get copyWith => __$AuthFormStateCopyWithImpl<_AuthFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthFormState&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.done, done) || other.done == done)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.alert, alert) || other.alert == alert));
}


@override
int get hashCode => Object.hash(runtimeType,submitting,done,nameError,emailError,passwordError,alert);

@override
String toString() {
  return 'AuthFormState(submitting: $submitting, done: $done, nameError: $nameError, emailError: $emailError, passwordError: $passwordError, alert: $alert)';
}


}

/// @nodoc
abstract mixin class _$AuthFormStateCopyWith<$Res> implements $AuthFormStateCopyWith<$Res> {
  factory _$AuthFormStateCopyWith(_AuthFormState value, $Res Function(_AuthFormState) _then) = __$AuthFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool submitting, bool done, String? nameError, String? emailError, String? passwordError, String? alert
});




}
/// @nodoc
class __$AuthFormStateCopyWithImpl<$Res>
    implements _$AuthFormStateCopyWith<$Res> {
  __$AuthFormStateCopyWithImpl(this._self, this._then);

  final _AuthFormState _self;
  final $Res Function(_AuthFormState) _then;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? submitting = null,Object? done = null,Object? nameError = freezed,Object? emailError = freezed,Object? passwordError = freezed,Object? alert = freezed,}) {
  return _then(_AuthFormState(
submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as String?,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,alert: freezed == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
