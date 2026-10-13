import 'package:flix_tap/domain/entities/category.dart';
import 'package:flix_tap/infrastructure/models/moviedb/movie_genres_response.dart';

class CategoryMapper {
  static Category genreToEntity(Genre genre) =>
      Category(id: genre.id, name: genre.name);
}
