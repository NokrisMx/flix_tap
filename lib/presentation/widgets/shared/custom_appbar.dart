import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flix_tap/domain/entities/movie.dart';
import 'package:flix_tap/presentation/delegates/search_movie_delegate.dart';
import 'package:flix_tap/presentation/providers/providers.dart';

class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/icon/icon_2.png',
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Text.rich(
                TextSpan(
                  style: titleStyle?.copyWith(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: 0.2,
                  ),
                  children: const [
                    TextSpan(text: 'Flix'),
                    TextSpan(
                      text: 'Tap',
                      style: TextStyle(color: Color(0xFFF98B6A)),
                    ),
                  ],
                ),
              ),

              Spacer(),

              IconButton.filledTonal(
                tooltip: 'Buscar películas',
                onPressed: () {
                  final searchedMovies = ref.read(searchedMoviesProvider);
                  final searchQuery = ref.read(searchQueryProvider);

                  showSearch<Movie?>(
                    query: searchQuery,
                    context: context,
                    delegate: SearchMovieDelegate(
                      initialMovies: searchedMovies,
                      searchMovies: ref
                          .read(searchedMoviesProvider.notifier)
                          .searchMoviesByQuery,
                    ),
                  ).then((movie) {
                    if (movie == null) return;

                    if (context.mounted) {
                      context.push('/movie/${movie.id}');
                    }
                  });
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
