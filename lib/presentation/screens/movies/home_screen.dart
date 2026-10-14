import 'package:flix_tap/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  static const String name = 'home_screen';
  final StatefulNavigationShell navigationShell;
  final bool showBottomNavigation;

  const HomeScreen({
    super.key,
    required this.navigationShell,
    required this.showBottomNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: showBottomNavigation
          ? CustomBottomNavigation(navigationShell: navigationShell)
          : null,
    );
  }
}
