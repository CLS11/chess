import 'dart:ui';

import 'package:chess/agents.dart' as agents;
import 'package:chess/board.dart';
import 'package:chess/pieces.dart';
import 'package:chess/player.dart';
import 'package:chess/positions.dart';
import 'package:flutter/material.dart';

class GameController {
  factory GameController.demo() {
    var controller = GameController();
    controller.addPlayerWithAgent(
      const Player('Random', Colors.black),
      agents.RandomMover(),
    );
    controller.addPlayerWithAgent(
      const Player('Seeker', Colors.blue),
      agents.Seeker(),
    );
    controller.addPlayerWithAgent(
      const Player('Runner 1', Colors.white),
      agents.Runner(),
    );
    controller.addPlayerWithAgent(
      const Player('Runner 2', Colors.white),
      agents.Runner(),
    );
    controller.addPlayerWithAgent(
      const Player('Runner 3', Colors.white),
      agents.Runner(),
    );
    controller.addPlayerWithAgent(
      const Player('Runner 4', Colors.white),
      agents.Runner(),
    );
    controller.addPlayerWithAgent(
      const Player('Runner 5', Colors.white),
      agents.Runner(),
    );
    controller.addPlayerWithAgent(
      const Player('Runner 6', Colors.white),
      agents.Runner(),
    );
    controller.addPlayerWithAgent(
      const Player('Runner 7', Colors.white),
      agents.Runner(),
    );
    return controller;
  }
  final Map<Player, agents.Agent> _agents = <Player, agents.Agent>{};

  GameController();

  void addPlayerWithAgent(Player player, agents.Agent agent) {
    _agents[player] = agent;
  }

  GameState getRandomInitialGameState() {
    var board = Board.empty();
    var players = _agents.keys.toList();
    for (var player in players) {
      Positions position;
      do {
        position = Positions.random();
      } while (board.getAt(position) != null);

      board = board.placeAt(position, Pieces(PieceType.king, player));
    }
    return GameState(board, players);
  }

  GameState takeTurn(GameState gameState) {
    var activePlayer = gameState.activePlayer;
    var view = agents.AgentView(gameState, activePlayer);
    var activeAgent = _agents[activePlayer]!;
    return gameState.move(activeAgent.pickMove(view));
  }
}
