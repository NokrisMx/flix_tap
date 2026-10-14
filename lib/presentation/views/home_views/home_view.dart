import 'package:flix_tap/presentation/providers/providers.dart';
import 'package:flix_tap/presentation/widgets/movies/movie_horizontal_listview.dart';
import 'package:flix_tap/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const request = InitialLoadRequest.home();
    final loadState = ref.watch(initialLoadingProvider(request));

    return InitialLoadView(
      state: loadState,
      loadingTitle: 'Preparando películas',
      loadingSubtitle: 'Estamos buscando películas para explorar.',
      errorTitle: 'No se pudieron cargar las películas',
      onRetry: () => ref.read(initialLoadingProvider(request).notifier).retry(),
      builder: (context) {
        final slideshowMovies = ref.watch(moviesSlideshowProvider);
        final nowPlayingMovies = ref.watch(nowPlayingMoviesProvider);
        final popularMovies = ref.watch(popularMoviesProvider);
        final topRatedMovies = ref.watch(topRatedMoviesProvider);
        final upcomingMovies = ref.watch(upcomingMoviesProvider);

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                title: CustomAppbar(),
                titlePadding: EdgeInsets.all(0),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Column(
                  children: [
                    MoviesSlideshow(movies: slideshowMovies),
                    SizedBox(height: 10),
                    MovieHorizontalListview(
                      movies: nowPlayingMovies,
                      title: 'En cines',
                      loadNextPage: () => ref
                          .read(nowPlayingMoviesProvider.notifier)
                          .loadNextPage(),
                    ),
                    SizedBox(height: 10),
                    MovieHorizontalListview(
                      movies: upcomingMovies,
                      title: 'Próximamente',
                      loadNextPage: () => ref
                          .read(upcomingMoviesProvider.notifier)
                          .loadNextPage(),
                    ),
                    SizedBox(height: 10),
                    MovieHorizontalListview(
                      movies: popularMovies,
                      title: 'Populares',
                      loadNextPage: () => ref
                          .read(popularMoviesProvider.notifier)
                          .loadNextPage(),
                    ),
                    SizedBox(height: 10),
                    MovieHorizontalListview(
                      movies: topRatedMovies,
                      title: 'Mejor calificadas',
                      loadNextPage: () => ref
                          .read(topRatedMoviesProvider.notifier)
                          .loadNextPage(),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }, childCount: 1),
            ),
          ],
        );
      },
    );
  }
}
