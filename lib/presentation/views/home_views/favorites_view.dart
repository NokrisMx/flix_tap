import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flix_tap/presentation/widgets/movies/movies_masonry.dart';
import 'package:flix_tap/presentation/providers/storage/favorite_movies_provider.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  ConsumerState<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends ConsumerState<FavoritesView> {
  @override
  void initState() {
    ref.read(favoriteMoviesProvider.notifier).loadNextPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteMovies = ref.watch(favoriteMoviesProvider);
    final myMovieList = favoriteMovies.values.toList();

    final colorPrimary = Theme.of(context).colorScheme.primary;

    if (myMovieList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Favoritos')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 100, color: colorPrimary),
              const Text('No tienes películas favoritas'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Favoritos')),
      body: MovieMasonry(
        movies: myMovieList,
        loadNextPage: () =>
            ref.read(favoriteMoviesProvider.notifier).loadNextPage(),
      ),
    );
  }
}
