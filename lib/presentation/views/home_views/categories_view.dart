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
      loadingTitle: 'Preparando categorías',
      loadingSubtitle: 'Estamos buscando películas para explorar.',
      errorTitle: 'No se pudieron cargar las categorías',
      onRetry: () => ref.read(initialLoadingProvider(request).notifier).retry(),
      builder: (context) {
        final categories = categoriesAsync.requireValue;

        if (categories.isEmpty) {
          return const FullScreenLoader(
            icon: Icons.category_outlined,
            title: 'Aún no hay categorías',
            subtitle: 'Vuelve más tarde para descubrir nuevos géneros.',
            isLoading: false,
          );
        }

        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true,
              title: Text(
                'Categorías',
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
                  childAspectRatio: 0.95,
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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imagePath != null)
                    Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(color: Colors.grey),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Explorar',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
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
