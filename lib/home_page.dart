import 'dart:async';
import 'dart:math';

import 'package:chess/board.dart';
import 'package:chess/game_controller.dart';
import 'package:chess/player.dart';
import 'package:flutter/material.dart';

const int kNumberOfPlayers = 5;
const Duration kGameTickDuration = Duration(milliseconds: 1);

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
    timer?.cancel(); // Fix: add parentheses to cancel the timer correctly
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
      gameController = GameController.withRandomAgents(kNumberOfPlayers);
      gameState = gameController.getRandomInitialGameState();
    });

    timer = Timer.periodic(kGameTickDuration, _handleTimer);
  }

  void _stopBattle() {
    setState(() {
      timer?.cancel();
      timer = null;
    });
  }

  void nextTurn() {
    setState(() {
      gameState =
          gameController.takeTurn(gameState); // Remove nullable safety operator
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

const double kValue = 16.0;
const double initialRating = 500.0;

class GameHistory {
  final Map<String, double> wins = <String, double>{};
  int gameCount = 0;

  final Map<String, double> rating = <String, double>{};
  final Map<String, Color> colors = <String, Color>{};

  double expectedScore(double currentRating, double opponentRating) {
    var exponent = (opponentRating - currentRating) / 400.0;
    return 1.0 / (1.0 + pow(10.0, exponent));
  }

  double pointsToTransfer(double score, double expectedScore) {
    return kValue * (score - expectedScore);
  }

  double currentRatingForName(String name) {
    return rating[name] ?? initialRating;
  }

  double currentRating(Player player) => currentRatingForName(player.name);

  void adjustRating(Player player, double delta) {
    rating[player.name] = currentRating(player) + delta;
  }

  void updateRating(Player winner, Player loser, double score) {
    var winnerRating = currentRating(winner);
    var loserRating = currentRating(loser);
    var stake =
        pointsToTransfer(score, expectedScore(winnerRating, loserRating));
    adjustRating(winner, stake);
    adjustRating(loser, -stake);
  }

  void recordGame(GameState gameState) {
    var pointsPerPlayer = 1.0 / gameState.players.length;
    for (var player in gameState.players) {
      var name = player.name;
      wins[name] = (wins[name] ?? 0.0) + pointsPerPlayer;
      colors[name] = player.color;
      gameCount += 1;
    }

    var haveSeen = <Type, bool>{};

    bool checkPlayer(p) {
      var didSeeBefore = haveSeen[p.runtimeType] ?? false;
      haveSeen[p.runtimeType] = true;
      return !didSeeBefore;
    }

    var alivePlayers = gameState.players.where(checkPlayer).toList();
    var deadPlayers = gameState.deadPlayers.where(checkPlayer).toList();
    recordRatings(alivePlayers, deadPlayers);
  }

  void recordRatings(List<Player> alivePlayers, List<Player> deadPlayers) {
    for (var i = 0; i < deadPlayers.length - 1; i++) {
      var winner = deadPlayers[i + 1];
      var loser = deadPlayers[i];
      updateRating(winner, loser, 1.0);
    }

    alivePlayers.shuffle();
    if (deadPlayers.isNotEmpty) {
      updateRating(alivePlayers.first, deadPlayers.last, 1.0);
    }
    for (var i = 0; i < alivePlayers.length; i++) {
      for (var j = i + 1; j < alivePlayers.length; j++) {
        updateRating(alivePlayers[i], alivePlayers[j], 0.5);
      }
    }
  }
}
