import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/models/food_category.dart';

class FakeCategoryRepository implements CategoryRepository {
  static const seed = [
    FoodCategory(id: 'root', label: 'O que bate hoje?'),
    FoodCategory(
      id: 'savory',
      label: 'Salgado',
      parentId: 'root',
      examples: 'Coxinha, pastel, pizza',
      foodTheme: 'tomato',
    ),
    FoodCategory(
      id: 'sweet',
      label: 'Doce',
      parentId: 'root',
      examples: 'Brigadeiro, açaí, bolo',
      foodTheme: 'bubblegum',
    ),
    FoodCategory(
      id: 'pasta',
      label: 'Massa',
      parentId: 'savory',
      examples: 'Macarrão, lasanha, nhoque',
      foodTheme: 'mustard',
    ),
    FoodCategory(
      id: 'snack',
      label: 'Lanche',
      parentId: 'savory',
      examples: 'Xis, hot dog, burger',
      foodTheme: 'copper',
    ),
    FoodCategory(
      id: 'spaghetti',
      label: 'Macarrão',
      parentId: 'pasta',
      placesKeyword: 'restaurante italiano',
      examples: 'Espaguete, penne, fettuccine',
      foodTheme: 'lime',
    ),
    FoodCategory(
      id: 'pizza',
      label: 'Pizza',
      parentId: 'pasta',
      placesKeyword: 'pizzaria',
      examples: 'Calabresa, marguerita, portuguesa',
      foodTheme: 'plum',
    ),
    FoodCategory(
      id: 'burger',
      label: 'Hambúrguer',
      parentId: 'snack',
      placesKeyword: 'hamburgueria',
      examples: 'Artesanal, smash, cheeseburger',
      foodTheme: 'cocoa',
    ),
    FoodCategory(
      id: 'xis',
      label: 'Xis',
      parentId: 'snack',
      placesKeyword: 'lanchonete xis',
      examples: 'Xis salada, xis coração, xis bacon',
      foodTheme: 'pistachio',
    ),
    FoodCategory(
      id: 'ice_cream',
      label: 'Sorvete',
      parentId: 'sweet',
      placesKeyword: 'sorveteria',
      examples: 'Casquinha, sundae, picolé',
      foodTheme: 'sky',
    ),
    FoodCategory(
      id: 'cake',
      label: 'Bolo',
      parentId: 'sweet',
      placesKeyword: 'confeitaria',
      examples: 'Chocolate, cenoura, torta',
      foodTheme: 'lilac',
    ),
  ];

  @override
  Future<List<FoodCategory>> fetchAll() async => seed;
}
