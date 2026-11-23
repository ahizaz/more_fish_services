import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.85,
          heightFactor: 0.85,
          child: Image(
            image: AssetImage('assets/more_fish.jpeg'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
