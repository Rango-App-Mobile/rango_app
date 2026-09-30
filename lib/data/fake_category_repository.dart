import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/models/food_category.dart';

class FakeCategoryRepository implements CategoryRepository {
  static const seed = [
    FoodCategory(id: 'root', label: 'O que bate hoje?'),
    FoodCategory(id: 'savory', label: 'Salgado', parentId: 'root'),
    FoodCategory(id: 'sweet', label: 'Doce', parentId: 'root'),
    FoodCategory(id: 'pasta', label: 'Massa', parentId: 'savory'),
    FoodCategory(
      id: 'burger',
      label: 'Hambúrguer',
      parentId: 'savory',
      placesKeyword: 'hamburgueria',
    ),
    FoodCategory(
      id: 'spaghetti',
      label: 'Macarrão',
      parentId: 'pasta',
      placesKeyword: 'restaurante italiano',
    ),
    FoodCategory(
      id: 'pizza',
      label: 'Pizza',
      parentId: 'pasta',
      placesKeyword: 'pizzaria',
    ),
    FoodCategory(
      id: 'ice_cream',
      label: 'Sorvete',
      parentId: 'sweet',
      placesKeyword: 'sorveteria',
    ),
    FoodCategory(
      id: 'cake',
      label: 'Bolo',
      parentId: 'sweet',
      placesKeyword: 'confeitaria',
    ),
  ];

  @override
  Future<List<FoodCategory>> fetchAll() async => seed;
}
