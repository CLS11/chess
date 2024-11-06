import 'package:chess/board.dart';
import 'package:chess/pieces.dart';
import 'package:chess/positions.dart';
import 'package:flutter/material.dart';

const int kBoardWidth = 10;
const int kBoardHeight = 10;

class BoardPainter extends CustomPainter {
  BoardPainter(this.gameState);
  final GameState gameState;

  void paintBackground(Canvas canvas, Size size, Size cell) {
    final paint = Paint();
    paint.style = PaintingStyle.fill;
    for (var i = 0; i < kBoardWidth; ++i) {
      for (var j = 0; j < kBoardHeight; ++j) {
        paint.color = ((i + j) % 2 == 0) ? Colors.blueGrey : Colors.grey;

        canvas.drawRect(rectForPosition(Positions(i, j), cell), paint);
      }
    }
  }

  Rect rectForPosition(Positions position, Size cell) {
    return Rect.fromLTWH(position.x * cell.width, position.y * cell.height,
        cell.width, cell.height);
  }

  void paintPieces(Canvas canvas, Size size, Size cell) {
    gameState.board.forEachPiece(
      (position, piece) {
        piece.owner.paint(canvas, rectForPosition(position, cell), piece.type);
      },
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = Size(size.width / kBoardWidth, size.height / kBoardHeight);

    paintBackground(canvas, size, cellSize);

    paintPieces(canvas, size, cellSize);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
