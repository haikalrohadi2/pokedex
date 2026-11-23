import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../screens/detail_screen.dart';
import '../services/pokemon_service.dart';
import '../state/favorites_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'type_chip.dart';

/// Kartu Pokémon di halaman Home.
/// Nama & nomor langsung tampil; tipe (dan warna kartu) dimuat per kartu
/// hanya saat kartu terlihat di layar (pemuatan bertahap).
class PokemonCard extends StatefulWidget {
  final PokemonRef pokemon;
  const PokemonCard({super.key, required this.pokemon});

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  late Future<PokemonDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = PokemonService.instance.getDetail(widget.pokemon.id);
  }

  void _retry() {
    setState(() {
      _future = PokemonService.instance.getDetail(widget.pokemon.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pokemon;
    final heroTag = 'home-${p.id}';

    return FutureBuilder<PokemonDetail>(
      future: _future,
      builder: (context, snapshot) {
        final types = snapshot.data?.types ?? const <String>[];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          decoration: BoxDecoration(
            gradient: TypeColors.gradient(types),
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
                padding: const EdgeInsets.all(12),
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
                        ListenableBuilder(
                          listenable: FavoritesController.instance,
                          builder: (context, _) {
                            final fav = FavoritesController.instance.isFavorite(p.id);
                            return Icon(
                              fav ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: fav ? AppColors.primary : Colors.white38,
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
                            PokemonImages.official(p.id),
                            fit: BoxFit.contain,
                            cacheWidth: 300,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                            errorBuilder: (context, error, stack) => const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white38,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      prettyName(p.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 24,
                      child: snapshot.hasError
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: _retry,
                                child: const Icon(Icons.refresh, size: 18, color: Colors.white54),
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  for (final t in types)
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
      },
    );
  }
}
