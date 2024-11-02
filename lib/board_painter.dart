import 'package:chess/board.dart';
import 'package:flutter/material.dart';
import 'package:chess/player.dart';

const int kBoardWidth = 10;
const int kBoardHeight = 10;

class BoardPainter extends CustomPainter {
  BoardPainter(GameState gameState);

  void paintBackground(Canvas canvas, Size size, Size cell) {
    final paint = Paint();
    paint.style = PaintingStyle.fill;
    for (var i = 0; i < kBoardWidth; ++i) {
      for (var j = 0; j < kBoardHeight; ++j) {
        paint.color = ((i + j) % 2 == 0) ? Colors.blueGrey : Colors.grey;
        
        canvas.drawRect(
          Rect.fromLTWH(i * cell.width, j * cell.height, cell.width, cell.height),
          paint,
        );
      }
    }
  }

  void paintPlayers(Canvas canvas, Size size, Size cellSize) {
    final paint = Paint();
    paint.style = PaintingStyle.fill;
    for (var player in boardState.players) {
     var location = player.location;
     paint.color = player.color;
     var offset = Offset((location.x+0.5)*cellSize.width)
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = Size(size.width/kBoardWidth, size.height/kBoardHeight);

    paintBackground(canvas, size);

    paintPlayers(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
