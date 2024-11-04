import 'package:chess/agents.dart';
import 'package:chess/board_painter.dart';
import 'package:chess/pieces.dart';
import 'package:chess/player.dart';
import 'package:chess/positions.dart';
import 'package:flutter/material.dart';

class GameState {
  final Board board;
  final List<Player> players;

  Player get activePlayer => players.first;
  GameState(this.board, this.players);

  GameState move(Move move) {
    var newBoard = board.move(activePlayer, move);
    var newPlayers = <Player>[];
    for (var i = 1; i < players.length; ++i) {
      var player = players[i];
      if (newBoard.isAlive(player)) {
        newPlayers.add(player);
      }
    }
    newPlayers.add(activePlayer);
    return GameState(newBoard, newPlayers);
  }

  Player? get winner {
    if (players.length != 1) {
      return null;
    }
    return activePlayer;
  }
}

class BoardView extends StatelessWidget {
  const BoardView({Key? key, required this.gameState}) : super(key: key);

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    var winner = gameState.winner;
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: BoardPainter(gameState)),
        if (winner != null)
          Container(
            color: Colors.white,
            child: Text('A winner is ${winner.name}'),
          ),
      ],
    );
  }
}

class Board {
  static const int kBoardWidth = 10;
  static const int kBoardHeight = 10;

  static bool inBounds(Positions position) {
    return position.x >= 0 &&
        position.x < kBoardWidth &&
        position.y >= 0 &&
        position.y < kBoardHeight;
  }

  final Map<Positions, Pieces> _pieces;

  Board.empty() : _pieces = <Positions, Pieces>{};
  Board._(this._pieces);

  void forEachPiece(void Function(Positions position, Pieces piece) callback) {
    _pieces.forEach(callback);
  }

  Board placeAt(Positions position, Pieces piece) {
    return Board._(<Positions, Pieces>{position: piece, ..._pieces});
  }

  Pieces? getAt(Positions position) {
    return _pieces[position];
  }

  Board move(Player player, Move move) {
    var piece = getAt(move.initialPosition as Positions);
    if (piece == null) {
      throw IllegalMove('No piece at ${move.initialPosition}');
    }
    if (piece.owner != player) {
      throw IllegalMove(
          'Piece at ${move.initialPosition} not owned by ${player}');
    }
    if (!inBounds(move.finalPosition as Positions)) {
      throw IllegalMove(
          'Final position ${move.finalPosition} is out of bounds');
    }

    if (piece.owner == getAt(move.finalPosition as Positions)?.owner) {
      throw IllegalMove(
          'Pieces at ${move.initialPosition} and ${move.finalPosition} have the same owner');
    }
    var newPieces = <Positions, Pieces>{..._pieces};
    newPieces.remove(move.initialPosition as Positions);
    newPieces[move.finalPosition as Positions] = piece;
    return Board._(newPieces);
  }

  bool isLegalMove(Player player, Move move) {
    var piece = getAt(move.initialPosition as Positions);
    return piece != null &&
        piece.owner == player &&
        _canMovePieceTo(piece, move.finalPosition as Positions);
  }

  bool _canMovePieceTo(Pieces piece, Positions position) {
    return inBounds(position) && piece.owner != getAt(position)?.owner;
  }

  Iterable<Move> getLegalMoves(Player player) sync* {
    for (var position in _pieces.keys) {
      var piece = getAt(position);
      if (piece == null || piece.owner != player) {
        continue;
      }
      for (var delta in piece.deltas) {
        var move = position.move(delta);
        if (_canMovePieceTo(piece, move.finalPosition as Positions)) {
          assert(isLegalMove(player, move));
          yield move;
        }
      }
    }
  }

  bool hasPieceofType(Player player, PieceType type) {
    for (var piece in _pieces.values) {
      if (piece.owner == player && piece.type == type) {
        return true;
      }
    }
    return false;
  }

  bool isAlive(Player player) => hasPieceofType(player, PieceType.king);
}
