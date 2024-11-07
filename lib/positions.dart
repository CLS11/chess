// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:chess/agents.dart';
import 'package:chess/board.dart';
import 'package:flutter/material.dart';

class Delta {
  final int dx;
  final int dy;

  const Delta(this.dx, this.dy);

  @override
  String toString() => '<Δ$dx, Δ$dy>';

  double get magnitude => sqrt(dx * dx + dy * dy);
  int get walkingDistance => max(dx.abs(), dy.abs());

  @override
  bool operator ==(other) {
    if (other is! Delta) {
      return false;
    }
    return dx == other.dx && dy == other.dy;
  }

  @override
  int get hashCode {
    return hashValues(dx, dy);
  }
}

class Positions {
  const Positions(this.x, this.y);
  final int x;
  final int y;

  factory Positions.random() {
    var rng = Random();
    return Positions(
        rng.nextInt(Board.kBoardWidth), rng.nextInt(Board.kBoardHeight));
  }

  Positions apply(Delta delta) => Positions(x + delta.dx, y + delta.dy);
  Move move(Delta delta) => Move(this, apply(delta));

  Delta deltaTo(Positions other) {
    return Delta(other.x - x, other.y - y);
  }

  @override
  String toString() => '($x, $y)';

  @override
  bool operator ==(other) {
    if (other is! Positions) {
      return false;
    }
    return x == other.x && y == other.y;
  }
}
