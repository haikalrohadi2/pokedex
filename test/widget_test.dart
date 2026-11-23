import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/models/pokemon.dart';

// Menggantikan test bawaan Flutter (counter) yang tidak cocok dengan PokeDex.
void main() {
  test('PokemonDetail.fromJson membaca data dengan benar', () {
    final json = <String, dynamic>{
      'id': 25,
      'name': 'pikachu',
      'height': 4,
      'weight': 60,
      'types': [
        {'type': {'name': 'electric'}},
      ],
      'abilities': [
        {'ability': {'name': 'static'}},
      ],
      'stats': [
        {'base_stat': 35, 'stat': {'name': 'hp'}},
      ],
    };

    final p = PokemonDetail.fromJson(json);

    expect(p.id, 25);
    expect(p.name, 'pikachu');
    expect(p.types, ['electric']);
    expect(p.heightM, 0.4);
    expect(p.weightKg, 6.0);
    expect(p.abilities, ['static']);
    expect(p.stats.first.value, 35);
  });

  test('PokemonRef.fromListJson mengambil ID dari url', () {
    final ref = PokemonRef.fromListJson({
      'name': 'bulbasaur',
      'url': 'https://pokeapi.co/api/v2/pokemon/1/',
    });
    expect(ref.id, 1);
    expect(ref.name, 'bulbasaur');
  });
}
