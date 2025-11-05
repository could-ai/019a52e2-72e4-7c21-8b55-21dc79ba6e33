import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;

class ChessboardScreen extends StatefulWidget {
  const ChessboardScreen({super.key});

  @override
  State<ChessboardScreen> createState() => _ChessboardScreenState();
}

class _ChessboardScreenState extends State<ChessboardScreen> {
  late chess.Chess _game;
  String? _selectedSquare;
  List<String> _possibleMoves = [];

  @override
  void initState() {
    super.initState();
    _game = chess.Chess();
  }

  void _onSquareTap(String squareName) {
    setState(() {
      if (_game.game_over) {
        _showGameOverDialog();
        return;
      }

      if (_selectedSquare == null) {
        final piece = _game.get(squareName);
        if (piece != null && piece.color == _game.turn) {
          _selectedSquare = squareName;
          _possibleMoves = _game.moves({'square': squareName, 'verbose': true}).map((move) => move['to'].toString()).toList();
        }
      } else {
        if (_possibleMoves.contains(squareName)) {
          _game.move({'from': _selectedSquare!, 'to': squareName});
          if (_game.game_over) {
            _showGameOverDialog();
          }
        }
        _selectedSquare = null;
        _possibleMoves = [];
      }
    });
  }

  void _showGameOverDialog() {
    String status;
    if (_game.in_checkmate) {
      status = 'Checkmate! ${_game.turn == chess.Color.WHITE ? "Black" : "White"} wins.';
    } else if (_game.in_draw) {
      status = 'Draw!';
    } else if (_game.in_stalemate) {
      status = 'Stalemate!';
    } else if (_game.in_threefold_repetition) {
      status = 'Draw by threefold repetition!';
    } else {
      status = 'Game Over';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(status),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                setState(() {
                  _game.reset();
                  _selectedSquare = null;
                  _possibleMoves = [];
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess vs Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _game.reset();
                _selectedSquare = null;
                _possibleMoves = [];
              });
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _game.game_over ? 'Game Over' : "${_game.turn == chess.Color.WHITE ? "White's" : "Black's"} Turn",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemBuilder: (context, index) {
                  final row = index ~/ 8;
                  final col = index % 8;
                  final squareName =
                      '${String.fromCharCode('a'.codeUnitAt(0) + col)}${8 - row}';
                  final piece = _game.get(squareName);

                  final isLightSquare = (row + col) % 2 == 0;
                  final isSelected = _selectedSquare == squareName;
                  final isPossibleMove = _possibleMoves.contains(squareName);

                  return GestureDetector(
                    onTap: () => _onSquareTap(squareName),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green[400] : (isLightSquare ? Colors.brown[200] : Colors.brown[600]),
                        border: isPossibleMove ? Border.all(color: Colors.yellow, width: 3) : null,
                      ),
                      child: Center(
                        child: Text(
                          _getPieceUnicode(piece),
                          style: TextStyle(
                            fontSize: 36,
                            color: piece?.color == chess.Color.WHITE
                                ? Colors.white70
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: 64,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPieceUnicode(chess.Piece? piece) {
    if (piece == null) {
      return '';
    }
    switch (piece.type) {
      case chess.PieceType.PAWN:
        return piece.color == chess.Color.WHITE ? '♙' : '♟';
      case chess.PieceType.ROOK:
        return piece.color == chess.Color.WHITE ? '♖' : '♜';
      case chess.PieceType.KNIGHT:
        return piece.color == chess.Color.WHITE ? '♘' : '♞';
      case chess.PieceType.BISHOP:
        return piece.color == chess.Color.WHITE ? '♗' : '♝';
      case chess.PieceType.QUEEN:
        return piece.color == chess.Color.WHITE ? '♕' : '♛';
      case chess.PieceType.KING:
        return piece.color == chess.Color.WHITE ? '♔' : '♚';
      default:
        return '';
    }
  }
}
