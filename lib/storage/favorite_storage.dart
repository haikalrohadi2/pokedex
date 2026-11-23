import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_pokemon.dart';

/// Membaca/menulis daftar favorit ke SharedPreferences.
/// Disimpan sebagai satu string JSON: [{id, name, types}, ...]
class FavoriteStorage {
  static const String _key = 'favorite_pokemon';

  Future<List<FavoritePokemon>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => FavoritePokemon.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // data rusak -> mulai dari kosong
    }
  }

  Future<void> save(List<FavoritePokemon> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }
}
