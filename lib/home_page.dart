import 'dart:async';

import 'package:chess/board.dart';
import 'package:chess/game_controller.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GameState? gameState;
  GameController gameController = GameController.demo();
  final Map<String, int> wins = <String, int>{};
  Timer? timer;

  @override
  void initState() {
    super.initState();
    gameState = gameController.getRandomInitialGameState();
  }

  @override
  void dispose() {
    timer?.cancel;
    super.dispose();
  }

  void _handleTimer(Timer _) {
    nextTurn();

    if (gameState?.isDone ?? false) {
      var name = gameState?.winner?.name ?? "[Draw]";
      wins[name] = (wins[name] ?? 0) + 1;
      timer?.cancel();
      timer = null;
      _startBattle();
    }
  }

  void _startBattle() {
    gameState = gameController.getRandomInitialGameState();
    timer = Timer.periodic(const Duration(milliseconds: 1), _handleTimer);
  }

  void _stopBattle() {
    setState(() {
      timer?.cancel();
      timer = null;
    });
  }

  void nextTurn() {
    setState(() {
      gameState = gameController.takeTurn(gameState!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: BoardView(gameState: gameState!),
            ),
          ),
          LeaderBoard(wins: wins),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: timer == null ? _startBattle : _stopBattle,
        child: timer == null
            ? const Icon(Icons.play_arrow)
            : const Icon(Icons.stop),
      ),
    );
  }
}
