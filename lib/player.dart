import 'package:flutter/material.dart';

class Player {
  const Player(this.name, this.color);
  final String name;
  final Color color;

  @override
  String toString() => 'Player[$name]';
}
