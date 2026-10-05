import 'package:flix_tap/domain/entities/movie.dart';
import 'package:flix_tap/infrastructure/models/moviedb/movie_details.dart';
import 'package:flix_tap/infrastructure/models/moviedb/moviedb_moviedb.dart';

class MovieMapper {
  static Movie movieDBToEntity(MovieMovieDb moviedb) => Movie(
    adult: moviedb.adult,
    backdropPath: (moviedb.backdropPath).isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${moviedb.backdropPath}'
        : 'no-backdrop',
    genreIds: moviedb.genreIds.map((e) => e.toString()).toList(),
    id: moviedb.id,
    originalLanguage: moviedb.originalLanguage,
    originalTitle: moviedb.originalTitle,
    overview: (moviedb.overview).isNotEmpty ? moviedb.overview : 'no-overview',
    popularity: moviedb.popularity,
    posterPath: (moviedb.posterPath).isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${moviedb.posterPath}'
        : 'no-poster',
    releaseDate: moviedb.releaseDate,
    title: moviedb.title,
    video: moviedb.video,
    voteAverage: moviedb.voteAverage,
    voteCount: moviedb.voteCount,
  );

  static Movie movieDetailsToEntity(MovieDetails moviedb) => Movie(
    adult: moviedb.adult,
    backdropPath: (moviedb.backdropPath).isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${moviedb.backdropPath}'
        : 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
    genreIds: moviedb.genres.map((e) => e.name).toList(),
    id: moviedb.id,
    originalLanguage: moviedb.originalLanguage,
    originalTitle: moviedb.originalTitle,
    overview: (moviedb.overview).isNotEmpty ? moviedb.overview : 'no-overwiew',
    popularity: moviedb.popularity,
    posterPath: (moviedb.posterPath).isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${moviedb.posterPath}'
        : 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
    releaseDate: moviedb.releaseDate,
    title: moviedb.title,
    video: moviedb.video,
    voteAverage: moviedb.voteAverage,
    voteCount: moviedb.voteCount,
  );
}
