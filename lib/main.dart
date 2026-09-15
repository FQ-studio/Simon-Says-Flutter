import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const SimonSaysApp());
}

class SimonSaysApp extends StatelessWidget {
  const SimonSaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simon Says',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SimonSaysGame(),
    );
  }
}

class SimonSaysGame extends StatefulWidget {
  const SimonSaysGame({super.key});

  @override
  State<SimonSaysGame> createState() => _SimonSaysGameState();
}

class _SimonSaysGameState extends State<SimonSaysGame> {
  final Random _random = Random();

  final List<Color> _colors = <Color>[
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
  ];

  final List<int> _sequence = <int>[];

  int _playerIndex = 0;
  int _level = 0;
  int _highScore = 0;
  int? _litButton;
  bool _isShowingSequence = false;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  Future<void> _startGame() async {
    if (!mounted) return;

    setState(() {
      _sequence.clear();
      _level = 0;
      _playerIndex = 0;
      _litButton = null;
      _isShowingSequence = false;
      _gameStarted = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await _nextRound();
  }

  Future<void> _nextRound() async {
    if (!mounted) return;

    setState(() {
      _level++;
      _playerIndex = 0;
      _sequence.add(_random.nextInt(4));
      _isShowingSequence = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    for (final int colorIndex in _sequence) {
      if (!mounted) return;

      setState(() {
        _litButton = colorIndex;
      });

      await Future.delayed(const Duration(milliseconds: 550));

      if (!mounted) return;
      setState(() {
        _litButton = null;
      });

      await Future.delayed(const Duration(milliseconds: 180));
    }

    if (!mounted) return;
    setState(() {
      _isShowingSequence = false;
    });
  }

  void _handleButtonPress(int index) {
    if (!_gameStarted || _isShowingSequence || _sequence.isEmpty) return;

    setState(() {
      _litButton = index;
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() {
        _litButton = null;
      });
    });

    if (index != _sequence[_playerIndex]) {
      _gameOver();
      return;
    }

    _playerIndex++;

    if (_playerIndex >= _sequence.length) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted || !_gameStarted) return;
        _nextRound();
      });
    }
  }

  void _gameOver() {
    if (!_gameStarted) return;

    final int score = _level;

    if (score > _highScore) {
      _highScore = score;
    }

    setState(() {
      _gameStarted = false;
      _isShowingSequence = false;
      _litButton = null;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(
            'Urutan yang ditekan tidak tepat.\n\n'
            'Score: $score\n'
            'High Score: $_highScore',
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _startGame();
              },
              child: const Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorButton(int index) {
    final Color color = _colors[index];
    final bool isLit = _litButton == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isLit ? color : color.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isLit ? Colors.white : Colors.white.withValues(alpha: 0.10),
          width: isLit ? 4 : 1,
        ),
        boxShadow: isLit
            ? <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: 0.65),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ]
            : <BoxShadow>[],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => _handleButtonPress(index),
          child: Center(
            child: AnimatedScale(
              scale: isLit ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Icon(
                Icons.circle,
                size: 38,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double horizontalPadding =
                constraints.maxWidth < 500 ? 20 : 40;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _ScoreCard(
                        title: 'LEVEL',
                        value: '$_level',
                        icon: Icons.layers_rounded,
                      ),
                      _ScoreCard(
                        title: 'HIGH SCORE',
                        value: '$_highScore',
                        icon: Icons.emoji_events_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'SIMON SAYS',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _isShowingSequence
                          ? 'Perhatikan urutan...'
                          : 'Giliran anda!',
                      key: ValueKey<bool>(_isShowingSequence),
                      style: TextStyle(
                        color: _isShowingSequence
                            ? Colors.white70
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: 4,
                          itemBuilder: (BuildContext context, int index) =>
                              _buildColorButton(index),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_gameStarted)
                    FilledButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('RESTART GAME'),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Merah  •  Hijau  •  Biru  •  Kuning',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 22, color: Colors.white70),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
