import 'package:flix_tap/presentation/providers/providers.dart';
import 'package:flix_tap/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const request = InitialLoadRequest.favorites();
    final loadState = ref.watch(initialLoadingProvider(request));

    return InitialLoadView(
      state: loadState,
      loadingTitle: 'Cargando favoritos',
      loadingSubtitle: 'Buscando tus películas guardadas.',
      errorTitle: 'No se pudieron cargar tus favoritos',
      onRetry: () => ref.read(initialLoadingProvider(request).notifier).retry(),
      builder: (context) {
        final favoriteMovies = ref.watch(favoriteMoviesProvider);
        final movies = favoriteMovies.values.toList();

        if (movies.isEmpty) {
          final colors = Theme.of(context).colorScheme;

          return CustomScrollView(
            slivers: [
              const SliverAppBar(floating: true, title: Text('Favoritos')),
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
              ),
            ],
          );
        }

        return CustomScrollView(
          slivers: [
            const SliverAppBar(floating: true, title: Text('Favoritos')),
            MovieMasonry(
              asSliver: true,
              movies: movies,
              loadNextPage: () =>
                  ref.read(favoriteMoviesProvider.notifier).loadNextPage(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }
}
