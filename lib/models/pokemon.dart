/// URL gambar resmi Pokémon (dibentuk dari ID, tidak perlu request tambahan).
class PokemonImages {
  static String official(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

/// Data ringan dari daftar Pokémon (hanya ID dan nama).
class PokemonRef {
  final int id;
  final String name;

  const PokemonRef({required this.id, required this.name});

  /// Contoh url: https://pokeapi.co/api/v2/pokemon/25/  -> id = 25
  factory PokemonRef.fromListJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    return PokemonRef(id: int.parse(segments.last), name: json['name'] as String);
  }
}

class PokemonStat {
  final String name;
  final int value;

  const PokemonStat({required this.name, required this.value});
}

/// Data lengkap satu Pokémon (untuk kartu dan halaman detail).
class PokemonDetail {
  final int id;
  final String name;
  final List<String> types;
  final double heightM; // meter
  final double weightKg; // kilogram
  final List<String> abilities;
  final List<PokemonStat> stats;

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.types,
    required this.heightM,
    required this.weightKg,
    required this.abilities,
    required this.stats,
  });

  String get imageUrl => PokemonImages.official(id);

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List)
        .map<String>((t) => t['type']['name'] as String)
        .toList();
    final abilities = (json['abilities'] as List)
        .map<String>((a) => a['ability']['name'] as String)
        .toList();
    final stats = (json['stats'] as List)
        .map<PokemonStat>((s) => PokemonStat(
              name: s['stat']['name'] as String,
              value: s['base_stat'] as int,
            ))
        .toList();

    return PokemonDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      types: types,
      // API: tinggi dalam desimeter, berat dalam hektogram.
      heightM: (json['height'] as int) / 10,
      weightKg: (json['weight'] as int) / 10,
      abilities: abilities,
      stats: stats,
    );
  }
}
