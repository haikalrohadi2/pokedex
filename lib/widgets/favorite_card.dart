import 'package:flutter/material.dart';

import '../models/favorite_pokemon.dart';
import '../screens/detail_screen.dart';
import '../state/favorites_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'type_chip.dart';

/// Kartu Pokémon di halaman My Collection (data dari Local Storage).
class FavoriteCard extends StatelessWidget {
  final FavoritePokemon pokemon;
  const FavoriteCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final p = pokemon;
    final heroTag = 'fav-${p.id}';

    return Container(
      decoration: BoxDecoration(
        gradient: TypeColors.gradient(p.types),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => openPokemonDetail(
            context,
            id: p.id,
            name: p.name,
            heroTag: heroTag,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatNumber(p.id),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hapus dari koleksi',
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.white70,
                      onPressed: () {
                        final messenger = ScaffoldMessenger.of(context);
                        FavoritesController.instance.remove(p.id);
                        messenger
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text('${prettyName(p.name)} dihapus dari koleksi'),
                              action: SnackBarAction(
                                label: 'Urungkan',
                                onPressed: () => FavoritesController.instance.add(p),
                              ),
                            ),
                          );
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        p.imageUrl,
                        fit: BoxFit.contain,
                        cacheWidth: 300,
                        errorBuilder: (context, error, stack) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white38,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    prettyName(p.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 24,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        for (final t in p.types)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: TypeChip(type: t),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
