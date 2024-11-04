import 'package:chess/agents.dart';
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
  GameController gameController = GameController.random(2);

  @override
  void initState() {
    super.initState();
    gameState = gameController.getRandomInitialGameState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: BoardView(gameState: gameState!),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            gameState = gameController.takeTurn(gameState!);
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.navigation),
      ),
    );
  }
}
