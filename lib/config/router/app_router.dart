import 'package:flix_tap/presentation/screens/screens.dart';
import 'package:flix_tap/presentation/views/views.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return HomeScreen(childView: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return HomeView();
          },
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
        GoRoute(
          path: '/favorites',
          builder: (context, state) {
            return FavoritesView();
          },
        ),
      ],
    ),
    //* Rutas padre/hijo
    // GoRoute(
    //   path: '/',
    //   name: HomeScreen.name,
    //   builder: (context, state) => const HomeScreen(childView: FavoritesView()),
    //   routes: [
    // GoRoute(
    //   path: 'movie/:id',
    //   name: MovieScreen.name,
    //   builder: (context, state) =>
    //       MovieScreen(movieId: state.pathParameters['id']!),
    // ),
    // GoRoute(
    //   path: 'person/:id',
    //   name: PersonScreen.name,
    //   builder: (context, state) =>
    //       PersonScreen(personId: state.pathParameters['id']!),
    // ),
    //   ],
    // ),
  ],
);
