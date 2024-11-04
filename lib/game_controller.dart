import 'dart:ui';

import 'package:chess/agents.dart' as agents;
import 'package:chess/board.dart';
import 'package:chess/pieces.dart';
import 'package:chess/player.dart';
import 'package:chess/positions.dart';
import 'package:flutter/material.dart';

const List<Color> kPlayerColors = <Color>[Colors.black, Colors.white];
const List<String> kPlayerNames = <String>["Kenny", "Bae"];

class GameController {
  factory GameController.random(int playerCount) {
    var controller = GameController();
    for (var i = 0; i < playerCount; ++i) {
      var player = Player(kPlayerNames[i], kPlayerColors[i]);
      controller.addPlayerWithAgent(player, agents.RandomMover());
    }
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
