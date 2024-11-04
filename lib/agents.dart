// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:chess/board.dart';
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

  @override
  int get hashCode => hashValues(initialPosition, finalPosition);
}

class AgentView {
  final GameState _gameState;
  final Player _player;

  AgentView(this._gameState, this._player);

  Iterable<Move> get legalMoves => _gameState.board.getLegalMoves(_player);
}


abstract class Agent {
  Move pickMove(AgentView view);
}

class FirstMover implements Agent {
  @override
  Move pickMove(AgentView view) {
    return view.legalMoves.first;
  }
}

class RandomMover implements Agent {
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
