import 'package:flix_tap/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flix_tap/domain/entities/movie.dart';

final nowPlayingMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final fetchMoreMovies = ref.watch(movieRepositoryProvider).getNowPlaying;
      return MoviesNotifier(fetchMoreMovies: fetchMoreMovies);
    });

final popularMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final fetchMoreMovies = ref.watch(movieRepositoryProvider).getPopular;
      return MoviesNotifier(fetchMoreMovies: fetchMoreMovies);
    });

final topRatedMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final fetchMoreMovies = ref.watch(movieRepositoryProvider).getTopRated;
      return MoviesNotifier(fetchMoreMovies: fetchMoreMovies);
    });

final upcomingMoviesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
      final fetchMoreMovies = ref.watch(movieRepositoryProvider).getUpcoming;
      return MoviesNotifier(fetchMoreMovies: fetchMoreMovies);
    });

final similarMoviesProvider =
    StateNotifierProvider.family<SimilarMoviesNotifier, List<Movie>, String>((
      ref,
      movieId,
    ) {
      final fetchSimilarMovies = ref
          .watch(movieRepositoryProvider)
          .getSimilarMovieById;

      return SimilarMoviesNotifier(
        movieId: movieId,
        fetchMoreMovies: fetchSimilarMovies,
      );
    });

final moviesByCategoryProvider =
    StateNotifierProvider.family<SimilarMoviesNotifier, List<Movie>, String>((
      ref,
      categoryId,
    ) {
      final fetchMoviesByCategory = ref
          .watch(movieRepositoryProvider)
          .getMovieByCategory;

      return SimilarMoviesNotifier(
        movieId: categoryId,
        fetchMoreMovies: ({required String id, int page = 1}) =>
            fetchMoviesByCategory(categoryId: id, page: page),
      );
    });

typedef MovieCallback = Future<List<Movie>> Function({int page});

class MoviesNotifier extends StateNotifier<List<Movie>> {
  int currentPage = 0;
  bool isLoading = false;
  MovieCallback fetchMoreMovies;

  MoviesNotifier({required this.fetchMoreMovies}) : super([]);

  Future<void> loadNextPage() async {
    if (isLoading) return;
    isLoading = true;

    final nextPage = currentPage + 1;
    try {
      final newMovies = await fetchMoreMovies(page: nextPage);
      currentPage = nextPage;
      state = [...state, ...newMovies];
    } finally {
      isLoading = false;
    }
  }
}

typedef SimilarMoviesCallback = Future<List<Movie>> Function({
  required String id,
  int page,
});

class SimilarMoviesNotifier extends StateNotifier<List<Movie>> {
  int currentPage = 0;
  bool isLoading = false;

  final String movieId;
  final SimilarMoviesCallback fetchMoreMovies;

  SimilarMoviesNotifier({required this.movieId, required this.fetchMoreMovies})
    : super([]);

  Future<void> loadNextPage() async {
    if (isLoading) return;

    isLoading = true;
    final nextPage = currentPage + 1;
    try {
      final newMovies = await fetchMoreMovies(id: movieId, page: nextPage);
      currentPage = nextPage;
      state = [...state, ...newMovies];
    } finally {
      isLoading = false;
    }
  }
}
