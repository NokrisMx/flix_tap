import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomBottomNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        navigationShell.goBranch(index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_max), label: 'Inicio'),

        // BottomNavigationBarItem(
        //   icon: Icon(Icons.label_outline),
        //   label: 'Categorías',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          label: 'Favoritos',
        ),
      ],
    );
  }
}
