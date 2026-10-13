import 'package:flix_tap/presentation/providers/providers.dart';
import 'package:flix_tap/presentation/widgets/movies/movies_masonry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoviesByCategoryView extends ConsumerStatefulWidget {
  final String categoryId;

  const MoviesByCategoryView({super.key, required this.categoryId});

  @override
  ConsumerState<MoviesByCategoryView> createState() =>
      _MoviesByCategoryViewState();
}

class _MoviesByCategoryViewState extends ConsumerState<MoviesByCategoryView> {
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      await ref
          .read(moviesByCategoryProvider(widget.categoryId).notifier)
          .loadNextPage();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movies = ref.watch(moviesByCategoryProvider(widget.categoryId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryName = categoriesAsync.maybeWhen(
      data: (categories) {
        for (final category in categories) {
          if (category.id.toString() == widget.categoryId) {
            return category.name;
          }
        }
        return 'Categoría';
      },
      orElse: () => 'Categoría',
    );

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudieron cargar las películas'),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isLoading = true;
                      });
                      ref.invalidate(
                        moviesByCategoryProvider(widget.categoryId),
                      );
                      _loadMovies();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _isLoading && movies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : movies.isEmpty
          ? const Center(child: Text('No hay películas en esta categoría'))
          : MovieMasonry(
              movies: movies,
              loadNextPage: () async {
                await ref
                    .read(moviesByCategoryProvider(widget.categoryId).notifier)
                    .loadNextPage();
                return ref.read(moviesByCategoryProvider(widget.categoryId));
              },
            ),
    );
  }
}
