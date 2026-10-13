import 'package:flix_tap/domain/entities/category.dart';
import 'package:flix_tap/infrastructure/datasources/category_datasource_impl.dart';
import 'package:flix_tap/infrastructure/repositories/category_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesRepositoryProvider = Provider((ref) {
  return CategoryRepositoryImpl(CategoryDatasourceImpl());
});

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoriesRepositoryProvider).getCategories();
});
