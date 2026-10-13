import 'package:flix_tap/domain/entities/category.dart';

abstract class CategoriesRepository {
  Future<List<Category>> getCategories();
}
