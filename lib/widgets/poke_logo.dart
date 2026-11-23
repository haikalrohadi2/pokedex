import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Logo PokeDex: Pokéball sederhana yang digambar dengan kode (tanpa file aset).
class PokeLogo extends StatelessWidget {
  final double size;
  const PokeLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PokeBallPainter()),
    );
  }
}

class _PokeBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    final paint = Paint()..isAntiAlias = true;

    paint.color = AppColors.primary;
    canvas.drawArc(rect, math.pi, math.pi, true, paint);
    paint.color = Colors.white;
    canvas.drawArc(rect, 0, math.pi, true, paint);

    const dark = Color(0xFF111111);
    paint.color = dark;
    canvas.drawRect(Rect.fromLTWH(0, c.dy - r * 0.09, size.width, r * 0.18), paint);
    canvas.drawCircle(c, r * 0.3, paint);
    paint.color = Colors.white;
    canvas.drawCircle(c, r * 0.16, paint);

    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.09
      ..color = dark;
    canvas.drawCircle(c, r - r * 0.045, outline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
