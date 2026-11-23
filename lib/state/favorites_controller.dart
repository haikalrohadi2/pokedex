import 'package:flutter/foundation.dart';

import '../models/favorite_pokemon.dart';
import '../storage/favorite_storage.dart';

/// Menyimpan daftar favorit di memori + otomatis menyimpannya ke Local Storage.
/// Tampilan cukup "mendengarkan" controller ini (ListenableBuilder).
class FavoritesController extends ChangeNotifier {
  FavoritesController._();
  static final FavoritesController instance = FavoritesController._();

  final FavoriteStorage _storage = FavoriteStorage();
  List<FavoritePokemon> _items = [];

  List<FavoritePokemon> get items => List.unmodifiable(_items);

  bool isFavorite(int id) => _items.any((p) => p.id == id);

  /// Dipanggil sekali saat aplikasi dibuka: membaca data dari Local Storage.
  Future<void> load() async {
    _items = await _storage.load();
    notifyListeners();
  }

  Future<void> add(FavoritePokemon pokemon) async {
    if (isFavorite(pokemon.id)) return;
    _items = [..._items, pokemon];
    notifyListeners();
    await _storage.save(_items);
  }

  Future<void> remove(int id) async {
    _items = _items.where((p) => p.id != id).toList();
    notifyListeners();
    await _storage.save(_items);
  }

  Future<void> toggle(FavoritePokemon pokemon) {
    return isFavorite(pokemon.id) ? remove(pokemon.id) : add(pokemon);
  }
}
