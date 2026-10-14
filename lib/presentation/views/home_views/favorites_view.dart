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
    final colors = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        const SliverAppBar(floating: true, title: Text('Favoritos')),
        if (myMovieList.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 72,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No tienes películas favoritas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          )
        else
          MovieMasonry(
            asSliver: true,
            movies: myMovieList,
            loadNextPage: () =>
                ref.read(favoriteMoviesProvider.notifier).loadNextPage(),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}
