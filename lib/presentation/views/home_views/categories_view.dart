import 'package:flix_tap/domain/entities/category.dart';
import 'package:flix_tap/presentation/providers/providers.dart';
import 'package:flix_tap/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoriesView extends ConsumerWidget {
  const CategoriesView({super.key});

  static const _categoryImages = <int, String>{
    12: 'assets/images/categories/adventure.jpg',
    14: 'assets/images/categories/fantasy.jpg',
    16: 'assets/images/categories/animation.jpg',
    18: 'assets/images/categories/drama.jpg',
    27: 'assets/images/categories/horror.jpg',
    28: 'assets/images/categories/action.jpg',
    35: 'assets/images/categories/comedy.jpg',
    36: 'assets/images/categories/history.jpg',
    37: 'assets/images/categories/western.jpg',
    53: 'assets/images/categories/thriller.jpg',
    80: 'assets/images/categories/crime.jpg',
    99: 'assets/images/categories/documentary.jpg',
    878: 'assets/images/categories/science_fiction.jpg',
    9648: 'assets/images/categories/mystery.jpg',
    10402: 'assets/images/categories/music.jpg',
    10749: 'assets/images/categories/romance.jpg',
    10751: 'assets/images/categories/family.jpg',
    10752: 'assets/images/categories/war.jpg',
    10770: 'assets/images/categories/tv_movie.jpg',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const request = InitialLoadRequest.categories();
    final loadState = ref.watch(initialLoadingProvider(request));
    final categoriesAsync = ref.watch(categoriesProvider);

    return InitialLoadView(
      state: loadState,
      loadingTitle: 'Preparando géneros',
      loadingSubtitle: 'Estamos buscando películas para explorar.',
      errorTitle: 'No se pudieron cargar géneros',
      onRetry: () => ref.read(initialLoadingProvider(request).notifier).retry(),
      builder: (context) {
        final categories = categoriesAsync.requireValue;

        if (categories.isEmpty) {
          return const FullScreenLoader(
            icon: Icons.category_outlined,
            title: 'Aún no hay géneros',
            subtitle: 'Vuelve más tarde para descubrir nuevos géneros.',
            isLoading: false,
          );
        }

        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true,
              title: Text(
                'Géneros',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  return _CategoryCard(
                    category: category,
                    imagePath: _categoryImages[category.id],
                    onTap: () => context.push('/categories/${category.id}'),
                  );
                }, childCount: categories.length),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final String? imagePath;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _CategoryImagePlaceholder(color: colors.primaryContainer),
              )
            else
              _CategoryImagePlaceholder(color: colors.primaryContainer),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x08000000),
                    Color(0xE6000000),
                  ],
                  stops: [0, 0.35, 1],
                ),
              ),
            ),
            // Positioned(
            //   top: 12,
            //   left: 12,
            //   child: DecoratedBox(
            //     decoration: BoxDecoration(
            //       color: colors.surface.withValues(alpha: 0.78),
            //       borderRadius: BorderRadius.circular(20),
            //       border: Border.all(
            //         color: colors.onSurface.withValues(alpha: 0.12),
            //       ),
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 10,
            //         vertical: 6,
            //       ),
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Icon(
            //             Icons.movie_filter_outlined,
            //             size: 14,
            //             color: colors.primary,
            //           ),
            //           const SizedBox(width: 5),
            //           Text(
            //             'GÉNERO',
            //             style: textTheme.labelSmall?.copyWith(
            //               color: colors.onSurface,
            //               fontWeight: FontWeight.w700,
            //               letterSpacing: 0.6,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              left: 14,
              right: 12,
              bottom: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Explorar películas',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryImagePlaceholder extends StatelessWidget {
  final Color color;

  const _CategoryImagePlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: Icon(
          Icons.local_movies_outlined,
          size: 44,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
