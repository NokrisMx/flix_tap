import 'package:flix_tap/domain/entities/video.dart';
import 'package:flix_tap/presentation/providers/movies/videos_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videosByMovieProvider = FutureProvider.family<Video, String>((
  ref,
  movieId,
) {
  final videosRepository = ref.watch(videosRepositoryProvider);
  return videosRepository.getVideo(movieId);
});
