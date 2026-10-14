import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flix_tap/domain/entities/movie.dart';
import 'package:flix_tap/domain/repositories/local_storage_repository.dart';
import 'package:flix_tap/presentation/providers/storage/local_storage_provider.dart';

final favoriteMoviesProvider =
    StateNotifierProvider<StorageMoviesNotifier, Map<int, Movie>>((ref) {
      final localStorageRepository = ref.watch(localStorageRepositoryProvider);

      return StorageMoviesNotifier(
        localStorageRepository: localStorageRepository,
      );
    });

class StorageMoviesNotifier extends StateNotifier<Map<int, Movie>> {
  int page = 0;
  bool isLoading = false;
  final LocalStorageRepository localStorageRepository;

  StorageMoviesNotifier({required this.localStorageRepository}) : super({});

  Future<List<Movie>> loadNextPage() async {
    if (isLoading) return [];
    isLoading = true;

    try {
      final movies = await localStorageRepository.loadFavoriteMovies(
        limit: 10,
        offset: page * 10,
      );

      page++;
      state = {
        ...state,
        for (final movie in movies) movie.id: movie,
      };

      return movies;
    } finally {
      isLoading = false;
    }
  }

  Future<void> toggleFavoriteMovie(Movie movie) async {
    final isFavorite = await localStorageRepository.isFavoriteMovie(movie.id);
    await localStorageRepository.toggleFavoriteMovie(movie);

    if (isFavorite) {
      state.remove(movie.id);
      state = {...state};
      return;
    }

    state = {...state, movie.id: movie};
  }
}
