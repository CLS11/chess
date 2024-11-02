import 'package:chess/agents.dart';
import 'package:flutter/material.dart';
import 'package:chess/positions.dart';

class Player {
  Player({required this.position, required this.color});
  Positions position;
  final Color color;

  Player move(Move move) {
    return Player(
      position: Positions(position.x + move.dx, position.y + move.dy),
      color: color,
    );
  }
}
