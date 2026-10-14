import 'package:flix_tap/domain/entities/category.dart';
import 'package:flix_tap/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoriesView extends ConsumerWidget {
  const CategoriesView({super.key});

  static const _categoryIcons = <int, IconData>{
    12: Icons.explore_outlined,
    14: Icons.auto_awesome_outlined,
    16: Icons.animation_outlined,
    18: Icons.theater_comedy_outlined,
    27: Icons.local_fire_department_outlined,
    28: Icons.flash_on_outlined,
    35: Icons.sentiment_very_satisfied_outlined,
    36: Icons.account_balance_outlined,
    37: Icons.landscape_outlined,
    53: Icons.visibility_outlined,
    80: Icons.gavel_outlined,
    99: Icons.movie_filter_outlined,
    10402: Icons.music_note_outlined,
    10749: Icons.favorite_border_rounded,
    10751: Icons.family_restroom_rounded,
    10752: Icons.shield_outlined,
    10770: Icons.tv_outlined,
    9648: Icons.search_rounded,
    878: Icons.rocket_launch_outlined,
  };

  static const _accents = <Color>[
    Color(0xFF69BDEB),
    Color(0xFFF2937A),
    Color(0xFF91A9F5),
    Color(0xFF65C6B5),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final colors = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Explora por categorías'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Explora por género',
                //   style: Theme.of(context).textTheme.headlineSmall
                //       ?.copyWith(fontWeight: FontWeight.w700),
                // ),
                // const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Encuentra tu próxima película favorita.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ),
                    categoriesAsync.maybeWhen(
                      data: (categories) =>
                          _CategoryCount(count: categories.length),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        categoriesAsync.when(
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: _CategoryState(
              icon: Icons.movie_filter_outlined,
              title: 'Preparando categorías',
              subtitle: 'Estamos buscando películas para explorar.',
              isLoading: true,
            ),
          ),
          error: (error, stackTrace) => SliverFillRemaining(
            hasScrollBody: false,
            child: _CategoryState(
              icon: Icons.cloud_off_outlined,
              title: 'No se pudieron cargar las categorías',
              subtitle: 'Revisa tu conexión e inténtalo de nuevo.',
              action: TextButton.icon(
                onPressed: () => ref.invalidate(categoriesProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: _CategoryState(
                  icon: Icons.category_outlined,
                  title: 'Aún no hay categorías',
                  subtitle: 'Vuelve más tarde para descubrir nuevos géneros.',
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  return _CategoryCard(
                    category: category,
                    accent: _accents[index % _accents.length],
                    icon: _categoryIcons[category.id] ?? Icons.movie_outlined,
                    onTap: () => context.push('/categories/${category.id}'),
                  );
                }, childCount: categories.length),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryCount extends StatelessWidget {
  final int count;

  const _CategoryCount({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = count == 1 ? '1 categoría' : '$count categorías';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_view_rounded, size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(20);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primaryContainer, colors.surface],
          ),
        ),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: accent, size: 25),
                    ),
                    Icon(
                      Icons.arrow_outward_rounded,
                      color: colors.onSurfaceVariant,
                      size: 19,
                    ),
                  ],
                ),
                Column(
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
                    const SizedBox(height: 4),
                    Text(
                      'Ver películas',
                      style: textTheme.bodySmall?.copyWith(color: accent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final bool isLoading;

  const _CategoryState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              CircularProgressIndicator(color: colors.primary)
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 30, color: colors.primary),
              ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}
