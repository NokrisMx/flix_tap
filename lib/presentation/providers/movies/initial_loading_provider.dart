import 'dart:async';

import 'package:flix_tap/presentation/providers/actors/actors_by_movie_provider.dart';
import 'package:flix_tap/presentation/providers/categories/categories_repository_provider.dart';
import 'package:flix_tap/presentation/providers/movies/movie_info_provider.dart';
import 'package:flix_tap/presentation/providers/movies/movies_providers.dart';
import 'package:flix_tap/presentation/providers/movies/videos_by_movie_provider.dart';
import 'package:flix_tap/presentation/providers/persons/persons_provider.dart';
import 'package:flix_tap/presentation/providers/storage/favorite_movies_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InitialLoadTarget {
  home,
  categories,
  favorites,
  categoryMovies,
  movie,
  person,
}

class InitialLoadRequest {
  final InitialLoadTarget target;
  final String? id;

  const InitialLoadRequest.home() : target = InitialLoadTarget.home, id = null;

  const InitialLoadRequest.categories()
    : target = InitialLoadTarget.categories,
      id = null;

  const InitialLoadRequest.favorites()
    : target = InitialLoadTarget.favorites,
      id = null;

  const InitialLoadRequest.categoryMovies(String categoryId)
    : target = InitialLoadTarget.categoryMovies,
      id = categoryId;

  const InitialLoadRequest.movie(String movieId)
    : target = InitialLoadTarget.movie,
      id = movieId;

  const InitialLoadRequest.person(String personId)
    : target = InitialLoadTarget.person,
      id = personId;

  @override
  bool operator ==(Object other) =>
      other is InitialLoadRequest && other.target == target && other.id == id;

  @override
  int get hashCode => Object.hash(target, id);
}

final initialLoadingProvider =
    StateNotifierProvider.family<
      InitialLoadingNotifier,
      AsyncValue<void>,
      InitialLoadRequest
    >((ref, request) {
      return InitialLoadingNotifier(ref, request);
    });

class InitialLoadingNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final InitialLoadRequest request;

  InitialLoadingNotifier(this.ref, this.request) : super(const AsyncLoading()) {
    unawaited(load());
  }

  Future<void> retry() async {
    switch (request.target) {
      case InitialLoadTarget.categories:
        ref.invalidate(categoriesProvider);
        break;
      case InitialLoadTarget.categoryMovies:
        if (ref.read(categoriesProvider).hasError) {
          ref.invalidate(categoriesProvider);
        }
        break;
      case InitialLoadTarget.movie:
        if (ref.read(videosByMovieProvider(request.id!)).hasError) {
          ref.invalidate(videosByMovieProvider(request.id!));
        }
        break;
      case InitialLoadTarget.person:
      case InitialLoadTarget.home:
        break;
      case InitialLoadTarget.favorites:
        ref.invalidate(categoriesProvider);
        break;
    }

    await load();
  }

  Future<void> load() async {
    state = const AsyncLoading();

    try {
      switch (request.target) {
        case InitialLoadTarget.home:
          await Future.wait([
            if (ref.read(nowPlayingMoviesProvider.notifier).currentPage == 0)
              ref.read(nowPlayingMoviesProvider.notifier).loadNextPage(),
            if (ref.read(popularMoviesProvider.notifier).currentPage == 0)
              ref.read(popularMoviesProvider.notifier).loadNextPage(),
            if (ref.read(topRatedMoviesProvider.notifier).currentPage == 0)
              ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
            if (ref.read(upcomingMoviesProvider.notifier).currentPage == 0)
              ref.read(upcomingMoviesProvider.notifier).loadNextPage(),
          ]);
          break;
        case InitialLoadTarget.categories:
          await ref.read(categoriesProvider.future);
          break;
        case InitialLoadTarget.favorites:
          await Future.wait([
            ref.read(categoriesProvider.future),
            ref.read(favoriteMoviesProvider.notifier).loadNextPage(),
          ]);
          break;
        case InitialLoadTarget.categoryMovies:
          await Future.wait([
            ref.read(categoriesProvider.future),
            if (ref
                    .read(moviesByCategoryProvider(request.id!).notifier)
                    .currentPage ==
                0)
              ref
                  .read(moviesByCategoryProvider(request.id!).notifier)
                  .loadNextPage(),
          ]);
          break;
        case InitialLoadTarget.movie:
          final movieId = request.id!;
          final actors = ref.read(actorsByMovieProvider)[movieId];
          await Future.wait([
            if (ref.read(movieInfoProvider)[movieId] == null)
              ref.read(movieInfoProvider.notifier).loadMovie(movieId),
            if (actors == null)
              ref.read(actorsByMovieProvider.notifier).loadActors(movieId),
            if (ref.read(similarMoviesProvider(movieId).notifier).currentPage ==
                0)
              ref.read(similarMoviesProvider(movieId).notifier).loadNextPage(),
            ref.read(videosByMovieProvider(movieId).future),
          ]);
          break;
        case InitialLoadTarget.person:
          await ref.read(personInfoProvider.notifier).loadPerson(request.id!);
          break;
      }

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
