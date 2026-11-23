import 'package:flutter/material.dart';

import '../models/favorite_pokemon.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../state/favorites_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/stat_bar.dart';
import '../widgets/state_views.dart';
import '../widgets/type_chip.dart';

/// Membuka halaman detail dengan transisi fade + geser halus.
void openPokemonDetail(
  BuildContext context, {
  required int id,
  required String name,
  required String heroTag,
}) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) =>
          DetailScreen(id: id, name: name, heroTag: heroTag),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
                .animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

/// Tambah/hapus favorit lalu tampilkan pesan singkat.
Future<void> toggleFavorite(BuildContext context, PokemonDetail pokemon) async {
  final controller = FavoritesController.instance;
  final messenger = ScaffoldMessenger.of(context);
  final wasFavorite = controller.isFavorite(pokemon.id);

  await controller.toggle(FavoritePokemon.fromDetail(pokemon));

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite
              ? '${prettyName(pokemon.name)} dihapus dari koleksi'
              : '${prettyName(pokemon.name)} ditambahkan ke koleksi',
        ),
      ),
    );
}

class DetailScreen extends StatefulWidget {
  final int id;
  final String name;
  final String heroTag;

  const DetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.heroTag,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<PokemonDetail> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = PokemonService.instance.getDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokemonDetail>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              message: error is ApiException ? error.message : 'Gagal memuat data.',
              onRetry: () => setState(_load),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: widget.heroTag,
                    child: Image.network(
                      PokemonImages.official(widget.id),
                      height: 220,
                      errorBuilder: (context, error, stack) => const SizedBox(height: 220),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    prettyName(widget.name),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }
        return _DetailContent(pokemon: snapshot.data!, heroTag: widget.heroTag);
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  final PokemonDetail pokemon;
  final String heroTag;

  const _DetailContent({required this.pokemon, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final color = TypeColors.of(pokemon.types.isEmpty ? '' : pokemon.types.first);
    final controller = FavoritesController.instance;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final fav = controller.isFavorite(pokemon.id);
              return IconButton(
                tooltip: fav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                icon: Icon(
                  fav ? Icons.favorite : Icons.favorite_border,
                  color: fav ? AppColors.primary : Colors.white,
                ),
                onPressed: () => toggleFavorite(context, pokemon),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(color, AppColors.background, 0.25)!, AppColors.background],
            stops: const [0, 0.65],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 800;
                if (wide) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(child: _heroPanel()),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(child: _infoPanel(context, color)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Column(children: [_heroPanel(), _infoPanel(context, color)]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            formatNumber(pokemon.id),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            prettyName(pokemon.name),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [for (final t in pokemon.types) TypeChip(type: t, large: true)],
          ),
          const SizedBox(height: 12),
          Hero(
            tag: heroTag,
            child: Image.network(
              pokemon.imageUrl,
              height: 260,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => const SizedBox(
                height: 260,
                child: Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPanel(BuildContext context, Color color) {
    final controller = FavoritesController.instance;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _infoTile(Icons.height, 'Tinggi', '${pokemon.heightM.toStringAsFixed(1)} m')),
              const SizedBox(width: 12),
              Expanded(child: _infoTile(Icons.monitor_weight_outlined, 'Berat', '${pokemon.weightKg.toStringAsFixed(1)} kg')),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Abilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in pokemon.abilities)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(prettyName(a)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Base Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          for (final s in pokemon.stats)
            StatBar(label: statLabel(s.name), value: s.value, color: color),
          const SizedBox(height: 20),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final fav = controller.isFavorite(pokemon.id);
              return FilledButton.icon(
                onPressed: () => toggleFavorite(context, pokemon),
                icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                label: Text(fav ? 'Hapus dari Favorit' : 'Tambahkan ke Favorit'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: fav ? AppColors.surfaceLight : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
