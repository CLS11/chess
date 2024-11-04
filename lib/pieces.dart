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
        for (int dx = -1; dx <= 1; ++dx) {
          for (int dy = -1; dy <= 1; ++dy) {
            if (dx == 0 && dy == 0) {
              continue;
            }
            yield Delta(dx, dy);
          }
        }
        break;
    }
  }
}
