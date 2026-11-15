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

 bool get submitting; bool get done;/// Signed in, but the terms were not accepted yet: the View goes to the
/// acceptance screen instead of closing.
 bool get needsTerms; String? get nameError; String? get emailError; String? get passwordError; String? get confirmEmailError; String? get confirmPasswordError; String? get termsError;/// The terms switch of the sign-up form.
 bool get termsAccepted;/// An error that is not about one field: no network, or unexpected.
 String? get alert;
/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFormStateCopyWith<AuthFormState> get copyWith => _$AuthFormStateCopyWithImpl<AuthFormState>(this as AuthFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFormState&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.done, done) || other.done == done)&&(identical(other.needsTerms, needsTerms) || other.needsTerms == needsTerms)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.confirmEmailError, confirmEmailError) || other.confirmEmailError == confirmEmailError)&&(identical(other.confirmPasswordError, confirmPasswordError) || other.confirmPasswordError == confirmPasswordError)&&(identical(other.termsError, termsError) || other.termsError == termsError)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.alert, alert) || other.alert == alert));
}


@override
int get hashCode => Object.hash(runtimeType,submitting,done,needsTerms,nameError,emailError,passwordError,confirmEmailError,confirmPasswordError,termsError,termsAccepted,alert);

@override
String toString() {
  return 'AuthFormState(submitting: $submitting, done: $done, needsTerms: $needsTerms, nameError: $nameError, emailError: $emailError, passwordError: $passwordError, confirmEmailError: $confirmEmailError, confirmPasswordError: $confirmPasswordError, termsError: $termsError, termsAccepted: $termsAccepted, alert: $alert)';
}


}

/// @nodoc
abstract mixin class $AuthFormStateCopyWith<$Res>  {
  factory $AuthFormStateCopyWith(AuthFormState value, $Res Function(AuthFormState) _then) = _$AuthFormStateCopyWithImpl;
@useResult
$Res call({
 bool submitting, bool done, bool needsTerms, String? nameError, String? emailError, String? passwordError, String? confirmEmailError, String? confirmPasswordError, String? termsError, bool termsAccepted, String? alert
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
@pragma('vm:prefer-inline') @override $Res call({Object? submitting = null,Object? done = null,Object? needsTerms = null,Object? nameError = freezed,Object? emailError = freezed,Object? passwordError = freezed,Object? confirmEmailError = freezed,Object? confirmPasswordError = freezed,Object? termsError = freezed,Object? termsAccepted = null,Object? alert = freezed,}) {
  return _then(_self.copyWith(
submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,needsTerms: null == needsTerms ? _self.needsTerms : needsTerms // ignore: cast_nullable_to_non_nullable
as bool,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as String?,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,confirmEmailError: freezed == confirmEmailError ? _self.confirmEmailError : confirmEmailError // ignore: cast_nullable_to_non_nullable
as String?,confirmPasswordError: freezed == confirmPasswordError ? _self.confirmPasswordError : confirmPasswordError // ignore: cast_nullable_to_non_nullable
as String?,termsError: freezed == termsError ? _self.termsError : termsError // ignore: cast_nullable_to_non_nullable
as String?,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,alert: freezed == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool submitting,  bool done,  bool needsTerms,  String? nameError,  String? emailError,  String? passwordError,  String? confirmEmailError,  String? confirmPasswordError,  String? termsError,  bool termsAccepted,  String? alert)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
return $default(_that.submitting,_that.done,_that.needsTerms,_that.nameError,_that.emailError,_that.passwordError,_that.confirmEmailError,_that.confirmPasswordError,_that.termsError,_that.termsAccepted,_that.alert);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool submitting,  bool done,  bool needsTerms,  String? nameError,  String? emailError,  String? passwordError,  String? confirmEmailError,  String? confirmPasswordError,  String? termsError,  bool termsAccepted,  String? alert)  $default,) {final _that = this;
switch (_that) {
case _AuthFormState():
return $default(_that.submitting,_that.done,_that.needsTerms,_that.nameError,_that.emailError,_that.passwordError,_that.confirmEmailError,_that.confirmPasswordError,_that.termsError,_that.termsAccepted,_that.alert);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool submitting,  bool done,  bool needsTerms,  String? nameError,  String? emailError,  String? passwordError,  String? confirmEmailError,  String? confirmPasswordError,  String? termsError,  bool termsAccepted,  String? alert)?  $default,) {final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
return $default(_that.submitting,_that.done,_that.needsTerms,_that.nameError,_that.emailError,_that.passwordError,_that.confirmEmailError,_that.confirmPasswordError,_that.termsError,_that.termsAccepted,_that.alert);case _:
  return null;

}
}

}

/// @nodoc


class _AuthFormState implements AuthFormState {
  const _AuthFormState({this.submitting = false, this.done = false, this.needsTerms = false, this.nameError, this.emailError, this.passwordError, this.confirmEmailError, this.confirmPasswordError, this.termsError, this.termsAccepted = false, this.alert});
  

@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool done;
/// Signed in, but the terms were not accepted yet: the View goes to the
/// acceptance screen instead of closing.
@override@JsonKey() final  bool needsTerms;
@override final  String? nameError;
@override final  String? emailError;
@override final  String? passwordError;
@override final  String? confirmEmailError;
@override final  String? confirmPasswordError;
@override final  String? termsError;
/// The terms switch of the sign-up form.
@override@JsonKey() final  bool termsAccepted;
/// An error that is not about one field: no network, or unexpected.
@override final  String? alert;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthFormStateCopyWith<_AuthFormState> get copyWith => __$AuthFormStateCopyWithImpl<_AuthFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthFormState&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.done, done) || other.done == done)&&(identical(other.needsTerms, needsTerms) || other.needsTerms == needsTerms)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.confirmEmailError, confirmEmailError) || other.confirmEmailError == confirmEmailError)&&(identical(other.confirmPasswordError, confirmPasswordError) || other.confirmPasswordError == confirmPasswordError)&&(identical(other.termsError, termsError) || other.termsError == termsError)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.alert, alert) || other.alert == alert));
}


@override
int get hashCode => Object.hash(runtimeType,submitting,done,needsTerms,nameError,emailError,passwordError,confirmEmailError,confirmPasswordError,termsError,termsAccepted,alert);

@override
String toString() {
  return 'AuthFormState(submitting: $submitting, done: $done, needsTerms: $needsTerms, nameError: $nameError, emailError: $emailError, passwordError: $passwordError, confirmEmailError: $confirmEmailError, confirmPasswordError: $confirmPasswordError, termsError: $termsError, termsAccepted: $termsAccepted, alert: $alert)';
}


}

/// @nodoc
abstract mixin class _$AuthFormStateCopyWith<$Res> implements $AuthFormStateCopyWith<$Res> {
  factory _$AuthFormStateCopyWith(_AuthFormState value, $Res Function(_AuthFormState) _then) = __$AuthFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool submitting, bool done, bool needsTerms, String? nameError, String? emailError, String? passwordError, String? confirmEmailError, String? confirmPasswordError, String? termsError, bool termsAccepted, String? alert
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
@override @pragma('vm:prefer-inline') $Res call({Object? submitting = null,Object? done = null,Object? needsTerms = null,Object? nameError = freezed,Object? emailError = freezed,Object? passwordError = freezed,Object? confirmEmailError = freezed,Object? confirmPasswordError = freezed,Object? termsError = freezed,Object? termsAccepted = null,Object? alert = freezed,}) {
  return _then(_AuthFormState(
submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,needsTerms: null == needsTerms ? _self.needsTerms : needsTerms // ignore: cast_nullable_to_non_nullable
as bool,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as String?,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,confirmEmailError: freezed == confirmEmailError ? _self.confirmEmailError : confirmEmailError // ignore: cast_nullable_to_non_nullable
as String?,confirmPasswordError: freezed == confirmPasswordError ? _self.confirmPasswordError : confirmPasswordError // ignore: cast_nullable_to_non_nullable
as String?,termsError: freezed == termsError ? _self.termsError : termsError // ignore: cast_nullable_to_non_nullable
as String?,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,alert: freezed == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
