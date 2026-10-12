import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flix_tap/presentation/providers/storage/local_storage_provider.dart';

// final isFavoriteMovieProvider = FutureProvider.family.autoDispose<bool, int>((
final isFavoriteMovieProvider = FutureProvider.family<bool, int>((
  ref,
  movieId,
) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return localStorageRepository.isFavoriteMovie(movieId);
});
