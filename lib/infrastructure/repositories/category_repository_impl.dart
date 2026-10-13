import 'package:flix_tap/domain/datasources/categories_datasource.dart';
import 'package:flix_tap/domain/entities/category.dart';
import 'package:flix_tap/domain/repositories/categories_repository.dart';

class CategoryRepositoryImpl extends CategoriesRepository {
  final CategoriesDatasource datasource;

  CategoryRepositoryImpl(this.datasource);

  @override
  Future<List<Category>> getCategories() {
    return datasource.getCategories();
  }
}
