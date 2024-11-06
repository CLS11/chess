import 'dart:math';
import 'dart:ui';

import 'package:chess/agents.dart' as agents;
import 'package:chess/agents.dart';
import 'package:chess/board.dart';
import 'package:chess/pieces.dart';
import 'package:chess/player.dart';
import 'package:chess/positions.dart';
import 'package:flutter/material.dart';

class GameController {
  GameController.withAgents(this._agents);

  factory GameController.withRandomAgents(int numberOfPlayers) {
    var rng = Random();
    return GameController.withAgents(List<Agent>.generate(numberOfPlayers,
        (index) => agents.all[rng.nextInt(agents.all.length)]()));
  }

  final List<Agent> _agents;

  GameController() : _agents = <Agent>[];

  GameState getRandomInitialGameState() {
    var board = Board.empty();

    for (var player in _agents) {
      Positions position;
      do {
        position = Positions.random();
      } while (board.getAt(position) != null);

      board = board.placeAt(position, Pieces(PieceType.king, player));
    }
    return GameState(board, List<Player>.from(_agents), []);
  }

  GameState takeTurn(GameState gameState) {
    var activePlayer = gameState.activePlayer;
    var view = agents.AgentView(gameState, activePlayer);
    var activeAgent = activePlayer as Agent;
    return gameState.move(activeAgent.pickMove(view));
  }
}
