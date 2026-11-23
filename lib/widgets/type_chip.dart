import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Label kecil berwarna untuk menampilkan tipe Pokémon.
class TypeChip extends StatelessWidget {
  final String type;
  final bool large;
  const TypeChip({super.key, required this.type, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 8,
        vertical: large ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: Color.lerp(TypeColors.of(type), Colors.black, 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        prettyName(type),
        style: TextStyle(
          color: Colors.white,
          fontSize: large ? 13 : 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
