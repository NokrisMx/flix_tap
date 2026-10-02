import 'package:flix_tap/domain/entities/movie.dart';
import 'package:flix_tap/infrastructure/models/moviedb/moviedb_moviedb.dart';

class MovieMapper {
  static Movie movieDBToEntity(MovieMovieDb moviedb) => Movie(
    adult: moviedb.adult,
    backdropPath: (moviedb.backdropPath).isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${moviedb.backdropPath}'
        : 'https://ih1.redbubble.net/image.4905811447.8675/flat,750x,075,f-pad,750x1000,f8f8f8.jpg',
    genreIds: moviedb.genreIds.map((e) => e.toString()).toList(),
    id: moviedb.id,
    originalLanguage: moviedb.originalLanguage,
    originalTitle: moviedb.originalTitle,
    overview: moviedb.overview,
    popularity: moviedb.popularity,
    posterPath: (moviedb.posterPath).isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${moviedb.posterPath}'
        : 'https://ih1.redbubble.net/image.4905811447.8675/flat,750x,075,f-pad,750x1000,f8f8f8.jpg',
    releaseDate: moviedb.releaseDate,
    title: moviedb.title,
    video: moviedb.video,
    voteAverage: moviedb.voteAverage,
    voteCount: moviedb.voteCount,
  );
}
