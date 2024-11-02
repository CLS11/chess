import 'package:chess/agents.dart';
import 'package:chess/board_painter.dart';
import 'package:chess/player.dart';
import 'package:chess/positions.dart';
import 'package:flutter/material.dart';

class GameState {
  GameState()
      : players = <Player>[
          Player(
            position: Positions(0, 0),
            color: Colors.black,
          ),
          Player(
            position: Positions(kBoardWidth - 1, kBoardHeight - 1),
            color: Colors.white,
          ),
        ];
  final List<Player> players;
  int currentPlayerIndex = 0;
  int nextPlayerIndex() {
    return (currentPlayerIndex + 1) % players.length;
  }

  Player activePlayer() {
    return players[currentPlayerIndex];
  }

  GameState._(this.players, this.currentPlayerIndex);

  GameState afterMove(Move move) {
    var nextPlayers = List<Player>.from(players);
    players[currentPlayerIndex] = activePlayer().move(move);
    return GameState._(nextPlayers, nextPlayerIndex());
  }
}

class Board extends StatelessWidget {
  const Board({required this.gameState, super.key});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: BoardPainter(gameState));
  }
}
