import 'package:flix_tap/config/helpers/human_formats.dart';
import 'package:flix_tap/domain/entities/video.dart';
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

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);
    ref
        .read(similarMoviesProvider(widget.movieId.toString()).notifier)
        .loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];

    if (movie == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
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
  }
}

class _MovieDetails extends ConsumerWidget {
  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;

    final similarMovies = ref.watch(similarMoviesProvider(movie.id.toString()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(movie.posterPath, width: size.width * 0.3),
              ),

              SizedBox(width: 10),

              // Descripción
              SizedBox(
                width: (size.width - 40) * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: (size.width - 40) * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movie.title, style: textStyles.titleLarge),

                          SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(
                                Icons.star_half_outlined,
                                color: Colors.yellow.shade800,
                              ),
                              SizedBox(width: 3),
                              Text(
                                HumanFormats.number(movie.voteAverage, 1),
                                style: textStyles.bodyMedium?.copyWith(
                                  color: Colors.yellow.shade800,
                                ),
                              ),

                              Spacer(),

                              Text(
                                HumanFormats.number(movie.popularity),
                                style: textStyles.bodySmall,
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Estreno: ${HumanFormats.date(movie.releaseDate)}',
                            style: textStyles.bodySmall,
                          ),

                          Text(
                            'Idioma original: ${movie.originalLanguage.toUpperCase()}',
                            style: textStyles.bodySmall,
                          ),

                          SizedBox(height: 8),

                          Text(movie.overview),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Generos de la película
        Padding(
          padding: EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map(
                (gender) => Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Chip(
                    label: Text(gender),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        _MovieTrailer(movieId: movie.id.toString()),

        //Actores
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

        SizedBox(height: 50),
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
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton.icon(
            onPressed: () => _showVideoPicker(context, videos),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Ver tráiler'),
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

class _CustomSliverAppBar extends StatelessWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
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
            SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    stops: [0.0, 0.3],
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
