import 'package:flix_tap/config/helpers/human_formats.dart';
import 'package:flix_tap/domain/entities/video.dart';
import 'package:flix_tap/presentation/providers/storage/is_favorite_movie_provider.dart';
import 'package:flix_tap/presentation/widgets/movies/movie_horizontal_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flix_tap/domain/entities/movie.dart';

import 'package:flix_tap/presentation/providers/providers.dart';
import 'package:flix_tap/presentation/providers/movies/movie_info_provider.dart';
import 'package:flix_tap/presentation/widgets/widgets.dart';

class MovieScreen extends ConsumerWidget {
  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = InitialLoadRequest.movie(movieId);
    final loadState = ref.watch(initialLoadingProvider(request));

    return InitialLoadView(
      state: loadState,
      loadingTitle: 'Cargando película',
      loadingSubtitle: 'Preparando los detalles de la película.',
      errorTitle: 'No se pudo cargar la película',
      onRetry: () => ref.read(initialLoadingProvider(request).notifier).retry(),
      builder: (context) {
        final Movie movie = ref.watch(movieInfoProvider)[movieId]!;

        return Scaffold(
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              _CustomSliverAppBar(movie: movie),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _MovieDetails(movie: movie),
                  childCount: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MovieDetails extends ConsumerWidget {
  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarMovies = ref.watch(similarMoviesProvider(movie.id.toString()));
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.title, style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MovieMetricCard(
                      icon: Icons.star_rounded,
                      label: 'CALIFICACIÓN',
                      value: HumanFormats.number(movie.voteAverage, 1),
                      detail:
                          '${HumanFormats.number(movie.voteCount.toDouble())} votos',
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MovieMetricCard(
                      icon: Icons.trending_up_rounded,
                      label: 'POPULARIDAD',
                      value: HumanFormats.number(movie.popularity, 1),
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MovieInfoCard(
                      icon: Icons.calendar_month_rounded,
                      label: 'ESTRENO',
                      value: HumanFormats.date(movie.releaseDate),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MovieInfoCard(
                      icon: Icons.language_rounded,
                      label: 'IDIOMA ORIGINAL',
                      value: movie.originalLanguage.toUpperCase(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _MovieSectionTitle(icon: Icons.subject_rounded, title: 'Resumen'),
              const SizedBox(height: 10),
              Text(
                movie.overview,
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _MovieSectionTitle(
                icon: Icons.local_offer_outlined,
                title: 'Géneros',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: movie.genreIds
                    .map(
                      (genre) => Chip(
                        avatar: Icon(
                          Icons.movie_filter_outlined,
                          size: 16,
                          color: colors.primary,
                        ),
                        label: Text(genre),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        _MovieTrailer(movieId: movie.id.toString()),

        const SizedBox(height: 24),
        _ActorsByMovie(movieId: movie.id.toString()),

        if (similarMovies.isNotEmpty)
          // Películas similares
          MovieHorizontalListview(
            movies: similarMovies,
            title: 'Películas similares',
            loadNextPage: () => ref
                .read(similarMoviesProvider(movie.id.toString()).notifier)
                .loadNextPage(),
          ),

        const SizedBox(height: 50),
      ],
    );
  }
}

class _MovieMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? detail;
  final Color color;

  const _MovieMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (detail != null) ...[
              const SizedBox(height: 2),
              Text(detail!, style: textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _MovieInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MovieInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: colors.primary),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                letterSpacing: 0.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _MovieSectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _MovieTrailer extends ConsumerWidget {
  final String movieId;

  const _MovieTrailer({required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videosByMovieProvider(movieId));

    return videosAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Expanded(child: Text('No se pudieron cargar los tráileres.')),
            IconButton(
              tooltip: 'Reintentar',
              onPressed: () => ref.invalidate(videosByMovieProvider(movieId)),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
      data: (video) {
        final videos =
            video.results
                .where(
                  (result) =>
                      result.site.toLowerCase() == 'youtube' &&
                      result.key.isNotEmpty &&
                      ['trailer', 'teaser'].contains(result.type.toLowerCase()),
                )
                .toList()
              ..sort(_compareVideos);

        if (videos.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showVideoPicker(context, videos),
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Ver tráiler'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  int _compareVideos(VideoResult first, VideoResult second) {
    var comparison = (second.official ? 1 : 0).compareTo(
      first.official ? 1 : 0,
    );
    if (comparison != 0) return comparison;

    int languagePriority(VideoResult video) {
      if (video.iso6391 == 'es' && video.iso31661 == 'MX') return 2;
      if (video.iso6391 == 'es') return 1;
      return 0;
    }

    comparison = languagePriority(second).compareTo(languagePriority(first));
    if (comparison != 0) return comparison;

    comparison = (second.type.toLowerCase() == 'trailer' ? 1 : 0).compareTo(
      first.type.toLowerCase() == 'trailer' ? 1 : 0,
    );
    if (comparison != 0) return comparison;

    return second.publishedAt.compareTo(first.publishedAt);
  }

  void _showVideoPicker(BuildContext context, List<VideoResult> videos) {
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Selecciona un tráiler',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            ...videos.map(
              (video) => ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(video.name),
                subtitle: Text(
                  '${video.type}${video.official ? ' · Oficial' : ''} · '
                  '${video.iso6391.toUpperCase()}'
                  '${video.iso31661.isNotEmpty ? '-${video.iso31661}' : ''}',
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _openYouTube(video.key, messenger);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openYouTube(
    String videoKey,
    ScaffoldMessengerState messenger,
  ) async {
    final videoUri = Uri.https('www.youtube.com', '/watch', {'v': videoKey});

    try {
      final launched = await launchUrl(
        videoUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No se pudo abrir YouTube.')),
        );
      }
    } on PlatformException {
      if (messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No se pudo abrir YouTube.')),
        );
      }
    }
  }
}

class _ActorsByMovie extends ConsumerWidget {
  final String movieId;

  const _ActorsByMovie({required this.movieId});

  @override
  Widget build(BuildContext context, ref) {
    final actorsByMovie = ref.watch(actorsByMovieProvider);

    if (actorsByMovie[movieId] == null) {
      return CircularProgressIndicator(strokeWidth: 2);
    }
    final actors = actorsByMovie[movieId]!;

    if (actors.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('Elenco', style: Theme.of(context).textTheme.titleLarge),
        ),

        SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actors.length,
            itemBuilder: (context, index) {
              final actor = actors[index];

              return Container(
                padding: EdgeInsets.all(8.0),
                width: 135,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/person/${actor.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Actor Photo
                      FadeInRight(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            actor.profilePath,
                            height: 180,
                            width: 135,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Nombre
                      SizedBox(height: 5),

                      Text(actor.name, maxLines: 2),
                      Text(
                        actor.character ?? '',
                        maxLines: 2,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CustomSliverAppBar extends ConsumerWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isFavoriteFuture = ref.watch(isFavoriteMovieProvider(movie.id));
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return SliverAppBar(
      backgroundColor: backgroundColor,
      expandedHeight: size.height * 0.55,
      foregroundColor: Theme.of(context).colorScheme.onSurface,

      actions: [
        IconButton(
          onPressed: () async {
            await ref
                .read(favoriteMoviesProvider.notifier)
                .toggleFavoriteMovie(movie);
            ref.invalidate(isFavoriteMovieProvider(movie.id));
          },
          icon: isFavoriteFuture.when(
            data: (isFavorite) => isFavorite
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_border_outlined),
            error: (_, _) =>
                throw Exception('Error al cargar el estado de favoritos'),
            loading: () => const CircularProgressIndicator(strokeWidth: 2),
          ),
          // icon: const Icon(Icons.favorite_border_outlined),
          // icon: const Icon(Icons.favorite, color: Colors.red),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        // title: Text(
        //   movie.title,
        //   style: TextStyle(fontSize: 20),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) return SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),

            //SizedBox.expand(
            //child: DecoratedBox(
            //decoration: BoxDecoration(
            //gradient: LinearGradient(
            //begin: Alignment.topCenter,
            //end: Alignment.bottomCenter,
            //stops: [0.7, 1.0],
            //colors: [Colors.transparent, Colors.black87],
            //),
            //),
            //),
            //),

            //Sombra botón de regresar
            _CustomGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.2],
              colors: [Colors.black87, Colors.transparent],
            ),

            //Sombra botón de favoritos
            _CustomGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.0, 0.4],
              colors: [Colors.black87, Colors.transparent],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomGradient extends StatelessWidget {
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;

  const _CustomGradient({
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    required this.stops,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: stops,
            colors: colors,
          ),
        ),
      ),
    );
  }
}
