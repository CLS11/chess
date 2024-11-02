import 'package:chess/board.dart';
import 'package:chess/board_painter.dart';
import 'package:chess/player.dart';
import 'package:chess/positions.dart';

class Move {
  Move(this.dx, this.dy);
  final int dx;
  final int dy;
}

class AgentBoardView {
  AgentBoardView(this._gameState, this._player);
  final GameState _gameState;
  final Player _player;
  bool isValidPosition(Positions position) {
    return position.x >= 0 &&
        position.x < kBoardWidth &&
        position.y >= 0 &&
        position.y < kBoardHeight;
  }

  bool isValidMove(Move move) {
    final player = _player.move(move);
    return isValidPosition(player.position);
  }

  Iterable<Move> get validMoves sync* {
    for (var dx = -1; dx <= -1; ++dx) {
      for (var dy = -1; dy <= -1; ++dy) {
        if (dx == 0 && dy == 0) {
          continue;
        }
        final move = Move(dx, dy);
        if (isValidMove(move)) {
          yield Move(dx, dy);
        }
      }
    }
  }
}

abstract class Agent {
  Move pickMove(AgentBoardView view);
}

class FirstMover implements Agent {
  @override
  Move pickMove(AgentBoardView view) {
    return view.validMoves.first;
  }
}
