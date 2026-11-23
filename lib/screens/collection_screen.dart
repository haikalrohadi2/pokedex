import 'package:flutter/material.dart';

import '../state/favorites_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/favorite_card.dart';
import '../widgets/poke_logo.dart';
import '../widgets/state_views.dart';

/// Halaman My Collection: daftar Pokémon favorit dari Local Storage.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoritesController.instance,
      builder: (context, _) {
        final items = [...FavoritesController.instance.items]
          ..sort((a, b) => a.id.compareTo(b.id));

        return SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Collection',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${items.length} Pokémon favorit',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (items.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        illustration: Opacity(opacity: 0.5, child: PokeLogo(size: 96)),
                        title: 'Koleksi masih kosong',
                        message:
                            'Buka halaman Explore, pilih Pokémon, lalu tekan tombol favorit untuk menyimpannya di sini.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 210,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.74,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => FavoriteCard(
                            key: ValueKey(items[index].id),
                            pokemon: items[index],
                          ),
                          childCount: items.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
