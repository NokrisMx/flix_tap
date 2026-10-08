import 'package:flix_tap/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
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
);
