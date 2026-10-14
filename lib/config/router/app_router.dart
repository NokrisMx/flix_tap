import 'package:flix_tap/presentation/screens/screens.dart';
import 'package:flix_tap/presentation/views/views.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        final isMainRoute = {
          '/',
          '/categories',
          '/favorites',
        }.contains(state.uri.path);

        return HomeScreen(
          navigationShell: navigationShell,
          showBottomNavigation: isMainRoute,
        );
      },
      branches: [
        // Rama 0: Inicio
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => HomeView(),
              routes: [
                GoRoute(
                  path: 'movie/:id',
                  name: MovieScreen.name,
                  builder: (context, state) =>
                      MovieScreen(movieId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'person/:id',
                  name: PersonScreen.name,
                  builder: (context, state) =>
                      PersonScreen(personId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),

        // Rama 1: Categorias
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/categories',
              builder: (context, state) => CategoriesView(),
              routes: [
                GoRoute(
                  path: ':categoryId',
                  builder: (context, state) => MoviesByCategoryView(
                    categoryId: state.pathParameters['categoryId']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Rama 2: Favoritos
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => FavoritesView(),
            ),
          ],
        ),
      ],
    ),
  ],
);
