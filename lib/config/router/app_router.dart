import 'package:flix_tap/presentation/screens/screens.dart';
import 'package:flix_tap/presentation/views/views.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute(
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
      navigatorContainerBuilder: (context, navigationShell, children) =>
          _DirectionalBranchContainer(
            navigationShell: navigationShell,
            children: children,
          ),
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

class _DirectionalBranchContainer extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const _DirectionalBranchContainer({
    required this.navigationShell,
    required this.children,
  });

  @override
  State<_DirectionalBranchContainer> createState() =>
      _DirectionalBranchContainerState();
}

class _DirectionalBranchContainerState
    extends State<_DirectionalBranchContainer>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 280);

  late final AnimationController _controller;
  int? _outgoingIndex;
  late int _direction;

  int get _currentIndex => widget.navigationShell.currentIndex;

  @override
  void initState() {
    super.initState();
    _direction = 1;
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener(_handleAnimationStatus);
  }

  @override
  void didUpdateWidget(covariant _DirectionalBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousIndex = oldWidget.navigationShell.currentIndex;
    if (previousIndex == _currentIndex) return;

    _outgoingIndex = previousIndex;
    _direction = _currentIndex > previousIndex ? 1 : -1;
    _controller.forward(from: 0);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _outgoingIndex = null);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Stack(
            fit: StackFit.expand,
            children: [
              for (var index = 0; index < widget.children.length; index++)
                _buildBranch(index, width),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranch(int index, double width) {
    final isCurrent = index == _currentIndex;
    final isOutgoing = index == _outgoingIndex;
    final isVisible = isCurrent || isOutgoing;

    var offset = 0.0;
    if (_outgoingIndex != null && isOutgoing) {
      offset = -_direction * width * _controller.value;
    } else if (_outgoingIndex != null && isCurrent) {
      offset = _direction * width * (1 - _controller.value);
    }

    return Offstage(
      offstage: !isVisible,
      child: TickerMode(
        enabled: isCurrent,
        child: IgnorePointer(
          ignoring: !isCurrent,
          child: Transform.translate(
            offset: Offset(offset, 0),
            child: widget.children[index],
          ),
        ),
      ),
    );
  }
}
