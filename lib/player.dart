import 'package:flutter/material.dart';
import 'package:chess/positions.dart';

class Player {
  Player({required this.position, required this.color});
  Positions position;
  final Color color;
}
