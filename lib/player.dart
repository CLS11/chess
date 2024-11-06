import 'package:chess/pieces.dart';
import 'package:flutter/material.dart';

abstract class Player {
  const Player();
  String get name;
  Color get color;

  void paint(Canvas canvas, Rect rect, PieceType type) {
    final paint = Paint();
    paint.style = PaintingStyle.fill;
    paint.color = color;
    switch (type) {
      case PieceType.king:
        canvas.drawOval(rect, paint);
    }
  }

  @override
  String toString() => 'Player[$name]';
}
