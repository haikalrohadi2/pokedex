import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

/// Error yang pesannya aman ditampilkan ke pengguna.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Semua komunikasi dengan PokeAPI ada di sini (terpisah dari tampilan).
class PokemonService {
  PokemonService._();
  static final PokemonService instance = PokemonService._();

  static const String _base = 'https://pokeapi.co/api/v2';
  static const int maxPokemon = 1025;

  final http.Client _client = http.Client();

  List<PokemonRef>? _index; // daftar ringan (nama + id)
  final Map<int, Future<PokemonDetail>> _detailCache = {};
  final Map<String, Set<int>> _typeCache = {};

  Future<Map<String, dynamic>> _getJson(String path) async {
    try {
      final response = await _client
          .get(Uri.parse('$_base/$path'))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw ApiException('Server mengembalikan kode ${response.statusCode}.');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Koneksi terlalu lama. Silakan coba lagi.');
    } on FormatException {
      throw ApiException('Data dari server tidak dapat dibaca.');
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke PokeAPI. Periksa koneksi internet.');
    }
  }

  /// Satu request ringan: hanya nama + url (tanpa detail).
  /// Dipakai untuk pencarian dan sebagai sumber pemuatan bertahap.
  Future<List<PokemonRef>> getIndex() async {
    final cached = _index;
    if (cached != null) return cached;
    final json = await _getJson('pokemon?limit=$maxPokemon');
    final list = (json['results'] as List)
        .map((e) => PokemonRef.fromListJson(e as Map<String, dynamic>))
        .where((p) => p.id <= maxPokemon)
        .toList();
    _index = list;
    return list;
  }

  /// Detail satu Pokémon. Hanya dipanggil saat kartu/halaman benar-benar tampil.
  Future<PokemonDetail> getDetail(int id) {
    final cached = _detailCache[id];
    if (cached != null) return cached;

    final future = _getJson('pokemon/$id').then(PokemonDetail.fromJson);
    _detailCache[id] = future;
    // Jika gagal, hapus dari cache supaya bisa dicoba lagi.
    future.then((_) {}, onError: (_) => _detailCache.remove(id));
    return future;
  }

  /// Kumpulan ID Pokémon untuk satu tipe (untuk filter).
  Future<Set<int>> getIdsByType(String type) async {
    final cached = _typeCache[type];
    if (cached != null) return cached;
    final json = await _getJson('type/$type');
    final ids = (json['pokemon'] as List).map<int>((e) {
      final url = e['pokemon']['url'] as String;
      final segments = url.split('/').where((s) => s.isNotEmpty).toList();
      return int.parse(segments.last);
    }).where((id) => id <= maxPokemon).toSet();
    _typeCache[type] = ids;
    return ids;
  }
}
