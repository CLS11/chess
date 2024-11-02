import 'package:chess/board_painter.dart';
import 'package:chess/player.dart';
import 'package:chess/positions.dart';
import 'package:flutter/material.dart';

class GameState {
  final List<Player> players;
  GameState()
      : players = <Player>[
          Player(position: Positions(0, 0), color: Colors.deepPurple),
          Player(
            position: Positions(kBoardWidth - 1, kBoardHeight - 1),
            color: const Color.fromARGB(255, 140, 123, 189),
          ),
        ];
}

class Board extends StatelessWidget {
  const Board({required this.gameState, super.key});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: BoardPainter(gameState));
  }
}
