// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:chess/board.dart';
import 'package:chess/pieces.dart';
import 'package:chess/player.dart';
import 'package:chess/positions.dart';
import 'package:flutter/material.dart';

class Move {
  const Move(this.initialPosition, this.finalPosition);
  final Positions initialPosition;
  final Positions finalPosition;

  @override
  String toString() => '[$initialPosition -> $finalPosition]';

  @override
  bool operator ==(other) {
    if (other is! Move) {
      return false;
    }
    return initialPosition == other.initialPosition &&
        finalPosition == other.finalPosition;
  }

  Delta get delta => finalPosition.deltaTo(initialPosition);

  @override
  int get hashCode => hashValues(initialPosition, finalPosition);
}

class AgentView {
  AgentView(this._gameState, this._player);
  final GameState _gameState;
  final Player _player;

  Iterable<Positions> getPositions(PieceType type) {
    List<Positions> positions = <Positions>[];
    _gameState.board.forEachPiece((position, piece) {
      if (piece.owner == _player && piece.type == type) {
        positions.add(position);
      }
    });
    return positions;
  }

  Positions? closestOpponent(Positions position, PieceType type) {
    Positions? bestPosition;
    double bestDistance = double.infinity;
    _gameState.board.forEachPiece((currentPosition, piece) {
      if (piece.owner == _player || piece.type != type) {
        return;
      }
      var currentDistance = position.deltaTo(currentPosition).magnitude;
      if (currentDistance < bestDistance) {
        bestDistance = currentDistance;
        bestPosition = currentPosition;
      }
    });
    return bestPosition;
  }

  Iterable<Move> get legalMoves => _gameState.board.getLegalMoves(_player);
}

abstract class Agent {
  const Agent();
  Move pickMove(AgentView view);
}

abstract class DistanceEvaluatorAgent extends Agent {
  bool isBetter(double currentDistance, double bestDistance);

  @override
  Move pickMove(AgentView view) {
    var myKing = view.getPositions(PieceType.king).first;
    var targetPosition = view.closestOpponent(myKing, PieceType.king);
    if (targetPosition == null) {
      return view.legalMoves.first;
    }

    Move? bestMove;
    double? bestDistance;

    for (var move in view.legalMoves) {
      var currentDistance =
          move.finalPosition.deltaTo(targetPosition).magnitude;
      if (bestDistance == null || isBetter(currentDistance, bestDistance)) {
        bestDistance = currentDistance;
        bestMove = move;
      }
    }
    return bestMove!;
  }
}

class Seeker extends DistanceEvaluatorAgent {
  @override
  bool isBetter(double currentDistance, double bestDistance) {
    return currentDistance < bestDistance;
  }
}

class Runner extends DistanceEvaluatorAgent {
  @override
  bool isBetter(double currentDistance, double bestDistance) {
    return currentDistance > bestDistance;
  }
}

class FirstMover extends Agent {
  @override
  Move pickMove(AgentView view) {
    return view.legalMoves.first;
  }
}

class RandomMover extends Agent {
  @override
  Move pickMove(AgentView view) {
    var rng = Random();
    final choices = view.legalMoves.toList();
    return choices[rng.nextInt(choices.length)];
  }
}

class IllegalMove {
  final String reason;
  const IllegalMove(this.reason);
}

class Fixate extends Agent {
  Delta? favorite;

  Move? getMatchingFavorite(List<Move> legalMoves) {
    var favorite = this.favorite;
    if (favorite != null) {
      for (var move in legalMoves) {
        if (move.delta == favorite) {
          return move;
        }
      }
    }
    return null;
  }

  @override
  Move pickMove(AgentView view) {
    var legalMoves = view.legalMoves.toList();
    var move = getMatchingFavorite(legalMoves) ?? getRandom(legalMoves);
    favorite = move.delta;
    return move;
  }
}
