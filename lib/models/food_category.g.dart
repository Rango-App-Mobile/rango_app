// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodCategory _$FoodCategoryFromJson(Map<String, dynamic> json) =>
    _FoodCategory(
      id: json['id'] as String,
      label: json['label'] as String,
      parentId: json['parentId'] as String?,
      placesKeyword: json['placesKeyword'] as String?,
      examples: json['examples'] as String?,
      foodTheme: json['foodTheme'] as String?,
    );

Map<String, dynamic> _$FoodCategoryToJson(_FoodCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'parentId': instance.parentId,
      'placesKeyword': instance.placesKeyword,
      'examples': instance.examples,
      'foodTheme': instance.foodTheme,
    };
