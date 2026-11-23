import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Fungsi pengujian Tahap 2. Hasilnya dicetak ke Debug Console
/// dan juga dikembalikan sebagai teks agar bisa ditampilkan di layar.

Future<String> testApi() async {
  final log = StringBuffer();
  void out(String m) {
    log.writeln(m);
    debugPrint(m);
  }

  out('=== TES API ===');
  try {
    // 1) Daftar Pokémon
    final listRes = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=10'));
    if (listRes.statusCode == 200) {
      final data = jsonDecode(listRes.body) as Map<String, dynamic>;
      final results = data['results'] as List;
      out('✅ Daftar Pokémon BERHASIL (status 200). Jumlah data: ${results.length}');
      out('   Pokémon pertama: ${results.first['name']}');
    } else {
      out('❌ Daftar Pokémon GAGAL. Status code: ${listRes.statusCode}');
    }

    // 2) Detail Pikachu
    final detailRes = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/pikachu'));
    if (detailRes.statusCode == 200) {
      final data = jsonDecode(detailRes.body) as Map<String, dynamic>;
      out('✅ Detail Pikachu BERHASIL (status 200).');
      out('   Nama: ${data['name']} | ID: ${data['id']}');
      final types = (data['types'] as List).map((t) => t['type']['name']).join(', ');
      out('   Tipe: $types');
    } else {
      out('❌ Detail Pikachu GAGAL. Status code: ${detailRes.statusCode}');
    }
  } catch (e) {
    out('❌ ERROR koneksi/exception: $e');
  }
  return log.toString();
}

const String _testKey = 'test_favorites';

Future<String> testSaveFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  final data = [
    {'id': 25, 'name': 'pikachu'},
    {'id': 1, 'name': 'bulbasaur'},
  ];
  await prefs.setString(_testKey, jsonEncode(data));
  const msg = '✅ SIMPAN: Pikachu (#25) dan Bulbasaur (#1) tersimpan.';
  debugPrint(msg);
  return msg;
}

Future<String> testReadFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_testKey);
  if (raw == null) {
    const msg = '⚠️ BACA: tidak ada data favorit tersimpan.';
    debugPrint(msg);
    return msg;
  }
  final list = jsonDecode(raw) as List;
  final names = list.map((e) => '${e['name']} (#${e['id']})').join(', ');
  final msg = '✅ BACA: ${list.length} data ditemukan -> $names';
  debugPrint(msg);
  return msg;
}

Future<String> testDeleteFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_testKey);
  final stillThere = prefs.containsKey(_testKey);
  final msg = stillThere ? '❌ HAPUS gagal.' : '✅ HAPUS: data favorit berhasil dihapus.';
  debugPrint(msg);
  return msg;
}
