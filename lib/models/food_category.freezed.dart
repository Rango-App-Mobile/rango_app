// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoodCategory {

 String get id; String get label; String? get parentId; String? get placesKeyword;/// Line under the title on the card, e.g. "Coxinha, pastel, pizza".
 String? get examples; String? get foodTheme;/// Name of the dish photo bundled in `assets/images/food/` (without the
/// `.jpg`), e.g. "pizza". Null draws the Food Card placeholder. A String
/// for the same reason as [foodTheme]: the View builds the image.
 String? get photo;
/// Create a copy of FoodCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodCategoryCopyWith<FoodCategory> get copyWith => _$FoodCategoryCopyWithImpl<FoodCategory>(this as FoodCategory, _$identity);

  /// Serializes this FoodCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.placesKeyword, placesKeyword) || other.placesKeyword == placesKeyword)&&(identical(other.examples, examples) || other.examples == examples)&&(identical(other.foodTheme, foodTheme) || other.foodTheme == foodTheme)&&(identical(other.photo, photo) || other.photo == photo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,parentId,placesKeyword,examples,foodTheme,photo);

@override
String toString() {
  return 'FoodCategory(id: $id, label: $label, parentId: $parentId, placesKeyword: $placesKeyword, examples: $examples, foodTheme: $foodTheme, photo: $photo)';
}


}

/// @nodoc
abstract mixin class $FoodCategoryCopyWith<$Res>  {
  factory $FoodCategoryCopyWith(FoodCategory value, $Res Function(FoodCategory) _then) = _$FoodCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String label, String? parentId, String? placesKeyword, String? examples, String? foodTheme, String? photo
});




}
/// @nodoc
class _$FoodCategoryCopyWithImpl<$Res>
    implements $FoodCategoryCopyWith<$Res> {
  _$FoodCategoryCopyWithImpl(this._self, this._then);

  final FoodCategory _self;
  final $Res Function(FoodCategory) _then;

/// Create a copy of FoodCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? parentId = freezed,Object? placesKeyword = freezed,Object? examples = freezed,Object? foodTheme = freezed,Object? photo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,placesKeyword: freezed == placesKeyword ? _self.placesKeyword : placesKeyword // ignore: cast_nullable_to_non_nullable
as String?,examples: freezed == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as String?,foodTheme: freezed == foodTheme ? _self.foodTheme : foodTheme // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodCategory].
extension FoodCategoryPatterns on FoodCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodCategory value)  $default,){
final _that = this;
switch (_that) {
case _FoodCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodCategory value)?  $default,){
final _that = this;
switch (_that) {
case _FoodCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String? parentId,  String? placesKeyword,  String? examples,  String? foodTheme,  String? photo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodCategory() when $default != null:
return $default(_that.id,_that.label,_that.parentId,_that.placesKeyword,_that.examples,_that.foodTheme,_that.photo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String? parentId,  String? placesKeyword,  String? examples,  String? foodTheme,  String? photo)  $default,) {final _that = this;
switch (_that) {
case _FoodCategory():
return $default(_that.id,_that.label,_that.parentId,_that.placesKeyword,_that.examples,_that.foodTheme,_that.photo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String? parentId,  String? placesKeyword,  String? examples,  String? foodTheme,  String? photo)?  $default,) {final _that = this;
switch (_that) {
case _FoodCategory() when $default != null:
return $default(_that.id,_that.label,_that.parentId,_that.placesKeyword,_that.examples,_that.foodTheme,_that.photo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodCategory implements FoodCategory {
  const _FoodCategory({required this.id, required this.label, this.parentId, this.placesKeyword, this.examples, this.foodTheme, this.photo});
  factory _FoodCategory.fromJson(Map<String, dynamic> json) => _$FoodCategoryFromJson(json);

@override final  String id;
@override final  String label;
@override final  String? parentId;
@override final  String? placesKeyword;
/// Line under the title on the card, e.g. "Coxinha, pastel, pizza".
@override final  String? examples;
@override final  String? foodTheme;
/// Name of the dish photo bundled in `assets/images/food/` (without the
/// `.jpg`), e.g. "pizza". Null draws the Food Card placeholder. A String
/// for the same reason as [foodTheme]: the View builds the image.
@override final  String? photo;

/// Create a copy of FoodCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodCategoryCopyWith<_FoodCategory> get copyWith => __$FoodCategoryCopyWithImpl<_FoodCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.placesKeyword, placesKeyword) || other.placesKeyword == placesKeyword)&&(identical(other.examples, examples) || other.examples == examples)&&(identical(other.foodTheme, foodTheme) || other.foodTheme == foodTheme)&&(identical(other.photo, photo) || other.photo == photo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,parentId,placesKeyword,examples,foodTheme,photo);

@override
String toString() {
  return 'FoodCategory(id: $id, label: $label, parentId: $parentId, placesKeyword: $placesKeyword, examples: $examples, foodTheme: $foodTheme, photo: $photo)';
}


}

/// @nodoc
abstract mixin class _$FoodCategoryCopyWith<$Res> implements $FoodCategoryCopyWith<$Res> {
  factory _$FoodCategoryCopyWith(_FoodCategory value, $Res Function(_FoodCategory) _then) = __$FoodCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String? parentId, String? placesKeyword, String? examples, String? foodTheme, String? photo
});




}
/// @nodoc
class __$FoodCategoryCopyWithImpl<$Res>
    implements _$FoodCategoryCopyWith<$Res> {
  __$FoodCategoryCopyWithImpl(this._self, this._then);

  final _FoodCategory _self;
  final $Res Function(_FoodCategory) _then;

/// Create a copy of FoodCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? parentId = freezed,Object? placesKeyword = freezed,Object? examples = freezed,Object? foodTheme = freezed,Object? photo = freezed,}) {
  return _then(_FoodCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,placesKeyword: freezed == placesKeyword ? _self.placesKeyword : placesKeyword // ignore: cast_nullable_to_non_nullable
as String?,examples: freezed == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as String?,foodTheme: freezed == foodTheme ? _self.foodTheme : foodTheme // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
