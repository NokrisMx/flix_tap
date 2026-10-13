import 'package:flix_tap/domain/entities/category.dart';

abstract class CategoriesDatasource {
  Future<List<Category>> getCategories();
}
