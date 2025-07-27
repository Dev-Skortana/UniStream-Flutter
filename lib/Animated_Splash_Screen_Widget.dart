import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:unistream/Views/MainWrapper.dart';

class AnimatedSplashScreenWidget extends StatelessWidget {
  const AnimatedSplashScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset("assets/SplashSCreen UniStream.json"),
      ),
      splashIconSize: 300,
      nextScreen: MainWrapper(),
      duration: 3000,
      backgroundColor: Colors.white,
    );
  }
}
