import 'package:flutter/material.dart';

import '../state/favorites_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/poke_logo.dart';
import 'collection_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Kerangka navigasi utama.
/// Layar kecil (< 600 px)  : Bottom Navigation.
/// Layar sedang/besar      : Navigation Rail di sisi kiri
///                           (diperluas dengan teks jika lebar >= 1000 px).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    CollectionScreen(),
    ProfileScreen(),
  ];

  Widget _collectionIcon({required bool selected}) {
    return ListenableBuilder(
      listenable: FavoritesController.instance,
      builder: (context, _) {
        final count = FavoritesController.instance.items.length;
        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: Icon(selected ? Icons.favorite : Icons.favorite_border),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final body = IndexedStack(index: _index, children: _pages);

    if (width >= 600) {
      final extended = width >= 1000;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              extended: extended,
              labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              onDestinationSelected: (i) => setState(() => _index = i),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: extended
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PokeLogo(size: 32),
                          SizedBox(width: 10),
                          Text(
                            'PokeDex',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : const PokeLogo(size: 32),
              ),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: Text('Explore'),
                ),
                NavigationRailDestination(
                  icon: _collectionIcon(selected: false),
                  selectedIcon: _collectionIcon(selected: true),
                  label: const Text('Koleksi'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profil'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.surfaceLight),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: _collectionIcon(selected: false),
            selectedIcon: _collectionIcon(selected: true),
            label: 'Koleksi',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
