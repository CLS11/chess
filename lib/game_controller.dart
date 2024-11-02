import 'package:chess/agents.dart';
import 'package:chess/board.dart';
import 'package:chess/player.dart';
import 'package:flutter/material.dart';

class GameController {
  GameState gameState = GameState();
  List<Agent> agents = <Agent>[FirstMover(), FirstMover()];
  int currentPlayerIndex = 0;

  Agent activeAgent(GameState gameState) {
    return agents[gameState.currentPlayerIndex];
  }

  GameState takeTurn(GameState gameState) {
    final agent = activeAgent(gameState);
    final view = AgentBoardView(gameState, gameState.activePlayer());
    final move = agent.pickMove(view);
    return gameState.afterMove(move);
  }
}
