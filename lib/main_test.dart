import 'package:flutter/material.dart';

import 'tests/dev_tests.dart';

/// Pintu masuk KHUSUS pengujian Tahap 2 (bukan aplikasi utama).
/// Jalankan dengan:  flutter run -d chrome --web-port=5000 -t lib/main_test.dart
void main() => runApp(const TestApp());

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.red,
      ),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _log = 'Tekan tombol untuk menjalankan pengujian.\nHasil juga muncul di Debug Console.';
  bool _running = false;

  Future<void> _run(Future<String> Function() test) async {
    setState(() {
      _running = true;
      _log = 'Menjalankan...';
    });
    final result = await test();
    if (!mounted) return;
    setState(() {
      _log = result;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PokeDex - Pengujian Tahap 2')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('A. Pengujian API', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _running ? null : () => _run(testApi),
              child: const Text('Tes koneksi PokeAPI'),
            ),
            const SizedBox(height: 20),
            const Text('B. Pengujian Local Storage', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _running ? null : () => _run(testSaveFavorites),
                  child: const Text('1. Simpan'),
                ),
                FilledButton(
                  onPressed: _running ? null : () => _run(testReadFavorites),
                  child: const Text('2. Baca'),
                ),
                FilledButton(
                  onPressed: _running ? null : () => _run(testDeleteFavorites),
                  child: const Text('3. Hapus'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(child: SelectableText(_log)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
