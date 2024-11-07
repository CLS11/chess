import 'package:chess/player.dart';
import 'package:chess/positions.dart';

enum PieceType {
  king,
}

class Pieces {
  final PieceType type;
  final Player owner;

  const Pieces(this.type, this.owner);

  Iterable<Delta> get deltas sync* {
    switch (type) {
      case PieceType.king:
        for (int x = -1; x <= 1; ++x) {
          for (int y = -1; y <= 1; ++y) {
            for (int d = 1; d <= kMoveRange; ++d) {
              int dx = d * x;
              int dy = d * y;
              if (dx == 0 && dy == 0) {
                continue;
              }
              yield Delta(dx, dy);
            }
          }
        }

        break;
    }
  }
}
