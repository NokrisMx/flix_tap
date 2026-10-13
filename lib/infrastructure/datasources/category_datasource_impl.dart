import 'package:dio/dio.dart';
import 'package:flix_tap/config/constants/environment.dart';
import 'package:flix_tap/domain/datasources/categories_datasource.dart';
import 'package:flix_tap/domain/entities/category.dart';
import 'package:flix_tap/infrastructure/mappers/category_mapper.dart';
import 'package:flix_tap/infrastructure/models/moviedb/movie_genres_response.dart';

class CategoryDatasourceImpl extends CategoriesDatasource {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {'api_key': Environment.movieDbKey, 'language': 'es-MX'},
    ),
  );

  @override
  Future<List<Category>> getCategories() async {
    final response = await dio.get('/genre/movie/list');

    final genreResponse = Genres.fromJson(response.data);

    List<Category> categories = genreResponse.genres
        .map((genre) => CategoryMapper.genreToEntity(genre))
        .toList();

    return categories;
  }
}
