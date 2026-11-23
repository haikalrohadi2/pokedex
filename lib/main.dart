import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'state/favorites_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Baca favorit dari Local Storage sebelum aplikasi tampil.
  await FavoritesController.instance.load();
  runApp(const PokeDexApp());
}

/// Agar daftar yang bisa digeser (misal chip tipe) juga bisa di-drag memakai mouse
/// di Chrome / desktop.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class PokeDexApp extends StatelessWidget {
  const PokeDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeDex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      scrollBehavior: AppScrollBehavior(),
      home: const MainShell(),
    );
  }
}
