import 'dart:async';

import 'package:chess/board.dart';
import 'package:chess/game_controller.dart';
import 'package:flutter/material.dart';

class BattlePage extends StatefulWidget {
  const BattlePage({super.key});

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  GameState gameState = GameState.empty();
  GameController gameController = GameController();
  final history = GameHistory();
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel;
    super.dispose();
  }

  void _handleTimer(Timer _) {
    nextTurn();

    if (gameState.isDone) {
      history.recordGame(gameState);
      timer?.cancel();
      timer = null;
      _startBattle();
    }
  }

  void _startBattle() {
    setState(() {
      gameController = GameController.withRandomAgents(5);
      gameState = gameController.getRandomInitialGameState();
    });

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
          AspectRatio(
            aspectRatio: 1.0,
            child: BoardView(gameState: gameState),
          ),
          Flexible(
            child: Center(
              child: LeaderBoard(history: history),
            ),
          ),
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

class GameHistory {
  final Map<String, double> wins = <String, double>{};
  int gameCount = 0;

  void recordGame(GameState gameState) {
    var pointsPerPlayer = 1.0 / gameState.players.length;
    for (var player in gameState.players) {
      var name = player.name;
      wins[name] = (wins[name] ?? 0.0) + pointsPerPlayer;
      gameCount += 1;
    }
  }
}
