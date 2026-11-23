import 'pokemon.dart';

/// Data minimal yang disimpan di Local Storage untuk koleksi favorit.
class FavoritePokemon {
  final int id;
  final String name;
  final List<String> types;

  const FavoritePokemon({
    required this.id,
    required this.name,
    required this.types,
  });

  factory FavoritePokemon.fromDetail(PokemonDetail d) =>
      FavoritePokemon(id: d.id, name: d.name, types: d.types);

  String get imageUrl => PokemonImages.official(id);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'types': types};

  factory FavoritePokemon.fromJson(Map<String, dynamic> json) => FavoritePokemon(
        id: json['id'] as int,
        name: json['name'] as String,
        types: (json['types'] as List).map((e) => e.toString()).toList(),
      );
}
