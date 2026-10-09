import 'package:flix_tap/presentation/screens/screens.dart';
import 'package:flix_tap/presentation/views/views.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomeScreen(navigationShell: navigationShell);
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

        // Rama 1: Favoritos
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
