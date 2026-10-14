import 'package:flix_tap/presentation/providers/providers.dart';
import 'package:flix_tap/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoviesByCategoryView extends ConsumerWidget {
  final String categoryId;

  const MoviesByCategoryView({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = InitialLoadRequest.categoryMovies(categoryId);
    final loadState = ref.watch(initialLoadingProvider(request));
    final movies = ref.watch(moviesByCategoryProvider(categoryId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryName = categoriesAsync.maybeWhen(
      data: (categories) {
        for (final category in categories) {
          if (category.id.toString() == categoryId) {
            return category.name;
          }
        }
        return 'Categoría';
      },
      orElse: () => 'Categoría',
    );

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: InitialLoadView(
        state: loadState,
        loadingTitle: 'Cargando películas',
        loadingSubtitle: 'Buscando películas de esta categoría.',
        errorTitle: 'No se pudieron cargar las películas',
        onRetry: () =>
            ref.read(initialLoadingProvider(request).notifier).retry(),
        builder: (context) => movies.isEmpty
            ? const Center(child: Text('No hay películas en esta categoría'))
            : MovieMasonry(
                movies: movies,
                loadNextPage: () async {
                  await ref
                      .read(moviesByCategoryProvider(categoryId).notifier)
                      .loadNextPage();
                  return ref.read(moviesByCategoryProvider(categoryId));
                },
              ),
      ),
    );
  }
}
