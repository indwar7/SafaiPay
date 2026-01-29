import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedDustbin extends StatelessWidget {
  final bool eyesClosed;

  const AnimatedDustbin({super.key, this.eyesClosed = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Lottie.asset(
        'assets/lottie/dustbin.json',
        repeat: true,
        animate: true,
      ),
    );
  }
}
