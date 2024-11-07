// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:chess/board.dart';
import 'package:chess/pieces.dart';
import 'package:chess/player.dart';
import 'package:chess/positions.dart';
import 'package:flutter/material.dart';

typedef AgentFactory = Agent Function();

List<AgentFactory> all = <AgentFactory>[
  FirstMover.new,
  RandomMover.new,
  Fixate.new,
  Seeker.new,
  CautiousSeeker.new,
  Runner.new,
  Opportunist.new,
];

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

  Delta get delta => initialPosition.deltaTo(finalPosition);

  @override
  int get hashCode => hashValues(initialPosition, finalPosition);
}

class AgentView {
  AgentView(this._gameState, this._player);
  final GameState _gameState;
  final Player _player;

  List<Positions> _getPositions(bool Function(Pieces piece) predicate) {
    List<Positions> positions = <Positions>[];
    _gameState.board.forEachPiece((position, piece) {
      if (predicate(piece)) {
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

  List<Positions> getPositions(PieceType type) {
    return _getPositions(
        (piece) => piece.owner == _player && piece.type == type);
  }

  List<Positions> enemyPositions(PieceType type) {
    return _getPositions(
        (piece) => piece.owner != _player && piece.type == type);
  }

  Iterable<Move> get legalMoves => _gameState.board.getLegalMoves(_player);
}

abstract class Agent extends Player {
  const Agent();

  Move pickMove(AgentView view);
}

Move findMoveByDistanceToTarget(AgentView view, Positions targetPosition,
    bool Function(double currentDistance, double bestDistance) isBetter) {
  Move? bestMove;
  double? bestDistance;
  for (var move in view.legalMoves) {
    var currentDistance = move.finalPosition.deltaTo(targetPosition).magnitude;
    if (bestDistance == null || isBetter(currentDistance, bestDistance)) {
      bestDistance = currentDistance;
      bestMove = move;
    }
  }
  return bestMove!;
}

class CautiousSeeker extends Agent {
  int? previousValue;
  int? element;
  @override
  String get name => 'CautiousSeeker';
  @override
  Color get color => Colors.cyanAccent;

  int _distanceToNearestPiece(Move move, List<Positions> pieces) {
    assert(pieces.isNotEmpty);
    return pieces
        .map((e) => e.deltaTo(move.finalPosition).walkingDistance)
        .fold(
          null,
          (int? previousValue, element) =>
              (previousValue == null || element! < previousValue)
                  ? element
                  : previousValue,
        )!;
  }

  @override
  Move pickMove(AgentView view) {
    final otherKings = view.getPositions(PieceType.king);
    final safeMoves = view.legalMoves
        .where((move) => !otherKings
            .map((e) => e.deltaTo(move.finalPosition).walkingDistance)
            .contains(1))
        .toList();

    if (safeMoves.isEmpty) {
      return _findRandomMove(view.legalMoves);
    }

    Move? bestMove;
    int? bestDistance;
    for (final move in safeMoves) {
      final distance = _distanceToNearestPiece(move, otherKings);
      if (bestDistance == null || distance < bestDistance) {
        bestDistance = distance;
        bestMove = move;
      }
    }
    return bestMove!;
  }
}

class Seeker extends Agent {
  Delta? target;

  @override
  String get name => 'Seeker';

  @override
  Color get color => Colors.blue;

  @override
  Move pickMove(AgentView view) {
    var initialPosition = view.getPositions(PieceType.king).first;
    var targetPosition = view.closestOpponent(initialPosition, PieceType.king);
    if (targetPosition == null) {
      target = null;
      return _findRandomMove(view.legalMoves);
    }
    final move = findMoveByDistanceToTarget(view, targetPosition,
        (double currentDistance, double bestDistance) {
      return currentDistance < bestDistance;
    });
    target = move.finalPosition.deltaTo(targetPosition);
    return move;
  }
}

class Runner extends Agent {
  @override
  String get name => 'Runner';

  @override
  Color get color => Colors.white;

  @override
  Move pickMove(AgentView view) {
    var initialPosition = view.getPositions(PieceType.king).first;
    var targetPosition = view.closestOpponent(initialPosition, PieceType.king);
    if (targetPosition == null) {
      return _findRandomMove(view.legalMoves);
    }
    return findMoveByDistanceToTarget(view, targetPosition,
        (double currentDistance, double bestDistance) {
      return currentDistance > bestDistance;
    });
  }
}

class Opportunist extends Agent {
  @override
  String get name => 'Opportunist';

  @override
  Color get color => Colors.black;

  @override
  Move pickMove(AgentView view) {
    var initialPosition = view.getPositions(PieceType.king).first;
    var targetPosition = view.closestOpponent(initialPosition, PieceType.king);
    if (targetPosition == null) {
      return _findRandomMove(view.legalMoves);
    }
    for (var move in view.legalMoves) {
      if (move.finalPosition == targetPosition) {
        return move;
      }
    }
    return findMoveByDistanceToTarget(view, targetPosition,
        (double currentDistance, double bestDistance) {
      return currentDistance > bestDistance;
    });
  }
}

class IllegalMove {
  final String reason;
  const IllegalMove(this.reason);
}

class FirstMover extends Agent {
  @override
  String get name => 'FirstMover';

  @override
  Color get color => Colors.teal;

  @override
  Move pickMove(AgentView view) {
    return view.legalMoves.first;
  }
}

Move _findRandomMove(Iterable<Move> legalMoves) {
  var rng = Random();
  var choices = legalMoves.toList();
  return choices[rng.nextInt(choices.length)];
}

class RandomMover extends Agent {
  @override
  String get name => 'RandomMover';

  @override
  Color get color => Colors.lime;

  @override
  Move pickMove(AgentView view) {
    return _findRandomMove(view.legalMoves);
  }
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
  String get name => 'Fixate';

  @override
  Color get color => Colors.brown;

  @override
  Move pickMove(AgentView view) {
    var legalMoves = view.legalMoves.toList();
    final move = getMatchingFavorite(legalMoves) ?? _findRandomMove(legalMoves);
    favorite = move.delta;
    return move;
  }
}
