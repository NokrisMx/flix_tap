import 'package:flix_tap/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoriesView extends ConsumerWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(floating: true, title: Text('Categorías')),
        categoriesAsync.when(
          loading: () => SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No se pudieron cargar las categorías'),
                  TextButton(
                    onPressed: () => ref.invalidate(categoriesProvider),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No hay categorías disponibles')),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];

                  return Card(
                    color: colors.primaryContainer,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () =>
                          context.push('/categories/${category.id}'),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            category.name,
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: categories.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
