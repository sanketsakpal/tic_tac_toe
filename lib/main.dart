import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TicTacToeGame(title: 'Tic Tac Toe'),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key, required this.title});

  final String title;

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame>
    with TickerProviderStateMixin {
  List<List<String>> board = List.generate(3, (_) => List.filled(3, ''));
  bool xTurn = true;
  String winner = '';

  late List<List<AnimationController>> _controllers;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = List.generate(
      3,
      (i) => List.generate(
        3,
        (j) => AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        ),
      ),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  void makeMove(int row, int col) {
    if (board[row][col].isNotEmpty || winner.isNotEmpty) {
      return;
    }

    setState(() {
      board[row][col] = xTurn ? 'X' : 'O';
      _controllers[row][col].forward();
      xTurn = !xTurn;
      _checkWinner();
    });
  }

  void _resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, ''));
      xTurn = true;
      winner = '';
      for (var row in _controllers) {
        for (var controller in row) {
          controller.reset();
        }
      }
    });
  }

  void _checkWinner() {
    for (int i = 0; i < 3; i++) {
      if (board[i][0].isNotEmpty &&
          board[i][0] == board[i][1] &&
          board[i][0] == board[i][2]) {
        winner = board[i][0];
        return;
      }
    }

    for (int i = 0; i < 3; i++) {
      if (board[0][i].isNotEmpty &&
          board[0][i] == board[1][i] &&
          board[0][i] == board[2][i]) {
        winner = board[0][i];
        return;
      }
    }

    if (board[0][0].isNotEmpty &&
        board[0][0] == board[1][1] &&
        board[0][0] == board[2][2]) {
      winner = board[0][0];
      return;
    }

    if (board[0][2].isNotEmpty &&
        board[0][2] == board[1][1] &&
        board[0][2] == board[2][0]) {
      winner = board[0][2];
      return;
    }
    bool isDraw = true;
    for (var row in board) {
      for (var cell in row) {
        if (cell.isEmpty) {
          isDraw = false;
          break;
        }
      }
    }

    if (isDraw) {
      winner = 'Draw';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            winner.isEmpty
                ? (xTurn ? 'X\'s turn' : 'O\'s turn')
                : winner == 'Draw'
                ? 'It\'s a Draw!'
                : 'Winner: $winner',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final row = index ~/ 3;
                  final col = index % 3;

                  return GestureDetector(
                    onTap: () {
                      makeMove(row, col);
                      _checkWinner();
                      if (winner == 'X' || winner == 'O' && winner != 'Draw') {
                        setState(() {
                          _confettiController.play();
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _controllers[row][col],
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _controllers[row][col].value,
                              child: Text(
                                board[row][col],
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      board[row][col] == 'X'
                                          ? Colors.blue
                                          : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _resetGame();
        },
        tooltip: 'Reset Game',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    for (var row in _controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
