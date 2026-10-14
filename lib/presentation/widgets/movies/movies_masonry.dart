import 'package:flix_tap/domain/entities/movie.dart';
import 'package:flix_tap/presentation/widgets/movies/movie_poster_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MovieMasonry extends StatefulWidget {
  final List<Movie> movies;
  final Future<List<Movie>> Function()? loadNextPage;
  final bool asSliver;

  const MovieMasonry({
    super.key,
    required this.movies,
    this.loadNextPage,
    this.asSliver = false,
  });

  @override
  State<MovieMasonry> createState() => _MovieMasonryState();
}

class _MovieMasonryState extends State<MovieMasonry> {
  bool isLastPage = false;
  bool isLoading = false;
  bool isPageLoadScheduled = false;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      // Si el scroll está al final o cerca de unos 200px, aquí llamar el loadNextPage
      if (scrollController.position.pixels + 200 >=
          scrollController.position.maxScrollExtent) {
        loadNextPageMovies();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void loadNextPageMovies() async {
    if (isLoading || isLastPage) return;
    if (widget.loadNextPage == null) return;

    isLoading = true;
    try {
      final movies = await widget.loadNextPage!();
      if (movies.isEmpty) {
        isLastPage = true;
      }
    } finally {
      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  void _scheduleNextPageIfNeeded(int index) {
    if (index < widget.movies.length - 3 ||
        isLoading ||
        isLastPage ||
        isPageLoadScheduled ||
        widget.loadNextPage == null) {
      return;
    }

    isPageLoadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isPageLoadScheduled = false;
      if (mounted) loadNextPageMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asSliver) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverMasonryGrid.count(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childCount: widget.movies.length,
          itemBuilder: (context, index) {
            _scheduleNextPageIfNeeded(index);
            return _buildMovieItem(index);
          },
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients || isLoading || isLastPage) {
        return;
      }

      if (scrollController.position.extentAfter <= 200) {
        loadNextPageMovies();
      }
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: MasonryGridView.count(
        controller: scrollController,
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: widget.movies.length,
        itemBuilder: (context, index) => _buildMovieItem(index),
      ),
    );
  }

  Widget _buildMovieItem(int index) {
    if (index == 1) {
      return Column(
        children: [
          const SizedBox(height: 30),
          MoviePosterLink(movie: widget.movies[index]),
        ],
      );
    }

    return MoviePosterLink(movie: widget.movies[index]);
  }
}
