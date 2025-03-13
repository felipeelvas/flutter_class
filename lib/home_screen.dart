
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Welcome Home!'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }
}
