import 'package:chess/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Chess());
}

class Chess extends StatelessWidget {
  const Chess({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkers Battle',
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
