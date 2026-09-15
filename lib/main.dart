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
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simon Says Game'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Selamat Datang ke Simon Says!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
